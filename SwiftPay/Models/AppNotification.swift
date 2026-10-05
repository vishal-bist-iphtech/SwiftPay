//
//  AppNotification.swift
//  SwiftPay
//
//  In-app record for a local debit notification.
//  Only amount debited + remaining balance are shown.
//

import Foundation

struct AppNotification: Identifiable, Hashable {
    let id: UUID
    let amount: Double
    let remainingBalance: Double
    let currencyCode: String
    let bankName: String
    let recipientName: String
    let date: Date
    var isRead: Bool

    init(
        id: UUID = UUID(),
        amount: Double,
        remainingBalance: Double,
        currencyCode: String = "USD",
        bankName: String = "",
        recipientName: String = "",
        date: Date = Date(),
        isRead: Bool = false
    ) {
        self.id = id
        self.amount = amount
        self.remainingBalance = remainingBalance
        self.currencyCode = currencyCode
        self.bankName = bankName
        self.recipientName = recipientName
        self.date = date
        self.isRead = isRead
    }

    var title: String { "Amount debited" }

    var body: String {
        let debited = AccountFormatting.formattedBalance(amount, currencyCode: currencyCode)
        let remaining = AccountFormatting.formattedBalance(remainingBalance, currencyCode: currencyCode)
        if recipientName.isEmpty {
            return "\(debited) debited · Remaining balance \(remaining)"
        }
        return "\(debited) debited to \(recipientName) · Remaining balance \(remaining)"
    }

    var timeText: String {
        date.formatted(date: .omitted, time: .shortened)
    }
}
