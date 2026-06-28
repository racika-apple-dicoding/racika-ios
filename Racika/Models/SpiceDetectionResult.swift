import Foundation
import UIKit

struct RegionalName: Identifiable, Codable, Hashable {
    let id = UUID()
    let language: String
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case language
        case name
    }
}

struct AlternativeSpice: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let reason: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case reason
    }
}

struct SpiceDetectionResult: Identifiable, Hashable {
    let id = UUID()
    let classLabel: String
    let displayName: String
    let accuracy: Double
    let capturedImage: UIImage
    let capturedDate: Date

    var latinName: String = ""
    var about: String = ""
    var storageMethod: String = ""
    var storageIcon: String = ""
    var regionalNames: [RegionalName] = []
    var alternatives: [AlternativeSpice] = []

    // Hashable by id only — UIImage is not Hashable
    static func == (lhs: SpiceDetectionResult, rhs: SpiceDetectionResult) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
