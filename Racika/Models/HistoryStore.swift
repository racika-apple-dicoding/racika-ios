import Foundation
import Observation

@Observable final class HistoryStore {
    static let shared = HistoryStore()
    
    var items: [SpiceDetectionResult] = []
    
    func save(_ result: SpiceDetectionResult) {
        items.insert(result, at: 0)
    }

    func delete(_ result: SpiceDetectionResult) {
        items.removeAll { $0.id == result.id }
    }
}
