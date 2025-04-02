//
//  PersistenceController.swift
//  SandClock
//
//  Created by Sikun Chen on 2025-03-20.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "SandClock") // Must match xcdatamodeld filename
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        }
    }
    
    var context: NSManagedObjectContext {
        return container.viewContext
    }
}
