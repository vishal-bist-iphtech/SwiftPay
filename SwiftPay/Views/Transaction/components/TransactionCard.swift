//
//  TransactionCard.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 30/09/26.
//

import SwiftUI


/// One day group: header ("Today · September 23" + net total)
/// with a dark rounded card containing its rows.
/// Tap a row to edit, long-press for Edit/Delete.
struct TransactionCard: View {

    let section: TransactionDaySection
    var onTap: (Transaction) -> Void = { _ in }
    var onDelete: (Transaction) -> Void = { _ in }

    var body: some View {

        VStack(alignment: .leading, spacing: 8) {

            // MARK: Day header
            HStack {
                Text(section.title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color("mutedText"))

                Spacer()

                Text(TransactionFormat.sectionTotalText(section.total))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color("mutedText"))
            }
            .padding(.horizontal, 4)

            // MARK: Rows card
            VStack(spacing: 0) {
                ForEach(Array(section.transactions.enumerated()), id: \.element.id) { index, transaction in
                    Button {
                        onTap(transaction)
                    } label: {
                        TransactionRowContent(transaction: transaction)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button {
                            onTap(transaction)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button(role: .destructive) {
                            onDelete(transaction)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }

                    if index < section.transactions.count - 1 {
                        Divider()
                            .background(Color.white.opacity(0.06))
                            .padding(.leading, 62)
                    }
                }
            }
            .padding(.vertical, 6)
            .background(Color("surface").opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
            }
        }
    }
}

/// Colored icon badge + title/subtitle + amount.
struct TransactionRowContent: View {

    let transaction: Transaction

    var body: some View {

        HStack(spacing: 12) {

            // Icon badge
            Image(systemName: TransactionViewModel.icon(for: transaction.category, isIncome: transaction.isIncome))
                .font(.system(size: 25, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(
                    TransactionViewModel.iconColor(
                        for: transaction.category,
                        isIncome: transaction.isIncome
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color("primaryText"))
                    .lineLimit(1)

                Text(TransactionFormat.subtitle(transaction))
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color("mutedText"))
                    .lineLimit(1)
            }

            Spacer(minLength: 8)

            Text(TransactionFormat.amountText(transaction))
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(
                    transaction.isIncome ? Color.green : Color("primaryText")
                )
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}

#Preview {
    TransactionCard(
        section: TransactionDaySection(
            id: "2026-09-23",
            title: "Today · September 23",
            total: -76.42,
            transactions: [
                Transaction(title: "Breakfast", category: "food", amount: 6.80, isIncome: false, date: Date()),
                Transaction(title: "Aster Market", category: "Grocery", amount: 54.62, isIncome: false, date: Date()),
                Transaction(title: "Sonora", category: "Subscription", amount: 15.00, isIncome: false, date: Date())
            ]
        )
    )
    .padding()
    .background(Color("background"))
    .preferredColorScheme(.dark)
}
