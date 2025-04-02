//
//  HourglassView.swift
//  SandClock
//
//  Created by Sikun Chen on 2025-03-22.
//

import SwiftUI

struct HourglassView: View {
    var viewModel: TaskViewModel

    let hourglassWidth: CGFloat = 200
    let beadSize: CGFloat = 20

    var body: some View {
        ZStack {
            HourglassShape()
                .stroke(Color.gray, lineWidth: 2)
                .frame(width: hourglassWidth, height: hourglassWidth * 2)

            // Top beads: pending tasks
            ForEach(viewModel.pendingTasks, id: \ .id) { task in
                BeadView(color: task.beadColor)
                    .frame(width: beadSize, height: beadSize)
                    .position(task.topPosition(in: hourglassWidth))
                    .transition(.scale)
                    .animation(.spring(), value: viewModel.tasks.count)
            }

            // Bottom beads: completed/overdue
            ForEach(viewModel.completedTasks, id: \ .id) { task in
                BeadView(color: task.beadColor)
                    .frame(width: beadSize, height: beadSize)
                    .position(task.bottomPosition(in: hourglassWidth))
            }
        }
        .frame(width: hourglassWidth, height: hourglassWidth * 2)
        .padding()
        .overlay(
            Text("Clock #1")
                .font(.headline)
                .padding(.top, hourglassWidth * 2 + 10),
            alignment: .top
        )
    }
}

// MARK: - Bead View
struct BeadView: View {
    let color: Color

    var body: some View {
        Circle()
            .fill(color)
            .shadow(radius: 2)
    }
}

// MARK: - Hourglass Shape
struct HourglassShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midX = rect.midX
        let topY = rect.minY
        let bottomY = rect.maxY

        path.move(to: CGPoint(x: rect.minX, y: topY))
        path.addLine(to: CGPoint(x: rect.maxX, y: topY))
        path.addLine(to: CGPoint(x: midX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: bottomY))
        path.addLine(to: CGPoint(x: rect.minX, y: bottomY))
        path.addLine(to: CGPoint(x: midX, y: rect.midY))
        path.closeSubpath()

        return path
    }
}
