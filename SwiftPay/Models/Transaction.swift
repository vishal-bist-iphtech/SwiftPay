//
//  Transaction.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 21/09/26.
//

import Foundation

struct Transaction: Identifiable {
    
    let id = UUID()
    let title: String
    let category: String
    let amount: Double
    let icon: String
    let isIncome: Bool
}
