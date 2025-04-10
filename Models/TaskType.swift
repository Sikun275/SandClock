import SwiftUI

struct TaskType: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var colorName: String
    
    var color: Color {
        Theme.availableColors.first { $0.name == colorName }?.color ?? .blue
    }
    
    init(id: UUID = UUID(), name: String, colorName: String) {
        self.id = id
        self.name = name
        self.colorName = colorName
    }
    
    static let none = TaskType(name: "None", colorName: "Blue")
}

// MARK: - Task Type Storage
class TaskTypeStorage: ObservableObject {
    @Published private(set) var types: [TaskType] = [.none]
    private let defaults = UserDefaults.standard
    private let storageKey = "com.sandclock.taskTypes"
    
    init() {
        loadTypes()
    }
    
    func addType(name: String, colorName: String) {
        let newType = TaskType(name: name, colorName: colorName)
        types.append(newType)
        saveTypes()
    }
    
    func removeType(_ type: TaskType) {
        guard type.name != "None" else { return } // Prevent removing default type
        types.removeAll { $0.id == type.id }
        saveTypes()
    }
    
    private func loadTypes() {
        guard let data = defaults.data(forKey: storageKey),
              let decodedTypes = try? JSONDecoder().decode([TaskType].self, from: data)
        else { return }
        
        types = decodedTypes
        if !types.contains(where: { $0.name == "None" }) {
            types.insert(.none, at: 0)
        }
    }
    
    private func saveTypes() {
        guard let encoded = try? JSONEncoder().encode(types) else { return }
        defaults.set(encoded, forKey: storageKey)
    }
} 