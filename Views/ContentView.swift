//
//  ContentView.swift
//  SandClock
//
//  Created by Sikun Chen on 2025-03-20.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = TaskViewModel()
    @State private var showingAddTask = false
    @State private var showTable = false

    var body: some View {
        VStack(spacing: 16) {
            // Top Controls
            HStack {
                Button("Add") {
                    showingAddTask = true
                }
                Spacer()
                Text("SandClock")
                    .font(.title.bold())
                Spacer()
                Button(action: { showingAddTask = true }) {
                    Image(systemName: "plus")
                }
            }
            .padding(.horizontal)

            // Spacer to push hourglass into center
            Spacer(minLength: 20)

            // Hourglass View Centered
            HourglassView(viewModel: viewModel)
                .transition(.scale.combined(with: .opacity))
                .animation(.spring(), value: viewModel.tasks.count)

            // Spacer to keep hourglass centered
            Spacer()

            // Clock Label
            Text("Clock #1")
                .font(.headline)
                .padding(.bottom)
            
            Button(action: { showTable.toggle() }) {
                    Text(showTable ? "Hide Task List" : "Show Task List")
                        .font(.subheadline)
                        .padding(.top, 8)
            }

            if showTable {
                TaskTableView(tasks: viewModel.tasks)
            }
        }
        .padding()
        .sheet(isPresented: $showingAddTask, onDismiss: {
            viewModel.fetchTasks()
        }) {
            AddTaskView { title, priority, dueDate in
                withAnimation {
                    viewModel.addTask(title: title, priority: priority, dueDate: dueDate)
                }
            }
        }
        .onAppear {
            viewModel.fetchTasks()
        }
    }

    func completionRate() -> Double {
        let total = viewModel.tasks.count
        let done = viewModel.tasks.filter { $0.isCompleted }.count
        return total == 0 ? 0 : Double(done) / Double(total)
    }

    func formattedDate(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        return fmt.string(from: date)
    }
}

