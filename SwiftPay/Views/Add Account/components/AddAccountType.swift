//
//  AddAccountType.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 28/09/26.
//

import Foundation

/// What the user wants to add (bank account vs card).
/// Note: Core Data `AccountEntity.accountType` is separate (saving/current)
/// and is always saved as "saving" for now.
enum AddAccountType: String, CaseIterable, Identifiable {
    case bank = "Bank"
    case creditCard = "Credit card"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .bank: return "building.columns.fill"
        case .creditCard: return "creditcard.fill"
        }
    }
}

/// Focusable fields on the Add Account screen.
/// Shared between `AddAccountView` and its components so keyboard
/// Next/Done navigation keeps working after the split.
enum AddAccountField: Hashable {
    case accountNumber, accountName, lastFour, cvvNumber
}
