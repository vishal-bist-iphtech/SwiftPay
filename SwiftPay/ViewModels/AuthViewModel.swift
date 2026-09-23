//
//  AuthViewModel.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 18/09/26.
//

import Foundation
import Combine

final class AuthViewModel: ObservableObject {
    
    @Published var isLogin = true
    
    @Published var name = ""
    @Published var email = ""
    @Published var phone = ""
    @Published var password = ""
    
    @Published var errorMessage: String?
    
    var isValid: Bool {
        
        if isLogin {
            return !email.isEmpty && !password.isEmpty
        }
        
        return !name.isEmpty &&
                !email.isEmpty &&
                !phone.isEmpty &&
                !password.isEmpty
    }
    
    func submit() -> Bool {
        
        guard isValid else {
            errorMessage = "Please fill all fields."
            return false
        }
        
        errorMessage = nil
        return true
    }
}
