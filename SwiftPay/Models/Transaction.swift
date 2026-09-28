//
//  Transaction.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 21/09/26.
//

import Foundation

struct Transaction: Identifiable {

    let id: UUID
    let title: String
    let category: String
    let amount: Double
    let icon: String
    let isIncome: Bool
    let date: Date

    init(
        id: UUID = UUID(),
        title: String,
        category: String,
        amount: Double,
        icon: String,
        isIncome: Bool,
        date: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.amount = amount
        self.icon = icon
        self.isIncome = isIncome
        self.date = date
    }
}
