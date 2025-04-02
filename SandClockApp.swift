//
//  SandClockApp.swift
//  SandClock
//
//  Created by Sikun Chen on 2025-03-20.
//

import SwiftUI

@main
struct SandClockApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.context)
        }
    }
}
