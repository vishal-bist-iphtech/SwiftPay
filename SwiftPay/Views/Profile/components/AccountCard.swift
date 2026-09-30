//
//  AccountCard.swift
//  SwiftPay
//

import SwiftUI
import CoreData

struct AccountCard: View {

    let card: BankAccount
    let onSetPrimary: () -> Void
    let onDelete: () -> Void
    
    @State private var isBalanceVisible: Bool = false

    var body: some View {

        VStack(alignment: .leading, spacing: 12) {
            // Top: bank identity + primary badge
            HStack(spacing: 12) {
                Image(systemName: "building.columns.fill")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color("primaryText"))
                    .frame(width: 44, height: 44)
                    .background(Color("surface"))
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(card.bankName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color("primaryText"))
                            .lineLimit(1)
                    }

                    Text("\(card.accountType) • \(card.maskedNumber)")
                        .font(.subheadline)
                        .foregroundStyle(Color("secondaryText"))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 2) {
                        Text("Balance")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(Color("secondaryText"))
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isBalanceVisible.toggle()
                            }
                        } label: {
                            Image(
                                systemName: isBalanceVisible
                                ? "eye.fill"
                                : "eye.slash.fill"
                            )
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.white.opacity(0.7))
                        }
                    }
                    Text(
                        isBalanceVisible
                        ? card.formattedBalance
                        : "xxxx"
                    )
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.8)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .lineLimit(1)
                }
            }
            
            
            Divider()
                .background(Color("border").opacity(0.4))

            // Bottom: actions
            HStack(spacing: 10) {
                if card.isPrimary {
                    Label("Primary for transfers", systemImage: "checkmark.circle.fill")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.green)
                } else {
                    Button(action: onSetPrimary) {
                        Text("Set as primary")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(Color("secondaryText"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color("surface").opacity(0.12))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }

                Spacer()

                Button(role: .destructive, action: onDelete) {
                    Label("Delete", systemImage: "trash")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .glassEffect(.regular, in: .rect)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let account = AccountEntity(context: context)
    account.bankName = "HDFC Bank"
    account.accountType = "Saving"
    account.maskedNumber = "••••• 4321"
    account.balance = NSDecimalNumber(value: 6000)
    account.currencyCode = "USD"
    account.isPrimary = true
    let card = BankAccount(id: UUID(), account: account)
    return AccountCard(card: card, onSetPrimary: {}, onDelete: {})
        .padding()
        .preferredColorScheme(.dark)
}
