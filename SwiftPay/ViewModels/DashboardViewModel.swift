//
//  DashboardViewModel.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 21/09/26.
//

import Foundation
import Combine
import CoreData



final class DashboardViewModel: ObservableObject {
    
    @Published var balance: Double = 0
    @Published var transactions: [Transaction] = []
    @Published var contacts: [ContactItem] = []
    @Published var bankName: String = ""
    @Published var maskedAccountNumber: String = ""
    @Published var hasAccount = false

    var hasTransactions: Bool { !transactions.isEmpty }
    var hasContacts: Bool { !contacts.isEmpty }

    private let service: CoreDataService
    private var cancellables = Set<AnyCancellable>()
    private var isObserving = false


    init(context: NSManagedObjectContext) {
        self.service = CoreDataService(context: context)
    }

    /// Starts observing the session; reloads whenever the user changes.
    func observe(session: AppSession) {
        guard !isObserving else { return }
        isObserving = true
        load(for: session.currentUser)
        session.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in self?.load(for: user) }
            .store(in: &cancellables)
    }

    /// Loads balance + transactions + contacts for `user`.
    /// Empty state when user is nil
    @MainActor
    func load(for user: UserEntity?) {
        guard let user else {
            balance = 0
            transactions = []
            contacts = []
            bankName = ""
            maskedAccountNumber = ""
            hasAccount = false
            return
        }
        if let account = service.fetchPrimaryAccount(for: user) {
            hasAccount = true
            balance = Self.doubleValue(account.balance)
            bankName = account.bankName ?? ""
            maskedAccountNumber = account.maskedNumber ?? Self.masked(from: account.accountNumber)
        } else {
            hasAccount = false
            balance = 0
            bankName = ""
            maskedAccountNumber = ""
        }
        transactions = service.fetchTransactions(for: user).map { entity in
            let title = entity.title ?? ""
            let category = entity.category ?? ""
            let isIncome = entity.isIncome
            return Transaction(
                title: title,
                category: category,
                amount: Self.doubleValue(entity.amount),
                icon: Self.icon(category: category, title: title, isIncome: isIncome),
                isIncome: isIncome
            )
        }
        contacts = service.fetchContacts(for: user).map { entity in
            ContactItem(
                id: entity.id ?? UUID(),
                name: entity.name ?? ""
            )
        }
    }

    /// SF Symbol for a category.
    static func icon(category: String, title: String, isIncome: Bool) -> String {        if isIncome { return "building.2.fill" }
        
        switch category.lowercased() {
            
        case "entertainment": 
            return "play.rectangle.fill"
            
        case "transport":
            return "car.fill"
            
        case "food", "foodstuff":
            return "fork.knife"
            
        case "subscriptions":
            return "repeat"
            
        case "bills":
            return "receipt"
            
        case "shopping":
            return "cart"
            
        case "others":
            return "ellipsis"
            
        default: break
        }
        
        
        switch title.lowercased() {
            
        case "netflix": 
            return "play.rectangle.fill"
            
        case "uber": 
            return "car.fill"
            
        case "salary": 
            return "building.2.fill"
            
        default: 
            return "circle.fill"
        }
    }

    // MARK: - Mapping helpers

    static func doubleValue(_ value: Any?) -> Double {
        if let number = value as? NSDecimalNumber {
            return number.doubleValue
        }
        if let decimal = value as? Decimal {
            return (decimal as NSDecimalNumber).doubleValue
        }
        if let number = value as? NSNumber {
            return number.doubleValue
        }
        return 0
    }

    static func masked(from accountNumber: String?, visibleDigits: Int = 4) -> String {
        guard let digits = accountNumber?.filter({ $0.isNumber }), !digits.isEmpty else { return "" }
        guard digits.count > visibleDigits else { return digits }
        return "••••• \(digits.suffix(visibleDigits))"
    }
}


struct ContactItem: Identifiable {
    let id: UUID
    let name: String
}
