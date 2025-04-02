//
//  TaskViewModel.swift
//  SandClock
//
//  Created by Sikun Chen on 2025-03-20.
//

import Foundation
import CoreData
import SwiftUI

class TaskViewModel: ObservableObject {
    @Published var tasks: [TodoTaskEntity] = []
    private let context: NSManagedObjectContext = PersistenceController.shared.context

    func fetchTasks() {
        let request: NSFetchRequest<TodoTaskEntity> = TodoTaskEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dueDate", ascending: true)]

        do {
            tasks = try context.fetch(request)
        } catch {
            print("Fetch error: \(error)")
        }
    }

    func addTask(title: String, priority: Int16, dueDate: Date) {
        let newTask = TodoTaskEntity(context: context)
        newTask.id = UUID()
        newTask.title = title
        newTask.isCompleted = false
        newTask.priority = priority
        newTask.dueDate = dueDate

        save()
        
        do {
                try context.save()
                fetchTasks()
            } catch {
                print("Save error: \(error)")
            }
    }

    func toggleTaskCompletion(_ task: TodoTaskEntity) {
        task.isCompleted.toggle()
        save()
    }

    func deleteTask(_ task: TodoTaskEntity) {
        context.delete(task)
        save()
    }

    private func save() {
        do {
            try context.save()
            fetchTasks()
        } catch {
            print("Save error: \(error)")
        }
    }
}

// MARK: - ViewModel Extensions
extension TaskViewModel {
    var pendingTasks: [TodoTaskEntity] {
        tasks.filter { !$0.isCompleted }
    }

    var completedTasks: [TodoTaskEntity] {
        tasks.filter { $0.isCompleted || ($0.dueDate ?? Date()) < Date() }
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
