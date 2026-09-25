//
//  SpendingViewModel.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 24/09/26.
//

import Foundation
import Combine

// One bar = one transaction.
struct MonthlyTransaction: Identifiable {
    let id = UUID()
    /// Chronological order within its day, plotted left -> right.
    let indexInDay: Int
    let amount: Double
    // Highest transaction of the month.
    var isMonthMax: Bool = false
}

// One day = one group. Bars inside the group are placed side-by-side.
struct DayGroup: Identifiable {
    let id: Int              // day of month, unique within the month
    let day: Int
    let transactions: [MonthlyTransaction]

    var totalAmount: Double {
        transactions.reduce(0) { $0 + $1.amount }
    }
}

// Grouped transaction row in the Analytics sheet.
struct TransactionCategory: Identifiable {
    let id = UUID()
    let title: String
    let transactionCount: Int
    let totalAmount: Double
    let icon: String
}

enum CategoryPriceFilter: String, CaseIterable, Identifiable {
    case highest
    case lowest

    var id: String { rawValue }

    var title: String {
        switch self {
        case .highest: "Highest"
        case .lowest: "Lowest"
        }
    }
}

final class SpendingViewModel: ObservableObject {

    
    @Published var selectedMonth: Int
    @Published var selectedYear: Int
    @Published var totalSpent: Double = 12_345.67

    /// All transactions for the month, grouped by day, sorted left -> right.
    @Published var days: [DayGroup] = []
    @Published var categories: [TransactionCategory] = []
    @Published var priceFilter: CategoryPriceFilter? = nil

    /// Categories sorted by the active price filter (nil = default order).
    var filteredCategories: [TransactionCategory] {
        guard let filter = priceFilter else { return categories }
        switch filter {
        case .highest:
            return categories.sorted { $0.totalAmount > $1.totalAmount }
        case .lowest:
            return categories.sorted { $0.totalAmount < $1.totalAmount }
        }
    }

    /// Highest transaction of the month.
    var maxAmount: Double {
        days.flatMap(\.transactions).map(\.amount).max() ?? 0
    }

    /// The day containing the month's highest transaction.
    var maxDay: Int? {
        days.first { $0.transactions.contains(where: \.isMonthMax) }?.day
    }

    // MARK: - Month picker (current year only, no future months)

    /// Current calendar month/year — upper bound for selection.
    var currentMonth: Int {
        Calendar.current.component(.month, from: Date())
    }

    var currentYear: Int {
        Calendar.current.component(.year, from: Date())
    }

    /// Displayed in the month picker button, e.g. "Sep, 2026".
    var monthLabel: String {
        let comps = DateComponents(year: selectedYear, month: selectedMonth, day: 1)
        guard let date = Calendar.current.date(from: comps) else { return "" }
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM, yyyy"
        return fmt.string(from: date)
    }

    /// Only months of the current year.
    func isMonthSelectable(_ month: Int) -> Bool {
        month >= 1 && month <= 12 && month <= currentMonth
    }

    /// Selects a month, ignores future months.
    func selectMonth(_ month: Int) {
        guard isMonthSelectable(month) else { return }
        selectedMonth = month
        selectedYear = currentYear
    }

    init() {
        let now = Date()
        let cal = Calendar.current
        self.selectedMonth = cal.component(.month, from: now)
        self.selectedYear = cal.component(.year, from: now)
        loadMock()
    }

    // MARK: - Mock data

    private func loadMock() {
        // (day, amount) — flat, exactly as it would come from a service.
        let raw: [(day: Int, amount: Double)] = [
            (1, 5_620),(2, 3_450), (3, 8_852.65),(3, 4_852.65), (4, 6_890),
            (6, 3_410), (6, 4_210),                       // two transactions on day 6
            (7, 2_980), (7, 5_340),                       // two transactions on day 7
            (8, 3_760), (9, 1_890), (10, 3_540), (11, 1_320),
            (12, 3_980), (13, 2_140), (14, 3_690),
            (15, 1_150), (16, 4_480), (17, 3_760),
            (21, 2_390), (21, 6_560),                     // two transactions on day 21
            (22, 7_520), (23, 3_380), (24, 6_690), (25, 6_290),
            (26, 4_810), (27, 3_440), (28, 2_610), (29, 5_350),
        ]

        // Find the month's max so we can flag it.
        let maxValue = raw.map(\.amount).max() ?? 0

        // Group by day.
        let grouped = Dictionary(grouping: raw, by: \.day)
            .map { day, entries -> DayGroup in
                let transactions = entries.enumerated().map { idx, entry in
                    MonthlyTransaction(
                        indexInDay: idx,
                        amount: entry.amount,
                        isMonthMax: entry.amount == maxValue
                    )
                }
                return DayGroup(id: day, day: day, transactions: transactions)
            }
            .sorted { $0.day < $1.day }

        self.days = grouped

        self.categories = [
            
            TransactionCategory(
                title: "Food",
                transactionCount: 75,
                totalAmount: 4_442.85,
                icon: "fork.knife"
            ),
            TransactionCategory(
                title: "Transport",
                transactionCount: 55,
                totalAmount: 1_650.00,
                icon: "bus.fill"
            ),
            TransactionCategory(
                title: "Subscriptions",
                transactionCount: 2,
                totalAmount: 860.00,
                icon: "repeat"
            ),
            TransactionCategory(
                title: "Bills",
                transactionCount: 4,
                totalAmount: 1_860.00, icon: "receipt"
            ),
            TransactionCategory(
                title: "Shopping",
                transactionCount: 6,
                totalAmount: 3_860.00, icon: "cart"
            ),
            TransactionCategory(
                title: "Others",
                transactionCount: 6,
                totalAmount: 1_360.00, icon: "ellipsis"
            ),

        ]
    }
    
}
