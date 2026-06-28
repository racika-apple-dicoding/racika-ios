import Foundation
import Observation

struct ShoppingListItem: Identifiable, Codable, Equatable, Hashable {
    var id: UUID = UUID()
    var name: String
    var isChecked: Bool = false
    var addedDate: Date = Date()
}

@Observable final class ShoppingListStore {
    static let shared = ShoppingListStore()
    
    var items: [ShoppingListItem] = []
    
    private init() {
        loadData()
    }
    
    func save(ingredients: [String]) {
        // Insert new items at the top of the list
        let newItems = ingredients.map { ShoppingListItem(name: $0) }
        items.insert(contentsOf: newItems, at: 0)
        saveData()
    }
    
    func toggle(item: ShoppingListItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isChecked.toggle()
            saveData()
        }
    }
    
    func delete(item: ShoppingListItem) {
        items.removeAll { $0.id == item.id }
        saveData()
    }
    
    // MARK: - Persistence Helper Methods
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func saveData() {
        let url = getDocumentsDirectory().appendingPathComponent("shopping_list.json")
        do {
            let data = try JSONEncoder().encode(items)
            try data.write(to: url)
        } catch {
            print("ShoppingListStore: Failed to encode metadata — \(error)")
        }
    }
    
    private func loadData() {
        let url = getDocumentsDirectory().appendingPathComponent("shopping_list.json")
        guard FileManager.default.fileExists(atPath: url.path) else { return }
        do {
            let data = try Data(contentsOf: url)
            let decodedItems = try JSONDecoder().decode([ShoppingListItem].self, from: data)
            self.items = decodedItems
        } catch {
            print("ShoppingListStore: Failed to load history — \(error)")
        }
    }
}
