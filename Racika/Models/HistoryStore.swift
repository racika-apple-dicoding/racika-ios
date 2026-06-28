import Foundation
import Observation
import UIKit

struct CodableSpiceDetectionResult: Codable {
    let id: UUID
    let classLabel: String
    let displayName: String
    let accuracy: Double
    let imageName: String
    let capturedDate: Date
    let latinName: String
    let about: String
    let storageMethod: String
    let storageIcon: String
    let regionalNames: [RegionalName]
    let alternatives: [AlternativeSpice]
}

@Observable final class HistoryStore {
    static let shared = HistoryStore()
    
    var items: [SpiceDetectionResult] = []
    
    private init() {
        loadHistory()
    }
    
    func save(_ result: SpiceDetectionResult) {
        items.insert(result, at: 0)
        let imageName = "\(result.id.uuidString).jpg"
        _ = saveImage(result.capturedImage, name: imageName)
        saveMetadata()
    }

    func delete(_ result: SpiceDetectionResult) {
        items.removeAll { $0.id == result.id }
        let imageName = "\(result.id.uuidString).jpg"
        deleteImage(name: imageName)
        saveMetadata()
    }
    
    // MARK: - Persistence Helper Methods
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func saveImage(_ image: UIImage, name: String) -> Bool {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return false }
        let url = getDocumentsDirectory().appendingPathComponent(name)
        do {
            try data.write(to: url)
            return true
        } catch {
            print("HistoryStore: Failed to save image \(name) — \(error)")
            return false
        }
    }
    
    private func loadImage(name: String) -> UIImage? {
        let url = getDocumentsDirectory().appendingPathComponent(name)
        return UIImage(contentsOfFile: url.path)
    }
    
    private func deleteImage(name: String) {
        let url = getDocumentsDirectory().appendingPathComponent(name)
        try? FileManager.default.removeItem(at: url)
    }
    
    private func saveMetadata() {
        let codableItems = items.map { item in
            CodableSpiceDetectionResult(
                id: item.id,
                classLabel: item.classLabel,
                displayName: item.displayName,
                accuracy: item.accuracy,
                imageName: "\(item.id.uuidString).jpg",
                capturedDate: item.capturedDate,
                latinName: item.latinName,
                about: item.about,
                storageMethod: item.storageMethod,
                storageIcon: item.storageIcon,
                regionalNames: item.regionalNames,
                alternatives: item.alternatives
            )
        }
        
        let url = getDocumentsDirectory().appendingPathComponent("history.json")
        do {
            let data = try JSONEncoder().encode(codableItems)
            try data.write(to: url)
        } catch {
            print("HistoryStore: Failed to encode metadata — \(error)")
        }
    }
    
    private func loadHistory() {
        let url = getDocumentsDirectory().appendingPathComponent("history.json")
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            let data = try Data(contentsOf: url)
            let codableItems = try JSONDecoder().decode([CodableSpiceDetectionResult].self, from: data)
            self.items = codableItems.compactMap { codable in
                guard let image = loadImage(name: codable.imageName) else {
                    return nil
                }
                return SpiceDetectionResult(
                    id: codable.id,
                    classLabel: codable.classLabel,
                    displayName: codable.displayName,
                    accuracy: codable.accuracy,
                    capturedImage: image,
                    capturedDate: codable.capturedDate,
                    latinName: codable.latinName,
                    about: codable.about,
                    storageMethod: codable.storageMethod,
                    storageIcon: codable.storageIcon,
                    regionalNames: codable.regionalNames,
                    alternatives: codable.alternatives
                )
            }
        } catch {
            print("HistoryStore: Failed to load history — \(error)")
        }
    }
}
