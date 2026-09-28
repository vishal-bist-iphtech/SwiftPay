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

    private let context: NSManagedObjectContext
    private let session: AppSession
    private var cancellables = Set<AnyCancellable>()

    init(context: NSManagedObjectContext, session: AppSession) {
        self.context = context
        self.session = session

        loadPrimaryAccount()
        loadTransactions()

        // Stay in sync with login/logout without any View involvement.
        session.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadPrimaryAccount()
                self?.loadTransactions()
            }
            .store(in: &cancellables)
    }
    
    func refresh() {
        loadPrimaryAccount()
        loadTransactions()
    }

    // MARK: - Private loading

    private func currentUser(in context: NSManagedObjectContext) -> UserEntity? {
        guard let user = session.currentUser else { return nil }
        
        return try? context.existingObject(with: user.objectID) as? UserEntity
    }

    private func loadPrimaryAccount() {
        guard let user = currentUser(in: context) else {
            hasPrimaryAccount = false
            primaryBalance = 0
            primaryMaskedNumber = "••••• ••••"
            primaryBankName = "No account"
            primaryCurrencyCode = "USD"
            return
        }

        let request = NSFetchRequest<AccountEntity>(entityName: "AccountEntity")
        request.predicate = NSPredicate(format: "owner == %@", user)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AccountEntity.createdAt, ascending: false)]

        do {
            let accounts = try context.fetch(request)
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
        } catch {
            print("Failed to load primary account:", error.localizedDescription)
        }
    }

    private func loadTransactions() {
        guard let user = currentUser(in: context) else {
            transactions = []
            return
        }

        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "owner == %@", user)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: false)]

        do {
            transactions = try context.fetch(request).map { entity in
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
        } catch {
            print("Failed to load transactions:", error.localizedDescription)
        }
    }
}
