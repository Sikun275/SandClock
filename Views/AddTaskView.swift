//
//  AddTaskView.swift
//  SandClock
//
//  Created by Sikun Chen on 2025-03-22.
//

import SwiftUI

struct AddTaskView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var taskTypeStorage = TaskTypeStorage()
    @State private var title: String = ""
    @State private var priority: Int = 1
    @State private var dueDate: Date = Date()
    @State private var selectedTaskType: TaskType = .none
    @State private var isAddingNewType = false

    var onSave: (String, Int16, Date, TaskType) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Task Info")) {
                    TextField("Title", text: $title)
                    
                    Picker("Priority", selection: $priority) {
                        ForEach(1...4, id: \.self) { 
                            Text("\($0)").tag($0)
                        }
                    }
                    
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
                    
                    Picker("Task Type", selection: $selectedTaskType) {
                        ForEach(taskTypeStorage.types) { type in
                            HStack {
                                Circle()
                                    .fill(type.color)
                                    .frame(width: 20, height: 20)
                                Text(type.name)
                            }
                            .tag(type)
                        }
                    }
                }
                
                Section {
                    Button("Add New Type") {
                        isAddingNewType = true
                    }
                }
            }
            .navigationTitle("New Task")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(title, Int16(priority), dueDate, selectedTaskType)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $isAddingNewType) {
                AddTaskTypeView(taskTypeStorage: taskTypeStorage)
            }
        }
    }
}

struct AddTaskTypeView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var taskTypeStorage: TaskTypeStorage
    @State private var typeName: String = ""
    @State private var selectedColor: Color = .blue
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Type Name", text: $typeName)
                
                ColorPicker("Select Color", selection: $selectedColor)
                
                HStack {
                    Text("Preview:")
                    Circle()
                        .fill(selectedColor)
                        .frame(width: 30, height: 30)
                }
            }
            .navigationTitle("New Task Type")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !typeName.isEmpty {
                            let components = selectedColor.components
                            taskTypeStorage.addType(name: typeName, colorName: "Custom", red: components.red, green: components.green, blue: components.blue)
                            dismiss()
                        }
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
