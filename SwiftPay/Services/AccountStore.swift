//
//  AccountStore.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 28/09/26.
//

import Foundation
import Combine
import CoreData

/// Single shared source for account + transaction + contact entities.
final class AccountStore: ObservableObject {

    @Published private(set) var accounts: [AccountEntity] = []
    @Published private(set) var transactions: [TransactionEntity] = []
    @Published private(set) var contacts: [ContactEntity] = []

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

    /// Re-runs the single shared fetch (accounts + transactions + contacts).
    func refresh() {
        reload()
    }

    /// Commits a transfer and refetches once so all observers update.
    /// Returns the created transaction entity for details navigation.
    @discardableResult
    func applyMoneyTransfer(
        amount: Double,
        from account: AccountEntity,
        recipientName: String,
        note: String = ""
    ) throws -> TransactionEntity {
        
        guard let user = getUser(),
              let account = CoreDataService(context: context).fetchAccount(id: account.id!),
              account.owner?.id == user.id else {
            throw CoreDataService.ValidationError.noAccount
        }
        let created = try CoreDataService(context: context).moneyTransferSuccess(
            amount: amount,
            from: account,
            recipientName: recipientName,
            note: note
        )
        reload()
        return created
    }


    // MARK: --------------- Bank accounts management ---------------------

    // Marks the account with `id` as primary for the current user, then reloads.
    func setPrimaryAccount(id: UUID) throws {
        
        guard let user = getUser() else { return }
        try CoreDataService(context: context).setPrimaryAccount(id: id, for: user)
        reload()
    }

    // Deletes the bank account
    func deleteBankAccount(id: UUID) throws {
        
        guard let user = getUser() else { return }
        try CoreDataService(context: context).deleteBankAccount(id: id, for: user)
        reload()
    }


    // MARK: - Private

    /// Takes the currentUser id from session manager  and returns the respective UserEntity from coredata in this context.
    private func getUser() -> UserEntity? {
        
        guard let sessionUser = session.currentUser else { return nil }
        
        guard let id = sessionUser.id else { return nil }
        return CoreDataService(context: context).fetchUser(id: id)
    }

    private func reload() {
        
        guard let user = getUser() else {
            accounts = []
            transactions = []
            contacts = []
            return
        }

        let accountRequest = NSFetchRequest<AccountEntity>(entityName: "AccountEntity")
        accountRequest.predicate = NSPredicate(format: "owner == %@", user)
        accountRequest.sortDescriptors = [NSSortDescriptor(keyPath: \AccountEntity.createdAt, ascending: false)]

        let transactionRequest: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        transactionRequest.predicate = NSPredicate(format: "owner == %@", user)
        transactionRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: false)]

        let contactRequest: NSFetchRequest<ContactEntity> = ContactEntity.fetchRequest()
        contactRequest.predicate = NSPredicate(format: "owner == %@", user)
        contactRequest.sortDescriptors = [NSSortDescriptor(keyPath: \ContactEntity.lastTransactionAt, ascending: false)]

        do {
            accounts = try context.fetch(accountRequest)
            transactions = try context.fetch(transactionRequest)
            contacts = try context.fetch(contactRequest)
        } catch {
            print("Failed to reload accounts:", error.localizedDescription)
        }
    }
}
