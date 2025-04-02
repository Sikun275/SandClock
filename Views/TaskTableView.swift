//
//  TaskTableView.swift
//  SandClock
//
//  Created by Sikun Chen on 2025-03-31.
//

import SwiftUI

struct TaskTableView: View {
    var tasks: [TodoTaskEntity]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(tasks, id: \ .self) { task in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(task.title ?? "Untitled")
                                .font(.headline)

                            HStack(spacing: 12) {
                                Text("Priority: \(task.priority)")
                                if let due = task.dueDate {
                                    Text("Due: \(formatted(due))")
                                }
                            }
                            .font(.subheadline)
                        }
                        Spacer()
                        Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(task.isCompleted ? .green : .gray)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                }
            }
            .padding()
        }
    }

    private func formatted(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        return fmt.string(from: date)
    }
    
    
}
