//
//  CameraManager.swift
//  WhatInMyFridge
//
//  Created by Daffa Putera Kouseina on 27/06/26.
//

import AVFoundation
import Vision
import CoreML
import SwiftUI

@Observable
final class CameraManager: NSObject {
    struct Detection: Identifiable {
        let id = UUID()
        let label: String
        let confidence: Float
        let boundingBox: CGRect  // Vision coords: normalized, origin bottom-left
    }

    // State yang dibaca SwiftUI — selalu diperbarui dari main thread
    var detections: [Detection] = []
    var isRunning = false
    var permissionDenied = false
    var capturedImage: UIImage? = nil
    
    // previewLayer diakses dari main thread saat attach ke UIView
    let previewLayer = AVCaptureVideoPreviewLayer()

    // Properti berikut diakses dari background queue — butuh nonisolated(unsafe)
    nonisolated(unsafe) private let session = AVCaptureSession()
    nonisolated(unsafe) private let videoOutput = AVCaptureVideoDataOutput()
    nonisolated(unsafe) private let photoOutput = AVCapturePhotoOutput()
    nonisolated(unsafe) private let sessionQueue = DispatchQueue(label: "camera.session.queue")
    nonisolated(unsafe) private let inferenceQueue = DispatchQueue(label: "camera.inference.queue", qos: .userInitiated)
    private var visionModel: VNCoreMLModel?
    private var lastInferenceTime = Date.distantPast

    // Interval minimum antar inferensi = 0.2 detik → maksimal 5 FPS
    private let inferenceInterval: TimeInterval = 0.2
    
    override init() {
        super.init()
        setupSession()
        sessionQueue.async { [weak self] in
            self?.setupModel()
        }
    }
    
    private func setupModel() {
        do {
            let config = MLModelConfiguration()
            let mlModel = try RacikaAPP2(configuration: config).model
            visionModel = try VNCoreMLModel(for: mlModel)
        } catch {
            print("CameraManager: gagal load model — \(error)")
        }
    }
    
    private func setupSession() {
        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspectFill
    }
    
    nonisolated private func configureInputOutput() {
        session.sessionPreset = .medium
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else {
            print("CameraManager: gagal setup input kamera")
            return
        }

        session.beginConfiguration()
        session.addInput(input)

        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: inferenceQueue)

        if session.canAddOutput(videoOutput) {
            session.addOutput(videoOutput)
        }
        
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }

        session.commitConfiguration()
    }

    // MARK: - Control

    func startSession() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            startCapture()
        case .notDetermined:
            // [weak self]: closure ini bisa hidup lebih lama dari objectnya — weak mencegah memory leak
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.startCapture()
                } else {
                    DispatchQueue.main.async { self?.permissionDenied = true }
                }
            }
        default:
            DispatchQueue.main.async { self.permissionDenied = true }
        }
    }

    private func startCapture() {
        sessionQueue.async { [weak self] in
            // guard let self: pastikan object masih ada sebelum melanjutkan
            guard let self, !self.session.isRunning else { return }
            if self.session.inputs.isEmpty {
                self.configureInputOutput()
            }
            self.session.startRunning()
            DispatchQueue.main.async { self.isRunning = true }
        }
    }

    func stopSession() {
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            self.session.stopRunning()
            DispatchQueue.main.async { self.isRunning = false }
        }
    }

    func capturePhoto() {
        sessionQueue.async { [weak self] in
            guard let self, self.session.isRunning else { return }
            let settings = AVCapturePhotoSettings()
            self.photoOutput.capturePhoto(with: settings, delegate: self)
        }
    }
    
    func runDetection(on image: UIImage) async -> SpiceDetectionResult? {
        guard let cgImage = image.cgImage, let model = visionModel else {
            return nil
        }
        
        return await withCheckedContinuation { continuation in
            let request = VNCoreMLRequest(model: model) { request, error in
                guard error == nil,
                      let results = request.results as? [VNClassificationObservation],
                      let best = results.first else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let result = SpiceDetectionResult(
                    classLabel: best.identifier,
                    displayName: best.identifier.replacingOccurrences(of: "_", with: " ").capitalized,
                    accuracy: Double(best.confidence),
                    capturedImage: image,
                    capturedDate: Date()
                )
                continuation.resume(returning: result)
            }
            
            request.imageCropAndScaleOption = .centerCrop
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform detection: \\(error)")
                continuation.resume(returning: nil)
            }
        }
    }
}

extension CameraManager: AVCaptureVideoDataOutputSampleBufferDelegate {
    nonisolated func captureOutput(_ output: AVCaptureOutput,
                                   didOutput sampleBuffer: CMSampleBuffer,
                                   from connection: AVCaptureConnection) {
        // Lewati frame jika belum mencapai interval minimum
        let now = Date()
        guard now.timeIntervalSince(lastInferenceTime) >= inferenceInterval else { return }
        lastInferenceTime = now

        guard let model = visionModel,
              let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        let request = VNCoreMLRequest(model: model) { [weak self] request, error in
            guard error == nil,
                  let observations = request.results as? [VNRecognizedObjectObservation] else { return }

            let detections = observations
                .filter { $0.confidence > 0.3 }
                .map { Detection(label: $0.labels.first?.identifier.capitalized ?? "?",
                                 confidence: $0.confidence,
                                 boundingBox: $0.boundingBox) }

            DispatchQueue.main.async {
                self?.detections = detections
            }
        }

        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer,
                                            orientation: .right,
                                            options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Inference error: \(error)")
        }
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("CameraManager: gagal capture foto — \(error)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            print("CameraManager: gagal memproses image data")
            return
        }
        
        DispatchQueue.main.async {
            self.capturedImage = image
        }
    }
}
