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
    
    
    // MARK: ---------------- Validation Error -------------------
    
    enum ValidationError: LocalizedError {
        
        case invalidAmount
        case noAccount
        case insufficientBal
        
        var errorDescription: String? {
            switch self {
                
            case .invalidAmount:
                return AppStrings.inValidAmt
                
            case .noAccount:
                return AppStrings.noAccount
                
            case .insufficientBal:
                return AppStrings.insufficientBal
                
            }
        
        }
    }
    
    // MARK: ---------------------- User ------------------------------
    
    // fetch user using phone number
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
            let user = try context.fetch(request).first
            return user
        } catch {
            print("Failed to fetch user:", error.localizedDescription)
            return nil
        }
    }

    // fetch a user by id. Used to restore the persisted auth session.
    func fetchUser(id: UUID) -> UserEntity? {
        
        let request = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            return try context.fetch(request).first
        } catch {
            print("Failed to fetch user by id:", error.localizedDescription)
            return nil
        }
    }
    
    // Create User
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
    
    // Update user details
    // Note: phone is the login identity and is never updated here.
    func updateUser(
        _ user: UserEntity,
        name: String,
        email: String,
        profileImage: Data?
    ) throws {
        
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)

        user.name = trimmedName
        user.email = trimmedEmail
        user.profileImage = profileImage

        try context.save()
    }

    // MARK: ------------------------ Dashboard -------------------------
    
    // fetch all transactions of a user, newest first.
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

    // fetch user's primary account
    func fetchPrimaryAccount(for user: UserEntity) -> AccountEntity? {
        
        let primary = NSFetchRequest<AccountEntity>(entityName: "AccountEntity")
        primary.predicate = NSPredicate(format: "owner == %@ AND isPrimary == YES", user)
        primary.fetchLimit = 1

        do {
            if let account = try context.fetch(primary).first {
                return account
            }
        } catch {
            print("Failed to fetch primary account:", error.localizedDescription)
        }

        let fallback = NSFetchRequest<AccountEntity>(entityName: "AccountEntity")
        fallback.predicate = NSPredicate(format: "owner == %@", user)
        fallback.fetchLimit = 1

        do {
            return try context.fetch(fallback).first
        } catch {
            print("Failed to fetch accounts:", error.localizedDescription)
            return nil
        }
    }

    // fetch all user contacts or transaction contacts, most recent first.
    func fetchContacts(for owner: UserEntity) -> [ContactEntity] {
        
        let request = NSFetchRequest<ContactEntity>(entityName: "ContactEntity")
        request.predicate = NSPredicate(format: "owner == %@", owner)
        request.sortDescriptors = [NSSortDescriptor(key: "lastTransactionAt", ascending: false)]

        do {
            let contacts = try context.fetch(request)
            return contacts
        } catch {
            print("Failed to fetch contacts:", error.localizedDescription)
            return []
        }
    }
    
    

    // MARK: ---------------------- Bank Accounts --------------------------

    // Returns true if the user already has a primary account.
    func hasPrimaryAccount(for user: UserEntity) -> Bool {
        fetchPrimaryAccount(for: user) != nil
    }

    // fetches all linked accounts of a user, newest first.
    func fetchAllAccounts(for user: UserEntity) -> [AccountEntity] {
        
        let request = NSFetchRequest<AccountEntity>(entityName: "AccountEntity")
        request.predicate = NSPredicate(format: "owner == %@", user)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AccountEntity.createdAt, ascending: false)]

        do {
            let accounts = try context.fetch(request)
            return accounts
        } catch {
            print("Failed to fetch accounts:", error.localizedDescription)
            return []
        }
    }

    // fetches a single account by UUID. Returns nil when missing/inaccessible.
    func fetchAccount(id: UUID) -> AccountEntity? {
        
        let request = NSFetchRequest<AccountEntity>(entityName: "AccountEntity")
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)

        do {
            return try context.fetch(request).first
        } catch {
            print("Failed to fetch account by id:", error.localizedDescription)
            return nil
        }
    }
    
    /// Sets the account with `id` as the single primary account for user.
    func setPrimaryAccount(id: UUID, for user: UserEntity) throws {
        
        let accounts = fetchAllAccounts(for: user)
        guard accounts.contains(where: { $0.id == id }) else {
            throw ValidationError.noAccount
        }
        
        for existing in accounts {
            existing.isPrimary = (existing.id == id)
        }
        
        try context.save()
    }

    // Creating an Account.
    func createBankAccount(
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

    // Deletes the bank account.
    func deleteBankAccount(id: UUID, for user: UserEntity) throws {
        
        let accounts = fetchAllAccounts(for: user)
        guard let target = accounts.first(where: { $0.id == id }) else {
            throw ValidationError.noAccount
        }
        
        let wasPrimary = target.isPrimary
        context.delete(target)
        try context.save()

        if wasPrimary {
            let remaining = fetchAllAccounts(for: user)
            if let newest = remaining.first {
                newest.isPrimary = true
                try context.save()
            }
        }
    }

    // MARK: -------------------- Money Transfers / Transactions -----------------------

    // Create transaction if money transfer successfull
    func MoneyTransferSuccess(
        amount: Double,
        from account: AccountEntity,
        recipientName: String
    ) throws {
        
        guard amount > 0 else {
            throw ValidationError.invalidAmount
        }

        let current = (account.balance as NSDecimalNumber?)?.doubleValue ?? 0

        guard amount <= current else {
            throw ValidationError.insufficientBal
        }

        // deducting transfered amount from account balance
        account.balance = NSDecimalNumber(value: current - amount)

        let transaction = TransactionEntity(context: context)
        transaction.id = UUID()
        transaction.title = recipientName
        transaction.category = "Money Transfer"
        transaction.amount = NSDecimalNumber(value: amount)
        transaction.isIncome = false
        transaction.status = "completed"
        transaction.date = Date()
        transaction.owner = account.owner
        transaction.account = account

        try context.save()
    }

}
