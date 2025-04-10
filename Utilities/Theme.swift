//
//  Theme.swift
//  SandClock
//
//  Created by Sikun Chen on 2025-03-22.
//
import SwiftUI

struct Theme {
    // System Colors
    static let background = Color(UIColor.systemBackground)
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    static let accent = Color.blue
    
    // Task Status Colors
    static let overdueColor = Color.gray
    
    // Available Colors for Task Types
    static let availableColors: [(name: String, color: Color)] = [
        ("Red", .red),
        ("Orange", .orange),
        ("Yellow", .yellow),
        ("Green", .green),
        ("Blue", .blue),
        ("Purple", .purple),
        ("Pink", .pink),
        ("Teal", .teal),
        ("Indigo", .indigo),
        ("Mint", .mint)
    ]
    
    // Hourglass Constants
    struct Hourglass {
        static let neckWidth: CGFloat = 80 // Width to fit ~8 beads
        static let prioritySizes: [Int: CGFloat] = [
            1: 20, // 25% of neck width
            2: 17.6, // 22% of neck width
            3: 15.2, // 19% of neck width
            4: 12.8  // 16% of neck width
        ]
    }
    
    // Clock Period
    struct Clock {
        static let defaultPeriod: TimeInterval = 7 * 24 * 60 * 60 // 1 week in seconds
    }
}
