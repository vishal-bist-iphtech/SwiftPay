//
//  AuthViewModel.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 18/09/26.
//

import Foundation
import Combine
import CoreData

final class AuthViewModel: ObservableObject {
    
    enum AuthFlow {
        case login(UserEntity)
        case signup(phone: String)
    }
    
    
    @Published var name = ""
    @Published var email = ""
    @Published var phone = ""
    
    @Published var errorMessage: String?

    func reset() {
        name = ""
        email = ""
        phone = ""
        errorMessage = nil
    }
    private let coreDataService: CoreDataService
    
    init(context: NSManagedObjectContext) {
        self.coreDataService = CoreDataService(
            context: context
        )
    }
    
    // phone number normalization into a single format
    private var normalizedPhone: String {
        phone.filter {
            $0.isNumber
        }
    }
    
    func login() -> AuthFlow? {        
        errorMessage = nil
        
        let phone = normalizedPhone
        
        guard phone.count == 10 else {
            errorMessage = AppStrings.authInvalidPhoneNumber
            return nil
        }
        
        if let existingUser = coreDataService.fetchUser(
            phone: phone
        ) {
            
            return .login(existingUser)
        }
        
        return .signup(phone: phone)
    }
    
    
    func signup() -> UserEntity? {
        
        errorMessage = nil
        
        name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !name.isEmpty else {
            errorMessage = AppStrings.authNameRequired
            return nil
        }
        
        guard isValidName(name) else {
            errorMessage = AppStrings.authNameInvalid
            return nil
        }
        
        guard isValidEmail(email) else {
            
            errorMessage = AppStrings.authEmailInvalid
            return nil
        }
        
        do {
            
            let user = try coreDataService.createUser(
                phone: phone,
                name: name,
                email: email
            )
            
            return user
            
        } catch {
            
            errorMessage = "\(AppStrings.authCreateAccountFailed)\n\(error.localizedDescription)"
            
            return nil
        }
    }

    // MARK: - Navigation intents (keep routing side effects out of Views)

    /// Login button intent: validates, then routes to main (existing user)
    /// or signup (new phone). Views call this single method.
    @MainActor
    func handleLoginTapped(session: AppSession, router: AppRouter) {
        guard let result = login() else { return }
        switch result {
        case .login(let user):
            session.login(user: user)
            router.screen = .main
        case .signup:
            router.screen = .signup
        }
    }

    /// Signup button intent: creates the account, logs in, routes to main.
    @MainActor
    func handleSignupTapped(session: AppSession, router: AppRouter) {
        guard let user = signup() else { return }
        session.login(user: user)
        router.screen = .main
    }

    /// Logout intent: clears persisted session, resets form state, routes out.
    @MainActor
    func handleLogout(session: AppSession, router: AppRouter) {
        session.logout()
        reset()
        router.screen = .landing
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        
        let regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        
        return email.range(
            of: regex,
            options: .regularExpression
        ) != nil
    }
    
    private func isValidName(_ name: String) -> Bool {
        
        guard (2...50).contains(name.count) else {return false}
        
        let regex4Name = CharacterSet.letters
            .union(.whitespaces)
        
        guard name.unicodeScalars.allSatisfy({regex4Name.contains($0)})
        else {return false}
        
        return true
    }
}
