import SwiftUI

struct PeriodTransitionView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TaskViewModel
    @State private var selectedTasks: Set<UUID> = []
    var onCompletion: (() -> Void)?
    
    var body: some View {
        NavigationView {
            List(viewModel.unfinishedTasks) { task in
                TaskRowView(task: task, isSelected: selectedTasks.contains(task.id!)) {
                    if let id = task.id {
                        if selectedTasks.contains(id) {
                            selectedTasks.remove(id)
                        } else {
                            selectedTasks.insert(id)
                        }
                    }
                }
            }
            .navigationTitle("Transfer Tasks")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Transfer") {
                        handleTransfer()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") {
                        handleSkip()
                    }
                }
            }
        }
        .interactiveDismissDisabled() // Prevent dismissal by drag
    }
    
    private func handleTransfer() {
        let tasksToTransfer = viewModel.unfinishedTasks.filter { task in
            selectedTasks.contains(task.id!)
        }
        viewModel.startNewPeriod(transferringTasks: tasksToTransfer)
        dismiss()
        onCompletion?()
    }
    
    private func handleSkip() {
        viewModel.startNewPeriod(transferringTasks: [])
        dismiss()
        onCompletion?()
    }
}

private struct TaskRowView: View {
    let task: TodoTaskEntity
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Circle()
                .fill(task.displayColor)
                .frame(width: 20, height: 20)
            
            VStack(alignment: .leading) {
                Text(task.title ?? "")
                    .font(.headline)
                if let dueDate = task.dueDate {
                    Text(dueDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isSelected ? .accentColor : .secondary)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
} 