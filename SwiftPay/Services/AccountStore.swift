//
//  AccountStore.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 28/09/26.
//

import Foundation
import Combine
import CoreData

/// Single shared source for account + transaction entities.
final class AccountStore: ObservableObject {

    @Published private(set) var accounts: [AccountEntity] = []
    @Published private(set) var transactions: [TransactionEntity] = []

    private let context: NSManagedObjectContext
    private let session: AppSession
    private var cancellables = Set<AnyCancellable>()

    init(context: NSManagedObjectContext, session: AppSession) {
        self.context = context
        self.session = session

        reload()

        // Stay in sync with login/logout without any View involvement.
        session.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reload()
            }
            .store(in: &cancellables)
    }

    /// Re-runs the single shared fetch (accounts + transactions).
    func refresh() {
        reload()
    }

    /// Commits a transfer and refetches once so all observers update.
    func applyTransfer(
        amount: Double,
        from account: AccountEntity,
        recipientName: String
    ) throws {
        try CoreDataService(context: context).TransferSuccess(
            amount: amount,
            from: account,
            recipientName: recipientName
        )
        reload()
    }

    // MARK: - Private

    private func resolvedUser() -> UserEntity? {
        guard let user = session.currentUser else { return nil }
        return try? context.existingObject(with: user.objectID) as? UserEntity
    }

    private func reload() {
        guard let user = resolvedUser() else {
            accounts = []
            transactions = []
            return
        }

        let accountRequest = NSFetchRequest<AccountEntity>(entityName: "AccountEntity")
        accountRequest.predicate = NSPredicate(format: "owner == %@", user)
        accountRequest.sortDescriptors = [NSSortDescriptor(keyPath: \AccountEntity.createdAt, ascending: false)]

        let transactionRequest: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        transactionRequest.predicate = NSPredicate(format: "owner == %@", user)
        transactionRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: false)]

        do {
            accounts = try context.fetch(accountRequest)
            transactions = try context.fetch(transactionRequest)
        } catch {
            print("Failed to reload accounts:", error.localizedDescription)
        }
    }
}
