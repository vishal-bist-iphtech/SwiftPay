//
//  TransactionViewModel.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 30/09/26.
//

import Foundation
import Combine
import CoreData
import SwiftUI

/// One day group for the Transactions screen.
struct TransactionDaySection: Identifiable {
    let id: String   // yyyy-MM-dd
    let title: String
    let total: Double   // (income - expenses)
    let transactions: [Transaction]
}

final class TransactionViewModel: ObservableObject {

    // MARK: - Published State
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var entities: [TransactionEntity] = []
    @Published var searchText: String = ""
    @Published var selectedCategory: String? = nil
    @Published var errorMessage: String?
    @Published var isSaving: Bool = false


    private let coredata = CoreDataService.shared
    private let session: AppSession
    private let store: AccountStore?
    private var cancellables = Set<AnyCancellable>()

    init(
        session: AppSession,
        store: AccountStore? = nil
    ) {
        self.session = session
        self.store = store

        load()

        session.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.load() }
            .store(in: &cancellables)
    }

    // MARK: - Month header

    var monthTitle: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMMM"
        return "\(fmt.string(from: Date()).uppercased()) SPENDING"
    }

    /// Total spendings (expenses only) in the current month.
    var monthlySpending: Double {
        let cal = Calendar.current
        let now = Date()
        return transactions
            .filter {
                !$0.isIncome &&
                cal.isDate($0.date, equalTo: now, toGranularity: .month) &&
                cal.isDate($0.date, equalTo: now, toGranularity: .year)
            }
            .reduce(0) { $0 + $1.amount }
    }

    var monthlySpendingText: String {
        AccountFormatting.formattedBalance(monthlySpending, currencyCode: "USD")
    }

    /// Unique categories for the filter sheet, sorted.
    var availableCategories: [String] {
        Array(Set(transactions.map { $0.category })).sorted()
    }

    // MARK: - filtering + grouping

    var filteredTransactions: [Transaction] {
        var result = transactions
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            result = result.filter {
                $0.title.lowercased().contains(query) ||
                $0.category.lowercased().contains(query)
            }
        }
        if let cat = selectedCategory, !cat.isEmpty {
            result = result.filter { $0.category == cat }
        }
        return result
    }

    /// Groups filtered transactions by day, newest first.
    var groupedSections: [TransactionDaySection] {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: filteredTransactions) { tx in
            cal.startOfDay(for: tx.date)
        }
        let sortedDays = grouped.keys.sorted(by: >)
        return sortedDays.map { day in
            
            let items = (grouped[day] ?? []).sorted { $0.date > $1.date }

            let total = items.reduce(0) { $0 + ($1.isIncome ? $1.amount : -$1.amount) }
            
            return TransactionDaySection(
                id: Self.dayID(day),
                title: Self.sectionTitle(for: day),
                total: total,
                transactions: items
            )
        }
    }

    var hasTransactions: Bool { !transactions.isEmpty }
    var hasFilteredResults: Bool { !filteredTransactions.isEmpty }

    // MARK: - Fetch

    /// Re-fetches from Core Data
    func load() {
        errorMessage = nil
        guard let user = currentUser() else {
            transactions = []
            entities = []
            return
        }
        let fetched = coredata.fetchTransactions(for: user)
        entities = fetched
        transactions = fetched.map { Self.map($0) }
    }

    func refresh() {
        load()
    }

    /// Entity for a UI transaction (needed for update/delete sheets).
    func entity(for transaction: Transaction) -> TransactionEntity? {
        entities.first { ($0.id ?? UUID()) == transaction.id }
    }

    // MARK: - Create

    func addTransaction(
        title: String,
        category: String,
        amount: Double,
        isIncome: Bool,
        date: Date = Date(),
        note: String = "",
        paidTo: String = "",
        paidWith: String = ""
    ) -> Bool {
        errorMessage = nil
        guard let user = currentUser() else {
            errorMessage = AppStrings.notLoggedIn
            return false
        }
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCategory = category.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            errorMessage = "Please enter a title"
            return false
        }
        guard !trimmedCategory.isEmpty else {
            errorMessage = "Please select a category"
            return false
        }
        guard amount > 0 else {
            errorMessage = AppStrings.inValidAmt
            return false
        }

        isSaving = true
        defer { isSaving = false }
        do {
            try coredata.addTransaction(
                title: trimmedTitle,
                category: trimmedCategory,
                amount: amount,
                isIncome: isIncome,
                date: date,
                owner: user,
                note: note,
                paidTo: paidTo,
                paidWith: paidWith
            )
            load()
            store?.refresh()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Update

    func updateTransaction(
        _ transaction: Transaction,
        title: String,
        category: String,
        amount: Double,
        isIncome: Bool,
        date: Date,
        note: String = "",
        paidTo: String = "",
        paidWith: String = ""
    ) -> Bool {
        errorMessage = nil
        guard let target = entity(for: transaction) else {
            errorMessage = "Transaction not found"
            return false
        }
        return updateEntity(
            target,
            title: title,
            category: category,
            amount: amount,
            isIncome: isIncome,
            date: date,
            note: note,
            paidTo: paidTo,
                paidWith: paidWith
        )
    }

    func updateEntity(
        _ entity: TransactionEntity,
        title: String,
        category: String,
        amount: Double,
        isIncome: Bool,
        date: Date,
        note: String = "",
        paidTo: String = "",
        paidWith: String = ""
    ) -> Bool {
        errorMessage = nil
        isSaving = true
        defer { isSaving = false }
        do {
            try coredata.updateTransaction(
                entity,
                title: title,
                category: category,
                amount: amount,
                isIncome: isIncome,
                date: date,
                note: note,
                paidTo: paidTo,
                paidWith: paidWith
            )
            load()
            store?.refresh()
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Delete

    func deleteTransaction(_ transaction: Transaction) {
        guard let target = entity(for: transaction) else { return }
        deleteEntity(target)
    }

    func deleteEntity(_ entity: TransactionEntity) {
        errorMessage = nil
        coredata.deleteTransaction(entity)
        load()
        store?.refresh()
    }

    /// Paid-with label
    func paidWithText(for transaction: Transaction) -> String {
        if !transaction.paidWith.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return transaction.paidWith }
        guard let entity = entity(for: transaction),
              let account = entity.account else { return "—" }
        let bank = (account.bankName?.isEmpty == false) ? account.bankName! : "Account"
        let masked = account.maskedNumber ?? ""
        let last4 = masked.filter(\.isNumber).suffix(4)
        if last4.isEmpty { return bank }
        return "\(bank) · \(last4)"
    }

    /// Saved contacts for the Paid-To suggestions, most recent first.
    func contactSuggestions() -> [Contact] {
        guard let user = currentUser() else { return [] }
        return coredata.fetchContacts(for: user).map(Contact.init(entity:))
    }

    /// Bank account suggestions for the Paid-With field
    func accountSuggestions() -> [String] {        guard let store else { return [] }
        return store.accounts.compactMap { account in
            let bank = (account.bankName?.isEmpty == false) ? account.bankName! : nil
            let masked = account.maskedNumber ?? ""
            let last4 = String(masked.filter(\.isNumber).suffix(4))
            if let bank, !last4.isEmpty { return "\(bank) · \(last4)" }
            return bank
        }
    }

    /// Full date string for details
    func dateTimeText(for transaction: Transaction) -> String {
        let d = transaction.date.formatted(date: .long, time: .omitted)
        let tm = transaction.date.formatted(date: .omitted, time: .shortened)
        return "\(d) · \(tm)"
    }

    func delete(at offsets: IndexSet, in section: TransactionDaySection) {
        for index in offsets {
            guard section.transactions.indices.contains(index) else { continue }
            deleteTransaction(section.transactions[index])
        }
    }

    // MARK: - Filter helpers

    func clearFilters() {
        searchText = ""
        selectedCategory = nil
    }

    // MARK: - Private

    /// Resolves the session user in this VM's context
    private func currentUser() -> UserEntity? {
        guard let sessionUser = session.currentUser,
              let id = sessionUser.id else { return nil }
        return coredata.fetchUser(id: id)
    }

    // MARK: - Mapping (Core Data -> UI)

    static func map(_ entity: TransactionEntity) -> Transaction {
        let title = entity.title ?? ""
        let category = (entity.category?.isEmpty == false) ? entity.category! : "Others"
        let isIncome = entity.isIncome
        let amount: Double = {
            if let n = entity.amount { return n.doubleValue }
            if let n = entity.amount { return n.doubleValue }
            return 0
        }()
        return Transaction(
            id: entity.id ?? UUID(),
            title: title,
            category: category,
            amount: amount,
            isIncome: isIncome,
            date: entity.date ?? Date(),
            status: (entity.status?.isEmpty == false) ? entity.status! : "Completed",
            note: entity.note ?? "",
            paidTo: entity.paidTo ?? "",
            paidWith: entity.paidWith ?? ""
        )
    }

    /// SF Symbol per category
    static func icon(for category: String, isIncome: Bool) -> String {
        if isIncome { return "building.2.fill" }
        switch category.lowercased() {
            
        case "food":
            return "fork.knife.circle.fill"
            
        case "grocery":
            return "carrot.fill"
            
        case  "shopping":
            return "bag.fill"
            
        case "subscription":
            return "music.note"
            
        case "income":
            return "building.2.fill"
            
        case "transport":
            return "car.fill"
            
        case "entertainment":
            return "play.rectangle.fill"
            
        case "bills":
            return "receipt.fill"
            
        case "money transfer":
            return "arrow.up.right"
            
        default:
            return "fork.knife"
        }
    }

    /// icon color per category
    static func iconColor(for category: String, isIncome: Bool) -> Color {
        
        if isIncome { return Color.blue }
        
        switch category.lowercased() {
            
        case "food":
            return Color(red: 0.85, green: 0.35, blue: 0.15) // burnt orange
            
        case "grocery", "shopping":
            return Color(red: 0.2, green: 0.55, blue: 0.35) // green
            
        case "subscription":
            return Color(red: 0.6, green: 0.35, blue: 0.75) // purple
            
        case "transport":
            return Color(red: 0.75, green: 0.25, blue: 0.2) // red
            
        case "income":
            return Color(red: 0.25, green: 0.5, blue: 0.85) // blue
            
        case "bills":
            return Color.gray
            
        case "entertainment":
            return Color.pink
            
        default:
            return Color.orange
        }
    }

    // MARK: - Section titles

    private static func dayID(_ day: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: day)
    }

    static func sectionTitle(for day: Date) -> String {
        let cal = Calendar.current
        let dayFmt = DateFormatter()
        dayFmt.dateFormat = "MMMM d"
        let dayString = dayFmt.string(from: day)
        if cal.isDateInToday(day) {
            return "Today · \(dayString)"
        } else if cal.isDateInYesterday(day) {
            return "Yesterday · \(dayString)"
        } else {
            let full = DateFormatter()
            full.dateFormat = "MMMM d"
            return full.string(from: day)
        }
    }
}

// MARK: - Formatters used by the view

enum TransactionFormat {
    static func amountText(_ tx: Transaction) -> String {
        let formatted = AccountFormatting.formattedBalance(tx.amount, currencyCode: "USD")
        return tx.isIncome ? "+\(formatted)" : "-\(formatted)"
    }

    static func sectionTotalText(_ total: Double) -> String {
        let abs = AccountFormatting.formattedBalance(abs(total), currencyCode: "USD")
        if total > 0 { return "+\(abs)" }
        if total < 0 { return "-\(abs)" }
        return abs
    }

    static func subtitle(_ tx: Transaction) -> String {
        let time = tx.date.formatted(date: .omitted, time: .shortened)
        return "\(tx.category) · \(time)"
    }
}
