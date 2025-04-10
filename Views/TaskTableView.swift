//
//  TaskTableView.swift
//  SandClock
//
//  Created by Sikun Chen on 2025-03-31.
//

import SwiftUI

/// Interactive task list view supporting completion toggle, deletion, and status display.
/// Requires TaskViewModel for operations and expects tasks with type colors and completion states.
struct TaskTableView: View {
    // MARK: - Properties
    let tasks: [TodoTaskEntity]
    let viewModel: TaskViewModel
    
    // MARK: - Body
    var body: some View {
        List {
            ForEach(tasks) { task in
                taskRow(for: task)
            }
            .onDelete { indexSet in
                deleteTask(at: indexSet)
            }
        }
        .listStyle(PlainListStyle())
    }
    
    // MARK: - Private Views
    private func taskRow(for task: TodoTaskEntity) -> some View {
        HStack {
            Circle()
                .fill(task.displayColor)
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading) {
                Text(task.title ?? "Untitled")
                    .strikethrough(task.isCompleted)
                if let dueDate = task.dueDate {
                    Text(dueDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: { toggleTaskCompletion(task) }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(task.isCompleted ? .green : .gray)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Private Methods
    private func toggleTaskCompletion(_ task: TodoTaskEntity) {
        withAnimation {
            viewModel.toggleTaskCompletion(task)
        }
    }
    
    private func deleteTask(at indexSet: IndexSet) {
        for index in indexSet {
            viewModel.deleteTask(tasks[index])
        }
    }
}

#Preview {
    let context = PersistenceController.preview.context
    let viewModel = TaskViewModel(context: context)
    return TaskTableView(tasks: [], viewModel: viewModel)
}
