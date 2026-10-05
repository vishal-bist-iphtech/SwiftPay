//
//  TransactionDetailsView.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 01/10/26.
//

import SwiftUI

struct TransactionDetailsView: View {

    @EnvironmentObject var viewModel: TransactionViewModel
    @Environment(\.dismiss) private var dismiss

    let transaction: Transaction

    /// To whom the payment was done. Falls back to title (merchant) when empty.
    private var paidToText: String {
        if !transaction.paidTo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return transaction.paidTo }
        return transaction.title.isEmpty ? "—" : transaction.title
    }

    @State private var showingEdit = false
    @State private var showingDeleteConfirm = false

    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {

                    // MARK: Custom nav (back + title + Edit)
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color("primaryText"))
                                .frame(width: 36, height: 36)
                                .background(Color("primaryText").opacity(0.08))
                                .clipShape(Circle())
                        }

                        Spacer()

                        Text("Transaction details")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundStyle(Color("primaryText"))

                        Spacer()

                        Button {
                            showingEdit = true
                        } label: {
                            Text("Edit")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color(red: 0.95, green: 0.45, blue: 0.2))
                        }
                    }

                    // MARK: Hero (icon + title + amount + status)
                    VStack(spacing: 8) {
                        Image(systemName: TransactionViewModel.icon(for: transaction.category, isIncome: transaction.isIncome))
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 52, height: 52)
                            .background(
                                TransactionViewModel.iconColor(for: transaction.category, isIncome: transaction.isIncome)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))

                        Text(transaction.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color("primaryText"))

                        Text(TransactionFormat.amountText(transaction))
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(Color("primaryText"))

                        Text(transaction.status.isEmpty ? "Completed" : transaction.status)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(Color.green)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.green.opacity(0.15))
                            .clipShape(Capsule())
                    }
                    .padding(.top, 4)

                    // MARK: Details card
                    VStack(spacing: 0) {
                        
                        DetailRow(
                            icon: "calendar",
                            label: "DATE & TIME",
                            value: viewModel.dateTimeText(for: transaction)
                        )
                        
                        DetailDivider()
                        
                        DetailRow(
                            icon: "creditcard.fill",
                            label: "PAID WITH",
                            value: viewModel.paidWithText(for: transaction)
                        )
                        
                        DetailDivider()
                        
                        DetailRow(
                            icon: "person.fill",
                            label: "PAID TO",
                            value: paidToText
                        )
                        
                        DetailDivider()
                        
                        DetailRow(
                            icon: "tag.fill",
                            label: "CATEGORY",
                            value: transaction.category
                        )
                    }
                    .padding(.vertical, 6)
                    .background(Color("surface").opacity(0.55))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color("border").opacity(0.4), lineWidth: 1)
                    }

                    // MARK: Note + receipt
                    VStack(alignment: .leading, spacing: 8) {
                        Text("NOTE")
                            .font(.system(size: 11, weight: .medium))
                            .tracking(0.5)
                            .foregroundStyle(Color("mutedText"))

                        Text(transaction.note.isEmpty ? "No note added." : transaction.note)
                            .font(.system(size: 14))
                            .foregroundStyle(
                                transaction.note.isEmpty
                                ? Color("mutedText")
                                : Color("primaryText")
                            )
                            .frame(maxWidth: .infinity, maxHeight: 100)
                            .frame(height: 50)
                    }
                    .padding(14)
                    .background(Color("surface").opacity(0.55))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .overlay {
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color("border").opacity(0.4), lineWidth: 1)
                    }
                    
                    Spacer(minLength: 12)

                    // MARK: Bottom
                    HStack(spacing: 12) {
                        Button {
                            showingDeleteConfirm = true
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(Color(red: 1.0, green: 0.4, blue: 0.35))
                                .frame(width: 52, height: 52)
                                .background(Color("primaryText").opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        Button {
                            showingEdit = true
                        } label: {
                            Text("Edit transaction")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(
                                    LinearGradient.primaryAction
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(.bottom, 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .sheet(isPresented: $showingEdit) {
            TransactionSheet(viewModel: viewModel, transaction: transaction)
        }
        .alert("Delete transaction?", isPresented: $showingDeleteConfirm) {
            Button("Delete", role: .destructive) {
                viewModel.deleteTransaction(transaction)
                dismiss()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("“\(transaction.title)” will be permanently removed.")
        }
    }
}

private struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color(red: 0.95, green: 0.45, blue: 0.2))
                .frame(width: 36, height: 36)
                .background(Color("primaryText").opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .tracking(0.5)
                    .foregroundStyle(Color("mutedText"))
                Text(value)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color("primaryText"))
                    .lineLimit(2)
            }

            Spacer(minLength: 8)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
}

private struct DetailDivider: View {
    var body: some View {
        Divider()
            .background(Color("border").opacity(0.4))
            .padding(.leading, 60)
    }
}

#Preview {
    let session = AppSession()
    let vm = TransactionViewModel(session: session)
    return NavigationStack {
        TransactionDetailsView(
            transaction: Transaction(
                title: "Copper & Pine",
                category: "Coffee & dining",
                amount: 6.80,
                isIncome: false,
                date: Date(),
                status: "Completed",
                note: "Morning coffee with Maya before the client review.",
                paidTo: "Maya Sharma"
            )
        )
        .environmentObject(vm)
    }
    .preferredColorScheme(.dark)
}
