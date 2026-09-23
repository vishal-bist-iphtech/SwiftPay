//
//  DashboardViewModel.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 21/09/26.
//

import Foundation
import Combine


final class DashboardViewModel: ObservableObject {
    
    @Published var balance: Double = 12345.80
    
    @Published var transactions: [Transaction] = [
        
        Transaction(
            title: "Apple",
            category: "Technology",
            amount: 32.90,
            icon: "apple.logo",
            isIncome: false
        ),
        
        Transaction(
            title: "Netflix",
            category: "Entertainment",
            amount: 19.99,
            icon: "play.rectangle.fill",
            isIncome: false
        ),
        
        Transaction(
            title: "Salary",
            category: "Income",
            amount: 5200,
            icon: "building.2.fill",
            isIncome: true
        ),
        
        Transaction(
            title: "Uber",
            category: "Transport",
            amount: 24.60,
            icon: "car.fill",
            isIncome: false
        )
    ]
}
