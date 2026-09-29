//
//  BankAccountCard.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 29/09/26.
//

import Foundation



/// UI row for one linked bank account.
struct BankAccount: Identifiable {
    let id: UUID
    let account: AccountEntity

    var bankName: String { account.bankName ?? "Bank account" }
    var accountType: String { account.accountType ?? "Saving" }
    var isPrimary: Bool { account.isPrimary }

    var maskedNumber: String {
        if let stored = account.maskedNumber, !stored.isEmpty { return stored }
        return AccountFormatting.maskedAccountNumber(account.accountNumber ?? "")
    }

    var balance: Double {
        (account.balance as NSDecimalNumber?)?.doubleValue ?? 0
    }

    var currencyCode: String { account.currencyCode ?? "USD" }

    var formattedBalance: String {
        AccountFormatting.formattedBalance(balance, currencyCode: currencyCode)
    }
}
