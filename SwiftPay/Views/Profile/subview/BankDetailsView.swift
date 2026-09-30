//
//  BankDetailsView.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 29/09/26.
//

import SwiftUI
import CoreData

struct BankDetailsView: View {

    @EnvironmentObject var viewModel: BankDetailsViewModel

    @State private var accountToDelete: BankAccount?
    @State private var showDeleteConfirm = false

    var body: some View {

        ZStack {
            Color("background")
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // MARK: Summary
                    Text(summaryText)
                        .font(.subheadline)
                        .foregroundStyle(Color("secondaryText"))
                        .padding(.top, 8)

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color("accentColor"))
                            .padding(.top, 12)
                    }

                    if viewModel.hasAccounts {
                        // MARK: Account cards
                        VStack(spacing: 14) {
                            ForEach(viewModel.accounts) { account in
                                AccountCard(
                                    card: account,
                                    onSetPrimary: {
                                        viewModel.setPrimary(account)
                                    },
                                    onDelete: {
                                        accountToDelete = account
                                        showDeleteConfirm = true
                                    }
                                )
                            }
                        }
                        .padding(.top, 16)
                    } else {
                        BankAccountsEmptyState()
                            .padding(.top, 16)
                    }

                    // MARK: Add account
                    NavigationLink {
                        AddAccountView()
                    } label: {
                        HStack {
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                            Text("Add new account")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.56, blue: 0.25),
                                    Color(red: 0.94, green: 0.27, blue: 0.2)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .padding(.top, 22)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("Bank accounts & cards")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                } label: {
                    Text("Help")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color("accentColor"))
                }
            }
            .sharedBackgroundVisibility(.hidden)
        }
        .onAppear {
            viewModel.refresh()
        }
        .alert(
            "Delete account?",
            isPresented: $showDeleteConfirm,
            presenting: accountToDelete
        ) { row in
            Button("Cancel", role: .cancel) {
                accountToDelete = nil
            }
            Button("Delete", role: .destructive) {
                viewModel.delete(row)
                accountToDelete = nil
            }
        } message: { account in
            Text("This will remove \(account.bankName) \(account.maskedNumber) from SwiftPay. This cannot be undone.")
        }
    }

    private var summaryText: String {
        let count = viewModel.accounts.count
        switch count {
        case 0: return "Manage your linked accounts"
        case 1: return "1 linked account"
        default: return "\(count) linked accounts"
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let session = AppSession()
    let store = AccountStore(context: context, session: session)
    return NavigationStack {
        BankDetailsView()
            .environmentObject(BankDetailsViewModel(store: store))
            .environmentObject(session)
            .environment(\.managedObjectContext, context)
    }
    .preferredColorScheme(.dark)
}
