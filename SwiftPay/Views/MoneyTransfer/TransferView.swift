//
//  TransferView.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 23/09/26.
//

import SwiftUI
import CoreData

struct TransferView: View {

    @EnvironmentObject var viewModel: TransferViewModel

    var body: some View {

        ZStack {

            LinearGradient(
                colors: [Color.orange, Color("background").opacity(0.7), Color("background"),Color("surface")],
                startPoint: .topTrailing, endPoint: .bottomLeading
            )
             .ignoresSafeArea()

            ScrollView(showsIndicators: false) {

                VStack(spacing: 8) {

                    // MARK: From & To cards
                    TransferCard(
                        bankName: viewModel.bankName,
                        maskedNumber: viewModel.maskedNumber,
                        balance: viewModel.balance,
                        currencyCode: viewModel.currencyCode,
                        recipient: viewModel.selectedRecipient,
                        onSelectRecipient: {
                            viewModel.showingContactPicker = true
                        }
                    )

                    // MARK: Transfer amount
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("$")
                            .font(.system(size: 30, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color("secondaryText").opacity(0.7))

                        if viewModel.transferAmount.isEmpty {
                            Text("0.00")
                                .font(.system(size: 50, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundStyle(
                                    Color("primaryText")
                                        .opacity(0.7)
                                )
                        }

                        Text(viewModel.transferAmount)

                            .font(.system(size: 50, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundStyle(Color("primaryText"))
                            .tint(.white)
                            .focusable(false)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 110)

                    // MARK: Balance / validation messages
                    if !viewModel.hasAccount {
                        Text(AppStrings.noAccount)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(Color("accentColor"))
                    } else if viewModel.exceedsBalance {
                        Text(AppStrings.insufficientBal)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(Color("accentColor"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(Color("accentColor"))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }

                    // MARK: Custom NumPad
                    Numpad(amount: Binding(
                        get: { viewModel.transferAmount },
                        set: { viewModel.updateAmount($0) }
                    ))


                    // MARK: Send Button
                    Button {
                        viewModel.send()
                    } label: {
                        ZStack {

                            Text("Send Money")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundStyle(
                                    Color("background")
                                )
                                .opacity(viewModel.isProcessing ? 0 : 1)

                            if viewModel.isProcessing {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(
                                        Color("background")
                                    )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .padding()
                        .background(.white)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 22)
                        )
                    }
                    .disabled(!viewModel.isAmountValid || viewModel.isProcessing)
                    .padding(.top, 15)
                }
                .padding(.top, 15)
                .padding(.horizontal, 15)
            }

        }
        .navigationTitle("Transfer money")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.refresh()
        }
        .fullScreenCover(isPresented: $viewModel.showSuccess) {
            TransferSuccessView(
                amount: viewModel.sentAmount,
                recipientName: viewModel.selectedRecipient?.name
            ) {
                viewModel.showSuccess = false
            }
        }
        .sheet(isPresented: $viewModel.showingContactPicker) {
            ContactPickerSheet(
                contacts: Contact.all,
                selected: viewModel.selectedRecipient,
                onSelect: { viewModel.selectRecipient($0) }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {

                } label: {
                    Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                }
                .padding(4)
            }
        }
    }
}


#Preview {
    let context = PersistenceController.preview.container.viewContext
    let session = AppSession()
    let store = AccountStore(context: context, session: session)
    return NavigationStack {
        TransferView()
            .environmentObject(TransferViewModel(store: store, session: session))
    }
}
