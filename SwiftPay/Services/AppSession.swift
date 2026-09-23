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
    
    @Published var currentUser: UserEntity?
    
    func login(user: UserEntity) {
        currentUser = user
    }
    
    func logout() {
        currentUser = nil
    }
}
