//
//  CoreDataService.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 18/09/26.
//

import CoreData

final class CoreDataService {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: Fetch User
    func fetchUser(phone: String) -> UserEntity? {
        
        let request = NSFetchRequest<UserEntity>(
            entityName: "UserEntity"
        )
        
        request.fetchLimit = 1
        
        request.predicate = NSPredicate(
            format: "phone == %@",
            phone
        )
        
        do {
            // return the first user
            return try context.fetch(request).first
        } catch {
            print("Failed to fetch user:", error.localizedDescription)
            return nil
        }
    }
    
    
    // MARK: Create User
    func createUser(
        phone: String,
        name: String,
        email: String
    ) throws -> UserEntity {

        let user = UserEntity(context: context)

        user.id = UUID()
        user.phone = phone
        user.name = name
        user.email = email
        user.createdAt = Date()

        try context.save()

        return user
    }

    // MARK: - Accounts

    /// Returns true if the user already has a primary account.
    func hasPrimaryAccount(for user: UserEntity) -> Bool {
        fetchPrimaryAccount(for: user) != nil
    }

    /// Fetches the user's primary account, if any.
    func fetchPrimaryAccount(for user: UserEntity) -> AccountEntity? {
        let request = NSFetchRequest<AccountEntity>(entityName: "AccountEntity")
        request.fetchLimit = 1
        request.predicate = NSPredicate(
            format: "owner == %@ AND isPrimary == YES",
            user
        )

        do {
            return try context.fetch(request).first
        } catch {
            print("Failed to fetch primary account:", error.localizedDescription)
            return nil
        }
    }

    /// Fetches all accounts for a user, newest first.
    func fetchAccounts(for user: UserEntity) -> [AccountEntity] {
        let request = NSFetchRequest<AccountEntity>(entityName: "AccountEntity")
        request.predicate = NSPredicate(format: "owner == %@", user)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AccountEntity.createdAt, ascending: false)]

        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch accounts:", error.localizedDescription)
            return []
        }
    }

    // Creating an Account.
    func createAccount(
        for owner: UserEntity,
        accountNumber: String,
        bankName: String,
        accountType: String = "Saving",
        balance: NSDecimalNumber = NSDecimalNumber(value: 6000),
        currencyCode: String = "USD"
    ) throws -> AccountEntity {
        let isPrimary = !hasPrimaryAccount(for: owner)

        let account = AccountEntity(context: context)
        account.id = UUID()
        account.accountNumber = accountNumber
        account.bankName = bankName
        account.accountType = accountType
        account.balance = balance
        account.currencyCode = currencyCode
        account.isPrimary = isPrimary
        account.maskedNumber = AccountFormatting.maskedAccountNumber(accountNumber)
        account.createdAt = Date()
        account.owner = owner

        try context.save()

        return account
    }

    // MARK: - Transfers

    enum TransferFailure: LocalizedError {
        case insufficientFunds(available: Double)
        case invalidAmount

        var errorDescription: String? {
            switch self {
            case .insufficientFunds(let available):
                return "Insufficient balance. Available: \(AccountFormatting.formattedBalance(available))"
            case .invalidAmount:
                return "Enter a valid transfer amount."
            }
        }
    }


    // transfer successfull
    func TransferSuccess(
        amount: Double,
        from account: AccountEntity,
        recipientName: String
    ) throws {
        guard amount > 0 else {
            throw TransferFailure.invalidAmount
        }

        let current = (account.balance as NSDecimalNumber?)?.doubleValue ?? 0

        guard amount <= current else {
            throw TransferFailure.insufficientFunds(available: current)
        }

        account.balance = NSDecimalNumber(value: current - amount)

        let record = TransactionEntity(context: context)
        record.id = UUID()
        record.title = recipientName
        record.category = "Transfer"
        record.amount = NSDecimalNumber(value: amount)
        record.isIncome = false
        record.status = "completed"
        record.date = Date()
        record.owner = account.owner
        record.account = account

        try context.save()
    }

    /// All transactions for a user, newest first.
    func fetchTransactions(for user: UserEntity) -> [TransactionEntity] {
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        request.predicate = NSPredicate(format: "owner == %@", user)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionEntity.date, ascending: false)]

        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch transactions:", error.localizedDescription)
            return []
        }
    }
}
