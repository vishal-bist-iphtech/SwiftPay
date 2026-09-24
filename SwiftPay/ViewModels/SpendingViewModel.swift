//
//  SpendingViewModel.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 24/09/26.
//

import Foundation
import Combine

// One bar = one spending transaction.
struct SpendingPoint: Identifiable {
    let id = UUID()
    /// Chronological order, plotted left -> right.
    let index: Int
    /// Day of month (1...30).
    let day: Int
    let amount: Double
    /// X position in the chart.
    var plotIndex: Int = 0
    // Highest transaction of the month.
    var isMonthMax: Bool = false
}

// One grouped row in the Analytics sheet.
struct SpendingCategory: Identifiable {
    let id = UUID()
    let title: String
    let transactionCount: Int
    let total: Double
    
    let icon: String
}

final class SpendingViewModel: ObservableObject {

    @Published var monthLabel: String = "Sep, 2026"
    @Published var totalSpent: Double = 12_345.67

    // All September transactions, chronological. Each element = one bar.
    @Published var points: [SpendingPoint] = []
    @Published var categories: [SpendingCategory] = []

    /// Highest transaction of the month (orange highlighted bar).
    var maxAmount: Double {
        points.map(\.amount).max() ?? 0
    }

    /// Rightmost x position, for the chart's x domain.
    var maxPlotIndex: Int {
        points.map(\.plotIndex).max() ?? 0
    }

    /// Plot range of each week group, recorded while laying out `points`.
    private var weekPlotRanges: [(label: String, start: Int, end: Int)] = []

    /// X positions (bar indices) where the week labels sit, centred under each week group.
    var weekLabelAnchors: [(label: String, index: Int)] {
        weekPlotRanges.map { ($0.label, ($0.start + $0.end) / 2) }
    }

    init() {
        loadMock()
    }

    // MARK: - Mock data

    private func loadMock() {
        // (day, amount) per week. Week 1 holds 9 transactions incl. the month max
        let weeks: [[(day: Int, amount: Double)]] = [
            [
                (1, 5_620), (2, 3_450), (3, 8_852.65), (4, 6_890), (5, 4_730),
                (6, 3_410), (6, 4_210), (7, 2_980), (7, 5_340),
            ],
            [
                (8, 3_760), (9, 1_890), (10, 3_540), (11, 1_320),
                (12, 3_980), (13, 2_140), (14, 3_690),
            ],
            [
                (15, 1_150), (16, 4_480), (17, 3_760), (18, 3_830),
                (19, 2_480), (20, 5_720), (21, 2_390), (21, 6_560),
            ],
            [
                (22, 7_520), (23, 3_380), (24, 6_690), (25, 6_290),
                (26, 4_810), (27, 3_440), (28, 2_610), (29, 5_350),
            ],
        ]

        // Lay out plot positions with an empty gap between week groups.
        let gap = 2
        var all: [SpendingPoint] = []
        var plot = 0
        for (group, week) in weeks.enumerated() {
            if group > 0 { plot += gap }
            for entry in week {
                all.append(SpendingPoint(
                    index: all.count,
                    day: entry.day,
                    amount: entry.amount,
                    plotIndex: plot
                ))
                plot += 1
            }
        }
        if let maxIndex = all.indices.max(by: { all[$0].amount < all[$1].amount }) {
            all[maxIndex].isMonthMax = true
        }
        self.points = all

        self.categories = [
            SpendingCategory(title: "Foodstuff", transactionCount: 155, total: 2_442.85, icon: "fork.knife"),
            SpendingCategory(title: "Transport", transactionCount: 55, total: 1_650.00, icon: "bus.fill"),
            SpendingCategory(title: "Subscriptions", transactionCount: 42, total: 860.00, icon: "repeat"),
        ]
    }
}
