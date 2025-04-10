//
//  TodoTask+CoreData.swift
//  SandClock
//
//  Created by Sikun Chen on 2025-03-20.
//
//

import Foundation
import CoreData
import SwiftUI

@objc(TodoTaskEntity)
public class TodoTaskEntity: NSManagedObject {
    // Helper computed properties
    var isOverdue: Bool {
        guard let dueDate = dueDate else { return false }
        return !isCompleted && dueDate < Date()
    }
    
    var displayColor: Color {
        if isOverdue {
            return Theme.overdueColor
        }
        return taskTypeColor ?? .blue // Default color if no type color is set
    }
    
    var beadSize: CGFloat {
        return Theme.Hourglass.prioritySizes[Int(priority)] ?? Theme.Hourglass.prioritySizes[1]!
    }
}

extension TodoTaskEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoTaskEntity> {
        return NSFetchRequest<TodoTaskEntity>(entityName: "TodoTaskEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var priority: Int16
    @NSManaged public var dueDate: Date?
    @NSManaged public var taskType: String?
    @NSManaged public var taskTypeColor: Color?
    @NSManaged public var clockId: UUID?
    @NSManaged public var originalDueDate: Date?
}
