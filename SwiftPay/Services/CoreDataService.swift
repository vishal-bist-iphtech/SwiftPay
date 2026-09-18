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
    
}
