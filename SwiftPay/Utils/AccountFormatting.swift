//
//  AccountFormatting.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 28/09/26.
//

import Foundation

enum AccountFormatting {

    /// Placeholder shown when a card balance is hidden.
    static let hiddenBalanceText = "xxxx"

    // Masking an account number, showing only the last `visibleDigits` digits.
    static func maskedAccountNumber(_ accountNumber: String, visibleDigits: Int = 4) -> String {
        let digitsOnly = accountNumber.filter { $0.isNumber }

        guard digitsOnly.count > visibleDigits else {
            return digitsOnly
        }

        let lastDigits = digitsOnly.suffix(visibleDigits)
        return "••••• \(lastDigits)"
    }

    // formatting the balance
    static func formattedBalance(_ value: Double, currencyCode: String = "USD") -> String {
        value.formatted(
            .currency(code: currencyCode)
            .precision(.fractionLength(2))
        )
    }
}
