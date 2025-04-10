//
//  TaskViewModel.swift
//  SandClock
//
//  Created by Sikun Chen on 2025-03-20.
//

import Foundation
import CoreData
import SwiftUI
import Combine

class TaskViewModel: ObservableObject {
    @Published var tasks: [TodoTaskEntity] = []
    @Published var showPeriodTransition = false
    @ObservedObject var clockStorage: ClockStorage
    private let context: NSManagedObjectContext
    private var periodCheckTimer: Timer?
    private var isHandlingOperation = false
    
    init(context: NSManagedObjectContext = PersistenceController.shared.context,
         clockStorage: ClockStorage = ClockStorage()) {
        self.context = context
        self.clockStorage = clockStorage
        fetchTasks()
        setupPeriodCheck()
    }
    
    private func setupPeriodCheck() {
        // Check every hour for period end
        periodCheckTimer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.checkPeriodEnd()
        }
    }
    
    private func checkPeriodEnd() {
        guard !isHandlingOperation else {
            // If handling an operation, schedule a check in 5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                self?.checkPeriodEnd()
            }
            return
        }
        
        let now = Date()
        if now >= clockStorage.currentClock.endDate {
            showPeriodTransition = true
        }
    }

    func fetchTasks() {
        let request: NSFetchRequest<TodoTaskEntity> = TodoTaskEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dueDate", ascending: true)]
        request.predicate = NSPredicate(format: "clockId == %@", clockStorage.currentClock.id as CVarArg)

        do {
            tasks = try context.fetch(request)
        } catch {
            print("Fetch error: \(error)")
        }
    }

    func addTask(title: String, priority: Int16, dueDate: Date, taskType: TaskType) {
        guard !showPeriodTransition else { return }
        
        isHandlingOperation = true
        let newTask = TodoTaskEntity(context: context)
        newTask.id = UUID()
        newTask.title = title
        newTask.isCompleted = false
        newTask.priority = priority
        newTask.dueDate = dueDate
        newTask.originalDueDate = dueDate
        newTask.taskType = taskType.name
        newTask.taskTypeColor = taskType.color
        newTask.clockId = clockStorage.currentClock.id

        save()
        isHandlingOperation = false
    }

    func toggleTaskCompletion(_ task: TodoTaskEntity) {
        isHandlingOperation = true
        task.isCompleted.toggle()
        save()
        isHandlingOperation = false
    }

    func deleteTask(_ task: TodoTaskEntity) {
        isHandlingOperation = true
        context.delete(task)
        save()
        isHandlingOperation = false
    }
    
    func startNewPeriod(transferringTasks selectedTasks: [TodoTaskEntity]) {
        isHandlingOperation = true
        
        // Archive current clock with stats
        let stats = (
            total: tasks.count,
            completed: tasks.filter { $0.isCompleted }.count
        )
        clockStorage.archiveCurrent(withStats: stats)
        
        // Transfer selected tasks to new period
        for task in selectedTasks {
            let newTask = TodoTaskEntity(context: context)
            newTask.id = UUID()
            newTask.title = task.title
            newTask.isCompleted = false
            newTask.priority = task.priority
            newTask.dueDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
            newTask.originalDueDate = task.originalDueDate
            newTask.taskType = task.taskType
            newTask.taskTypeColor = task.taskTypeColor
            newTask.clockId = clockStorage.currentClock.id
        }
        
        // Delete old tasks
        for task in tasks {
            context.delete(task)
        }
        
        save()
        showPeriodTransition = false
        isHandlingOperation = false
    }

    private func save() {
        do {
            try context.save()
            fetchTasks()
        } catch {
            print("Save error: \(error)")
            isHandlingOperation = false
        }
    }
    
    deinit {
        periodCheckTimer?.invalidate()
    }
}

// MARK: - Task Filtering
extension TaskViewModel {
    var pendingTasks: [TodoTaskEntity] {
        tasks.filter { !$0.isCompleted && !$0.isOverdue }
    }

    var completedTasks: [TodoTaskEntity] {
        tasks.filter { $0.isCompleted }
    }
    
    var overdueTasks: [TodoTaskEntity] {
        tasks.filter { !$0.isCompleted && $0.isOverdue }
    }
    
    var unfinishedTasks: [TodoTaskEntity] {
        tasks.filter { !$0.isCompleted }
    }
}

// MARK: - Bead Visual Info
extension TodoTaskEntity {
    var beadColor: Color {
        switch priority {
        case 1: return .red
        case 2: return .orange
        case 3: return .yellow
        case 4: return .green
        default: return .blue
        }
    }

    func topPosition(in width: CGFloat) -> CGPoint {
        let x = CGFloat.random(in: width * 0.3...width * 0.7)
        let y = CGFloat.random(in: width * 0.2...width * 0.4)
        return CGPoint(x: x, y: y)
    }

    func bottomPosition(in width: CGFloat) -> CGPoint {
        let x = CGFloat.random(in: width * 0.3...width * 0.7)
        let y = CGFloat.random(in: width * 1.6...width * 1.8)
        return CGPoint(x: x, y: y)
    }
}
