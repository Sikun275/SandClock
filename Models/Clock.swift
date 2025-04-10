import Foundation

struct Clock: Identifiable, Codable {
    let id: UUID
    var name: String
    var startDate: Date
    var endDate: Date
    var isArchived: Bool
    var completionRate: Double
    var totalTasks: Int
    var completedTasks: Int
    
    init(id: UUID = UUID(), 
         name: String = "New Clock",
         startDate: Date = Date(),
         periodInDays: Int = 7) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = Calendar.current.date(byAdding: .day, value: periodInDays, to: startDate) ?? startDate
        self.isArchived = false
        self.completionRate = 0
        self.totalTasks = 0
        self.completedTasks = 0
    }
}

// MARK: - Clock Storage
class ClockStorage: ObservableObject {
    @Published private(set) var clocks: [Clock] = []
    @Published var currentClock: Clock
    private let defaults = UserDefaults.standard
    private let storageKey = "com.sandclock.clocks"
    
    init() {
        self.currentClock = Clock()
        loadClocks()
    }
    
    func updateCurrentClock(name: String) {
        currentClock.name = name
        saveClocks()
    }
    
    func archiveCurrent(withStats stats: (total: Int, completed: Int)) {
        var clockToArchive = currentClock
        clockToArchive.isArchived = true
        clockToArchive.totalTasks = stats.total
        clockToArchive.completedTasks = stats.completed
        clockToArchive.completionRate = stats.total > 0 ? Double(stats.completed) / Double(stats.total) : 0
        
        if let index = clocks.firstIndex(where: { $0.id == currentClock.id }) {
            clocks[index] = clockToArchive
        } else {
            clocks.append(clockToArchive)
        }
        
        currentClock = Clock()
        saveClocks()
    }
    
    private func loadClocks() {
        guard let data = defaults.data(forKey: storageKey),
              let decodedClocks = try? JSONDecoder().decode([Clock].self, from: data)
        else { return }
        
        clocks = decodedClocks.filter { $0.isArchived }
        
        if let activeClock = decodedClocks.first(where: { !$0.isArchived }) {
            currentClock = activeClock
        }
    }
    
    private func saveClocks() {
        var allClocks = clocks
        allClocks.append(currentClock)
        
        guard let encoded = try? JSONEncoder().encode(allClocks) else { return }
        defaults.set(encoded, forKey: storageKey)
    }
} 