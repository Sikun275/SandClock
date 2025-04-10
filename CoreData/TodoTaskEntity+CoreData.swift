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
        return taskTypeColor
    }
    
    var beadSize: CGFloat {
        return Theme.Hourglass.prioritySizes[Int(priority)] ?? Theme.Hourglass.prioritySizes[1]!
    }
    
    var taskTypeColor: Color {
        get {
            Color(red: red, green: green, blue: blue)
        }
        set {
            red = newValue.components.red
            green = newValue.components.green
            blue = newValue.components.blue
        }
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
    @NSManaged public var red: Double
    @NSManaged public var green: Double
    @NSManaged public var blue: Double
    @NSManaged public var clockId: UUID?
    @NSManaged public var originalDueDate: Date?
}

// MARK: - Color Components Extension
extension Color {
    var components: (red: Double, green: Double, blue: Double) {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        return (Double(red), Double(green), Double(blue))
    }
}
