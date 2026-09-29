//
//  BankAccountsEmptyState.swift
//  SwiftPay
//
//  Empty state for BankDetailsView when no accounts are linked.
//

import SwiftUI

struct BankAccountsEmptyState: View {

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "building.columns.fill")
                .font(.title)
                .foregroundStyle(Color("mutedText"))

            Text(AppStrings.noBankAdded)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundStyle(Color("primaryText"))

            Text(AppStrings.emptyStateNoAccount)
                .font(.subheadline)
                .foregroundStyle(Color("mutedText"))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
        .background(Color("surface").opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    BankAccountsEmptyState()
        .padding()
        .preferredColorScheme(.dark)
}
