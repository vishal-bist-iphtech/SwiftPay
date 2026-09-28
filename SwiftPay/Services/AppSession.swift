//
//  AppSession.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 21/09/26.
//

import SwiftUI
import CoreData
import Combine


final class AppSession: ObservableObject {
    
    private enum Keys {
        static let activeUserId = "SwiftPay.activeUserId"
    }

    @Published var currentUser: UserEntity?

    var isLoggedIn: Bool { currentUser != nil }
    
    func login(user: UserEntity) {
        currentUser = user
        if let id = user.id {
            UserDefaults.standard.set(id.uuidString, forKey: Keys.activeUserId)
        }
    }
    
    func logout() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: Keys.activeUserId)
    }


    func restore(context: NSManagedObjectContext) -> Bool {
        guard currentUser == nil,
              let idString = UserDefaults.standard.string(forKey: Keys.activeUserId),
              let id = UUID(uuidString: idString) else {
            return currentUser != nil
        }
        let service = CoreDataService(context: context)
        guard let user = service.fetchUser(id: id) else {
            // Stored id no longer exists — clear stale session.
            UserDefaults.standard.removeObject(forKey: Keys.activeUserId)
            return false
        }
        currentUser = user
        return true
    }
}
