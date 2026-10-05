//
//  DashboardViewModel.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 21/09/26.
//

import Foundation
import Combine
import CoreData


final class DashboardViewModel: ObservableObject {

    private let store: AccountStore
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: - Primary account
    @Published var primaryBalance: Double = 0
    @Published var primaryMaskedNumber = "••••• ••••"
    @Published var primaryBankName = "No account"
    @Published var primaryCurrencyCode = "USD"
    @Published var hasPrimaryAccount = false
    @Published var contacts: [Contact] = []
    @Published var transactions: [Transaction] = []


    init(store: AccountStore) {
        self.store = store

        mapAccounts(store.accounts)
        mapTransactions(store.transactions)
        mapContacts(store.contacts)

        store.$accounts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.mapAccounts($0) }
            .store(in: &cancellables)

        store.$transactions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.mapTransactions($0) }
            .store(in: &cancellables)

        store.$contacts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.mapContacts($0) }
            .store(in: &cancellables)
    }
    
    
    // MARK: - Computed
    var hasTransactions: Bool { !transactions.isEmpty }
    var hasContacts: Bool { !contacts.isEmpty }

    /// Single balance formatter, provided by the ViewModel.
    /// All card balances across the app go through `AccountFormatting.formattedBalance`.
    var primaryBalanceText: String {
        AccountFormatting.formattedBalance(primaryBalance, currencyCode: primaryCurrencyCode)
    }

    /// Recent 5 transactions for the dashboard
    var recentTransactions: [Transaction] { Array(transactions.prefix(5)) }
    
    
    let Banks = [
        "JPMorgan Chase",
        "Bank of America",
        "Wells Fargo",
        "Citibank"
    ]
    let CardNetworks = [
        "Visa",
        "Mastercard",
        "RuPay"
    ]


    func refresh() {
        store.refresh()
    }

    // MARK: --------------------- Private mapping ----------------------------

    /// Maps the primary account from an account entity list.
    private func mapAccounts(_ accounts: [AccountEntity]) {
        guard let account = accounts.first(where: { $0.isPrimary }) ?? accounts.first else {
            hasPrimaryAccount = false
            primaryBalance = 0
            primaryMaskedNumber = "••••• ••••"
            primaryBankName = "No account"
            primaryCurrencyCode = "USD"
            return
        }

        hasPrimaryAccount = true
        primaryBalance = (account.balance as NSDecimalNumber?)?.doubleValue ?? 0
        primaryCurrencyCode = account.currencyCode ?? "USD"
        primaryBankName = account.bankName ?? "No account"

        if let masked = account.maskedNumber, !masked.isEmpty {
            primaryMaskedNumber = masked
        } else if let number = account.accountNumber, !number.isEmpty {
            primaryMaskedNumber = AccountFormatting.maskedAccountNumber(number)
        } else {
            primaryMaskedNumber = "••••• ••••"
        }
    }

    private func mapTransactions(_ entities: [TransactionEntity]) {
        transactions = entities.map { entity in
            Transaction(
                id: entity.id ?? UUID(),
                title: entity.title ?? "",
                category: entity.category ?? "Transfer",
                amount: (entity.amount as NSDecimalNumber?)?.doubleValue ?? 0,
                isIncome: entity.isIncome,
                date: entity.date ?? Date()
            )
        }
    }

    /// Maps saved contacts (most recent first) for Quick Transfer.
    private func mapContacts(_ entities: [ContactEntity]) {
        contacts = entities.map(Contact.init(entity:))
    }
}
