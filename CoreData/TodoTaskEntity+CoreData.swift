//
//  TodoTask+CoreData.swift
//  SandClock
//
//  Created by Sikun Chen on 2025-03-20.
//
//

import Foundation
import CoreData

@objc(TodoTaskEntity)
public class TodoTaskEntity: NSManagedObject {}

extension TodoTaskEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<TodoTaskEntity> {
        return NSFetchRequest<TodoTaskEntity>(entityName: "TodoTaskEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var title: String?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var priority: Int16
    @NSManaged public var dueDate: Date?
}
