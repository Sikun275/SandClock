//
//  ContentView.swift
//  SandClock
//
//  Created by Sikun Chen on 2025-03-20.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TaskViewModel()
    @StateObject private var clockStorage = ClockStorage()
    @SceneStorage("selected_tab") private var selectedTab = 0
    @State private var activeSheet: ActiveSheet?
    @State private var showTable = false
    @State private var pendingTask: PendingTask?
    @State private var showTransitionAlert = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Main Hourglass View
            NavigationView {
                VStack(spacing: 16) {
                    HourglassView(viewModel: viewModel, clockStorage: clockStorage)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(), value: viewModel.tasks.count)

                    if showTable {
                        TaskTableView(tasks: viewModel.tasks, viewModel: viewModel)
                            .transition(.move(edge: .bottom))
                    }
                }
                .padding()
                .navigationTitle("SandClock")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { handleAddTaskTap() }) {
                            Image(systemName: "plus")
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: { 
                            withAnimation(.spring()) {
                                showTable.toggle()
                            }
                        }) {
                            Image(systemName: showTable ? "list.bullet.circle.fill" : "list.bullet.circle")
                        }
                    }
                }
            }
            .tabItem {
                Label("Clock", systemImage: "hourglass")
            }
            .tag(0)
            
            // Shelf View
            NavigationView {
                ShelfView(clockStorage: clockStorage)
            }
            .tabItem {
                Label("Shelf", systemImage: "archivebox")
            }
            .tag(1)
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .addTask:
                AddTaskView(onSave: { title, priority, dueDate, taskType in
                    guard !title.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    withAnimation {
                        viewModel.addTask(title: title, priority: priority, dueDate: dueDate, taskType: taskType)
                    }
                })
            case .periodTransition:
                PeriodTransitionView(viewModel: viewModel) {
                    // Completion handler after transition
                    if let pending = pendingTask {
                        activeSheet = .addTask
                        pendingTask = nil
                    }
                }
            }
        }
        .onChange(of: viewModel.showPeriodTransition) { shouldShow in
            if shouldShow {
                handlePeriodTransition()
            }
        }
        .alert("Period Transition", isPresented: $showTransitionAlert) {
            Button("Add After Transition") {
                // Save the pending task info
                activeSheet = .periodTransition
            }
            Button("Cancel", role: .cancel) {
                pendingTask = nil
            }
        } message: {
            Text("A period transition is in progress. Would you like to add your task after the transition?")
        }
    }
    
    private func handleAddTaskTap() {
        if viewModel.showPeriodTransition {
            // Save current state and show alert
            pendingTask = PendingTask()
            showTransitionAlert = true
        } else {
            activeSheet = .addTask
        }
    }
    
    private func handlePeriodTransition() {
        if activeSheet == .addTask {
            // If adding task, save state and show alert
            pendingTask = PendingTask()
            activeSheet = nil
            showTransitionAlert = true
        } else {
            activeSheet = .periodTransition
        }
    }
}

// MARK: - Supporting Types
enum ActiveSheet: Identifiable {
    case addTask, periodTransition
    
    var id: Int { hashValue }
}

struct PendingTask {
    let timestamp = Date()
} 