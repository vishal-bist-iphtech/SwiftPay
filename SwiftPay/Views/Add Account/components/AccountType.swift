//
//  AccountType.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 28/09/26.
//

import SwiftUI

struct AccountType: View {
    let type: AddAccountType
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(selected ? Color("accentColor") : Color("secondaryText"))
                Text(type.rawValue)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(selected ? Color("accentColor") : Color("primaryText").opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 76)
            .background(Color("surface"))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        selected ? Color("accentColor") : Color("border").opacity(0.3),
                        lineWidth: selected ? 1.5 : 1
                    )
            }
        }
        .buttonStyle(.plain)
    }
}
