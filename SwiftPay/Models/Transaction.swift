//
//  Transaction.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 21/09/26.
//

import Foundation

struct Transaction: Identifiable, Hashable {

    let id: UUID
    let title: String
    let category: String
    let amount: Double
    let isIncome: Bool
    let date: Date
    let status: String
    let note: String
    let paidTo: String
    let paidWith: String

    init(
        id: UUID = UUID(),
        title: String,
        category: String,
        amount: Double,
        isIncome: Bool,
        date: Date = Date(),
        status: String = "Completed",
        note: String = "",
        paidTo: String = "",
        paidWith: String = ""
    ) {
        self.id = id
        self.title = title
        self.category = category
        self.amount = amount
        self.isIncome = isIncome
        self.date = date
        self.status = status
        self.note = note
        self.paidTo = paidTo
        self.paidWith = paidWith
    }
}
