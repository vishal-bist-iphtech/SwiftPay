//
//  CategoryRow.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 24/09/26.
//

import SwiftUI

struct CategoryRow: View {

    let category: TransactionCategory

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 1.0, green: 0.55, blue: 0.25),
                                Color(red: 0.9, green: 0.3, blue: 0.08),
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)

                Image(systemName: category.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(category.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color("primaryText"))

                Text("\(category.transactionCount) transactions")
                    .font(.subheadline)
                    .foregroundStyle(Color("mutedText"))
            }

            Spacer()

            Text("- \(category.totalAmount.formatted(.currency(code: "USD")))")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color("primaryText"))
        }
    }
}
