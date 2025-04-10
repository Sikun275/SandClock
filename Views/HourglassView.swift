//
//  HourglassView.swift
//  SandClock
//
//  Created by Sikun Chen on 2025-03-22.
//

import SwiftUI

struct HourglassView: View {
    @ObservedObject var viewModel: TaskViewModel
    @ObservedObject var clockStorage: ClockStorage
    @State private var isEditingName = false
    @State private var tempName = ""
    @State private var fallingBeads: Set<UUID> = []
    
    let hourglassWidth: CGFloat = 200
    
    var body: some View {
        VStack {
            ZStack {
                // Smooth hourglass shape
                SmoothHourglassShape()
                    .stroke(Color.gray, lineWidth: 2)
                    .frame(width: hourglassWidth, height: hourglassWidth * 2)
                
                // Top beads: pending tasks
                ForEach(viewModel.pendingTasks) { task in
                    Circle()
                        .fill(task.displayColor)
                        .frame(width: task.beadSize, height: task.beadSize)
                        .position(task.topPosition(in: hourglassWidth))
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .offset(y: -50)),
                            removal: .opacity.combined(with: .offset(y: hourglassWidth))
                        ))
                        .animation(.spring(dampingFraction: 0.7), value: viewModel.pendingTasks.count)
                }
                
                // Falling beads animation
                ForEach(viewModel.completedTasks.filter { fallingBeads.contains($0.id!) }) { task in
                    Circle()
                        .fill(task.displayColor)
                        .frame(width: task.beadSize, height: task.beadSize)
                        .position(task.topPosition(in: hourglassWidth))
                        .transition(.move(edge: .top))
                        .animation(
                            .spring(
                                response: 0.6,
                                dampingFraction: 0.7,
                                blendDuration: 0.6
                            ),
                            value: fallingBeads
                        )
                }
                
                // Bottom beads: completed and overdue
                ForEach(viewModel.completedTasks + viewModel.overdueTasks) { task in
                    if !fallingBeads.contains(task.id!) {
                        Circle()
                            .fill(task.displayColor)
                            .frame(width: task.beadSize, height: task.beadSize)
                            .position(task.bottomPosition(in: hourglassWidth))
                            .transition(.asymmetric(
                                insertion: .scale.combined(with: .offset(y: -hourglassWidth)),
                                removal: .opacity
                            ))
                            .animation(.spring(dampingFraction: 0.7), value: viewModel.completedTasks.count + viewModel.overdueTasks.count)
                    }
                }
            }
            .frame(width: hourglassWidth, height: hourglassWidth * 2)
            .padding()
            .onChange(of: viewModel.completedTasks) { newValue in
                handleCompletedTasksChange(newValue)
            }
            
            // Clock name
            if isEditingName {
                TextField("Clock Name", text: $tempName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 200)
                    .multilineTextAlignment(.center)
                    .onSubmit {
                        if !tempName.isEmpty {
                            clockStorage.updateCurrentClock(name: tempName)
                        }
                        isEditingName = false
                    }
            } else {
                Text(clockStorage.currentClock.name)
                    .font(.headline)
                    .onTapGesture {
                        tempName = clockStorage.currentClock.name
                        isEditingName = true
                    }
            }
            
            // Period info
            Text(clockStorage.currentClock.startDate...clockStorage.currentClock.endDate, format: .dateInterval)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func handleCompletedTasksChange(_ newTasks: [TodoTaskEntity]) {
        let newlyCompleted = Set(newTasks.map { $0.id! })
            .subtracting(fallingBeads)
        
        for id in newlyCompleted {
            fallingBeads.insert(id)
            // Remove from falling beads after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                fallingBeads.remove(id)
            }
        }
    }
}

// MARK: - Smooth Hourglass Shape
struct SmoothHourglassShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let midX = rect.midX
        let neckWidth = Theme.Hourglass.neckWidth
        let controlPointOffset = width * 0.2
        
        // Top bowl
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addCurve(
            to: CGPoint(x: midX + neckWidth/2, y: height * 0.4),
            control1: CGPoint(x: rect.maxX - controlPointOffset, y: height * 0.15),
            control2: CGPoint(x: midX + neckWidth/2 + controlPointOffset, y: height * 0.3)
        )
        
        // Right side of neck
        path.addLine(to: CGPoint(x: midX + neckWidth/2, y: height * 0.6))
        
        // Bottom bowl (right side)
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: height),
            control1: CGPoint(x: midX + neckWidth/2 + controlPointOffset, y: height * 0.7),
            control2: CGPoint(x: rect.maxX - controlPointOffset, y: height * 0.85)
        )
        
        // Bottom line
        path.addLine(to: CGPoint(x: rect.minX, y: height))
        
        // Bottom bowl (left side)
        path.addCurve(
            to: CGPoint(x: midX - neckWidth/2, y: height * 0.6),
            control1: CGPoint(x: controlPointOffset, y: height * 0.85),
            control2: CGPoint(x: midX - neckWidth/2 - controlPointOffset, y: height * 0.7)
        )
        
        // Left side of neck
        path.addLine(to: CGPoint(x: midX - neckWidth/2, y: height * 0.4))
        
        // Complete the shape
        path.addCurve(
            to: CGPoint(x: rect.minX, y: rect.minY),
            control1: CGPoint(x: midX - neckWidth/2 - controlPointOffset, y: height * 0.3),
            control2: CGPoint(x: controlPointOffset, y: height * 0.15)
        )
        
        return path
    }
}
