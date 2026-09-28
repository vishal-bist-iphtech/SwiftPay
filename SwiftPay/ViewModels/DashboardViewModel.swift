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

    // MARK: - Primary account

    @Published var primaryBalance: Double = 0
    @Published var primaryMaskedNumber = "••••• ••••"
    @Published var primaryBankName = "No account"
    @Published var primaryCurrencyCode = "USD"
    @Published var hasPrimaryAccount = false

    // MARK: - Transactions

    @Published var transactions: [Transaction] = []

    private let store: AccountStore
    private var cancellables = Set<AnyCancellable>()

    init(store: AccountStore) {
        self.store = store

        mapAccounts(store.accounts)
        mapTransactions(store.transactions)

        store.$accounts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.mapAccounts($0) }
            .store(in: &cancellables)

        store.$transactions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.mapTransactions($0) }
            .store(in: &cancellables)
    }

    func refresh() {
        store.refresh()
    }

    // MARK: - Private mapping

    // mapping primary account from account entity
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
                icon: entity.isIncome ? "arrow.down.left" : "arrow.up.right",
                isIncome: entity.isIncome,
                date: entity.date ?? Date()
            )
        }
    }
}
