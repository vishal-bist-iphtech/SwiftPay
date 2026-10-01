//
//  SpendingViewModel.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 24/09/26.
//

import Foundation
import Combine
import CoreData

/// Card data for the Spending carousel.
struct SpendingAccountCard: Identifiable, Hashable {
    let id: String
    let balance: Double
    let currencyCode: String
    let maskedNumber: String

    /// Single balance formatter, provided by the ViewModel.
    var formattedBalance: String {
        AccountFormatting.formattedBalance(balance, currencyCode: currencyCode)
    }
}

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
    var transactions: [MonthlyTransaction]

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
    @Published var totalSpent: Double = 0

    /// Account cards for the carousel.
    @Published var accountCards: [SpendingAccountCard] = []

    private let store: AccountStore
    private var cancellables = Set<AnyCancellable>()

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

    /// Monthly spending total always goes through `AccountFormatting.formattedBalance`.
    var formattedTotalSpent: String {
        AccountFormatting.formattedBalance(totalSpent, currencyCode: "USD")
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

    /// Short month name for the selected month, e.g. "Sep". Used for graph labels.
    var selectedMonthAbbreviation: String {
        let symbols = Calendar.current.shortMonthSymbols
        guard selectedMonth >= 1, selectedMonth <= symbols.count else { return "" }
        return symbols[selectedMonth - 1]
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

    init(store: AccountStore) {
        self.store = store

        let now = Date()
        let cal = Calendar.current
        self.selectedMonth = cal.component(.month, from: now)
        self.selectedYear = cal.component(.year, from: now)

        mapAccounts(store.accounts)
        rebuild(from: store.transactions)

        store.$accounts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.mapAccounts($0) }
            .store(in: &cancellables)

        // Rebuild whenever transactions or the selected month/year change.
        store.$transactions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.rebuild(from: $0) }
            .store(in: &cancellables)

        $selectedMonth
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.rebuild(from: self.store.transactions)
            }
            .store(in: &cancellables)

        $selectedYear
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                self.rebuild(from: self.store.transactions)
            }
            .store(in: &cancellables)
    }

    /// Reloads the account cards for the current session user.
    func refresh() {
        store.refresh()
    }

    // MARK: - Accounts

    private func mapAccounts(_ accounts: [AccountEntity]) {
        accountCards = accounts.map { account in
            let masked: String
            if let stored = account.maskedNumber, !stored.isEmpty {
                masked = stored
            } else if let number = account.accountNumber, !number.isEmpty {
                masked = AccountFormatting.maskedAccountNumber(number)
            } else {
                masked = "••••• ••••"
            }
            return SpendingAccountCard(
                id: (account.id ?? UUID()).uuidString,
                balance: (account.balance as NSDecimalNumber?)?.doubleValue ?? 0,
                currencyCode: account.currencyCode ?? "USD",
                maskedNumber: masked
            )
        }
    }

    /// Rebuilds total, daily groups and categories from expense transactions
    /// of the selected month/year.
    private func rebuild(from entities: [TransactionEntity]) {
        let cal = Calendar.current

        // Expenses only, matching the selected month + year.
        let monthExpenses: [(date: Date, amount: Double, category: String)] = entities.compactMap { entity in
            guard !entity.isIncome else { return nil }
            guard let date = entity.date else { return nil }
            let comps = cal.dateComponents([.year, .month], from: date)
            guard comps.year == selectedYear, comps.month == selectedMonth else { return nil }
            let amount: Double = {
                if let n = entity.amount { return n.doubleValue }
                if let n = entity.amount { return n.doubleValue }
                return 0
            }()
            guard amount > 0 else { return nil }
            let rawCategory = (entity.category ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            let category = rawCategory.isEmpty ? "Others" : rawCategory
            return (date: date, amount: amount, category: category)
        }

        // MARK: Total monthly spending
        totalSpent = monthExpenses.reduce(0) { $0 + $1.amount }

        // MARK: Daily groups — one bar = one transaction, left -> right chronological.
        let maxValue = monthExpenses.map(\.amount).max() ?? 0
        let groupedByDay = Dictionary(grouping: monthExpenses) { entry in
            cal.component(.day, from: entry.date)
        }
        var builtDays = groupedByDay
            .map { day, entries -> DayGroup in
                // Chronological within the day so bars read left -> right in time order.
                let sorted = entries.sorted { $0.date < $1.date }
                let transactions = sorted.enumerated().map { idx, entry in
                    MonthlyTransaction(
                        indexInDay: idx,
                        amount: entry.amount,
                        isMonthMax: false
                    )
                }
                return DayGroup(id: day, day: day, transactions: transactions)
            }
            .sorted { $0.day < $1.day }

        // Highlight only the single earliest max transaction: days are sorted
        // ascending and bars within a day are chronological, so the first max
        // encountered wins ties on amount by date/time.
        if maxValue > 0 {
            dayLoop: for dayIndex in builtDays.indices {
                for txIndex in builtDays[dayIndex].transactions.indices {
                    if builtDays[dayIndex].transactions[txIndex].amount == maxValue {
                        builtDays[dayIndex].transactions[txIndex].isMonthMax = true
                        break dayLoop
                    }
                }
            }
        }
        days = builtDays

        // MARK: Category analytics — grouped case-insensitively, display preserves first casing.
        var firstCasing: [String: String] = [:] // key: lowercased -> display title
        var totals: [String: Double] = [:]
        var counts: [String: Int] = [:]
        for entry in monthExpenses {
            let key = entry.category.lowercased()
            if firstCasing[key] == nil {
                firstCasing[key] = entry.category
            }
            totals[key, default: 0] += entry.amount
            counts[key, default: 0] += 1
        }
        categories = totals.map { key, total in
            let display = firstCasing[key] ?? "Others"
            return TransactionCategory(
                title: display,
                transactionCount: counts[key] ?? 0,
                totalAmount: total,
                icon: Self.icon(for: display)
            )
        }
        .sorted { $0.totalAmount > $1.totalAmount }
    }

    /// SF Symbol per category (matches existing Analytics row style).
    private static func icon(for category: String) -> String {
        switch category.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "food":
            return "fork.knife"
        case "grocery":
            return "cart"
        case "shopping":
            return "cart"
        case "transport", "travel":
            return "bus.fill"
        case "subscription", "subscriptions":
            return "repeat"
        case "bills", "bill", "utilities", "utility":
            return "receipt"
        case "entertainment":
            return "play.rectangle.fill"
        case "health":
            return "cross.fill"
        case "money transfer", "transfer":
            return "arrow.up.right"
        default:
            return "ellipsis"
        }
    }
    
}
