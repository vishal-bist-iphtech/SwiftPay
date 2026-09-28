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

    /// Fetch a user by id. Used to restore the persisted auth session.
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

    // MARK: - Dashboard

    func fetchTransactions(for owner: UserEntity) -> [TransactionEntity] {
        let request = NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
        request.predicate = NSPredicate(format: "owner == %@", owner)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch transactions:", error.localizedDescription)
            return []
        }
    }

    func fetchPrimaryAccount(for owner: UserEntity) -> AccountEntity? {
        let primary = NSFetchRequest<AccountEntity>(entityName: "AccountEntity")
        primary.predicate = NSPredicate(format: "owner == %@ AND isPrimary == YES", owner)
        primary.fetchLimit = 1

        do {
            if let account = try context.fetch(primary).first {
                return account
            }
        } catch {
            print("Failed to fetch primary account:", error.localizedDescription)
        }

        let fallback = NSFetchRequest<AccountEntity>(entityName: "AccountEntity")
        fallback.predicate = NSPredicate(format: "owner == %@", owner)
        fallback.fetchLimit = 1

        do {
            return try context.fetch(fallback).first
        } catch {
            print("Failed to fetch accounts:", error.localizedDescription)
            return nil
        }
    }

    /// Contacts owned by `owner`, most recent first.
    func fetchContacts(for owner: UserEntity) -> [ContactEntity] {
        let request = NSFetchRequest<ContactEntity>(entityName: "ContactEntity")
        request.predicate = NSPredicate(format: "owner == %@", owner)
        request.sortDescriptors = [NSSortDescriptor(key: "lastTransactionAt", ascending: false)]

        do {
            return try context.fetch(request)
        } catch {
            print("Failed to fetch contacts:", error.localizedDescription)
            return []
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
    
}
