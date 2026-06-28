import Foundation
import UIKit
import Vision

actor OCRService {
    static let shared = OCRService()
    
    /// Mengekstrak teks dari daftar gambar menggunakan VNRecognizeTextRequest
    func extractText(from images: [UIImage]) async throws -> [String] {
        var extractedLines: [String] = []
        
        for image in images {
            guard let cgImage = image.cgImage else {
                continue
            }
            
            let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            let lines = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[String], Error>) in
                let request = VNRecognizeTextRequest { request, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    
                    guard let observations = request.results as? [VNRecognizedTextObservation] else {
                        continuation.resume(returning: [])
                        return
                    }
                    
                    let recognizedStrings = observations.compactMap { observation in
                        // Ambil kandidat dengan tingkat kepercayaan paling tinggi
                        observation.topCandidates(1).first?.string
                    }
                    
                    continuation.resume(returning: recognizedStrings)
                }
                
                // Gunakan bahasa Indonesia jika didukung, jika tidak default ke en-US
                request.recognitionLanguages = ["id-ID", "en-US"]
                request.recognitionLevel = .accurate
                
                do {
                    try requestHandler.perform([request])
                } catch {
                    continuation.resume(throwing: error)
                }
            }
            
            extractedLines.append(contentsOf: lines)
        }
        
        // Membersihkan teks yang kosong atau hanya spasi
        let cleanedLines = extractedLines
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            
        return cleanedLines
    }
}
