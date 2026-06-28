//
//  CameraView.swift
//  Racika
//
//  Created by Daffa Putera Kouseina on 28/06/26.
//

import SwiftUI

struct CameraView: View {
    @State private var cameraManager = CameraManager()
    @State private var detectionResult: SpiceDetectionResult?
    @State private var isDetecting = false
    
    private var cameraPreview: some View {
        CameraPreviewView(previewLayer: cameraManager.previewLayer)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let capturedImage = cameraManager.capturedImage {
                    // Tampilan preview foto yang berhasil diambil
                    Image(uiImage: capturedImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                    
                    VStack {
                        Spacer()
                        HStack {
                            Button(action: {
                                cameraManager.capturedImage = nil
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text("Ambil Ulang")
                                }
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 14)
                                .background(Color.black.opacity(0.72))
                                .clipShape(Capsule())
                                .shadow(color: .black.opacity(0.16), radius: 8, x: 0, y: 4)
                            }
                        }
                        .padding(.bottom, geo.safeAreaInsets.bottom + 24)
                    }
                    
                    if isDetecting {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(.white)
                            Text("Mendeteksi rempah...")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.5))
                    }
                } else {
                    // Live camera preview
                    cameraPreview
                    
                    // Tombol shutter
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                cameraManager.capturePhoto()
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 72, height: 72)
                                    Circle()
                                        .stroke(Color.white, lineWidth: 3)
                                        .frame(width: 82, height: 82)
                                }
                            }
                            .buttonStyle(ShutterButtonStyle())
                            Spacer()
                        }
                        .padding(.bottom, geo.safeAreaInsets.bottom + 24)
                    }
                }
            }
        }
        .navigationTitle("Scan Rempah")
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea(edges: .bottom)
        .onAppear { cameraManager.startSession() }
        .onDisappear { cameraManager.stopSession() }
        .alert("Akses Kamera Ditolak", isPresented: Bindable(cameraManager).permissionDenied) {
            Button("Buka Pengaturan") {
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            }
            Button("Kembali", role: .cancel) { dismiss() }
        } message: {
            Text("Racika butuh akses kamera. Aktifkan di Pengaturan > Racika.")
        }
        .onChange(of: cameraManager.capturedImage) { _, newImage in
            guard let image = newImage else { return }
            isDetecting = true
            Task {
                if let result = await cameraManager.runDetection(on: image) {
                    await MainActor.run {
                        self.detectionResult = result
                        self.isDetecting = false
                    }
                } else {
                    await MainActor.run {
                        self.isDetecting = false
                    }
                }
            }
        }
        .sheet(item: $detectionResult) { result in
            DetectionResultView(
                result: result,
                onSave: { finalResult in
                    HistoryStore.shared.save(finalResult)
                    detectionResult = nil
                    cameraManager.capturedImage = nil
                    dismiss()
                },
                onRetake: {
                    detectionResult = nil
                    cameraManager.capturedImage = nil
                }
            )
        }
    }

    @Environment(\.dismiss) private var dismiss
}

#Preview {
    NavigationStack {
        CameraView()
    }
}

struct ShutterButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
