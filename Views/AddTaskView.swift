//
//  AddTaskView.swift
//  SandClock
//
//  Created by Sikun Chen on 2025-03-22.
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @State private var title: String = ""
    @State private var priority: Int = 1
    @State private var dueDate: Date = Date()

    var onSave: (String, Int16, Date) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Info")) {
                    TextField("Title", text: $title)
                    Picker("Priority", selection: $priority) {
                        ForEach(1...5, id: \ .self) { Text("\($0)") }
                    }
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                }
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(title, Int16(priority), dueDate)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
