import SwiftUI

struct ShelfView: View {
    @ObservedObject var clockStorage: ClockStorage
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 20)
            ], spacing: 20) {
                ForEach(clockStorage.clocks.sorted(by: { $0.endDate > $1.endDate })) { clock in
                    ClockPreviewView(clock: clock)
                }
            }
            .padding()
        }
        .navigationTitle("Clock Shelf")
    }
}

struct ClockPreviewView: View {
    let clock: Clock
    
    var body: some View {
        VStack {
            ZStack {
                // Hourglass shape as background
                Image(systemName: "hourglass")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary)
                    .opacity(0.3)
                
                VStack(spacing: 8) {
                    Text(clock.name)
                        .font(.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                    
                    Text("\(Int(clock.completionRate * 100))%")
                        .font(.title2)
                        .bold()
                        .foregroundColor(completionColor)
                    
                    Text("\(clock.completedTasks)/\(clock.totalTasks) Tasks")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(clock.startDate...clock.endDate, format: .dateInterval)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
        .frame(height: 200)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private var completionColor: Color {
        switch clock.completionRate {
        case 0.8...1.0: return .green
        case 0.5..<0.8: return .yellow
        default: return .red
        }
    }
} 