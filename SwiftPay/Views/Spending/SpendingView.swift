//
//  SpendingView.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 24/09/26.
//

import SwiftUI
import CoreData // Preview only; all Core Data work lives in the ViewModel.


struct SpendingView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: SpendingViewModel
    /// Selected card page
    @State private var selectedCardIndex = 0
    /// Presents the month-only picker for the current year.
    @State private var showingMonthPicker = false

    private var cardCount: Int {
        max(viewModel.accountCards.count, 1)
    }

    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {

                VStack(spacing: 10) {

                    // MARK: Cards (Core Data balances / masked numbers)

                    TabView(selection: $selectedCardIndex) {
                        if viewModel.accountCards.isEmpty {
                            CompactCard(balance: 0, currencyCode: "USD", maskedNumber: "••••• ••••")
                                .padding(.horizontal, 20)
                                .tag(0)
                        } else {
                            ForEach(Array(viewModel.accountCards.enumerated()), id: \.element.id) { index, card in
                                CompactCard(
                                    balance: card.balance,
                                    currencyCode: card.currencyCode,
                                    maskedNumber: card.maskedNumber
                                )
                                .padding(.horizontal, 20)
                                .tag(index)
                            }
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 120)
                    .onChange(of: viewModel.accountCards.count) { _, newCount in
                        if selectedCardIndex >= max(newCount, 1) {
                            selectedCardIndex = 0
                        }
                    }

                    // Custom page dots.
                    HStack(spacing: 6) {
                        ForEach(0..<cardCount, id: \.self) { index in
                            Circle()
                                .fill(Color("mutedText").opacity(index == selectedCardIndex ? 0.9 : 0.3))
                                .frame(width: 6, height: 6)
                                .animation(.easeInOut(duration: 0.2), value: selectedCardIndex)
                        }
                    }
                    
                    
                    Spacer()

                    // MARK: Total spending + month picker

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(alignment: .bottom, spacing: 4) {
                            Text(viewModel.formattedTotalSpent)
                                .font(.system(size: 34, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color("primaryText"))

                            Spacer()

                            Button {
                                showingMonthPicker = true
                            } label: {
                                HStack(spacing: 4) {
                                    Text(viewModel.monthLabel)
                                        .font(.system(size: 14, weight: .medium))
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12, weight: .semibold))
                                }
                                .foregroundStyle(Color("primaryText"))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .background(
                                    Color("primaryText").opacity(0.08),
                                    in: RoundedRectangle(cornerRadius: 20)
                                )
                            }
                        }

                        Text(viewModel.primaryAccountLabel)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color("mutedText"))
                    }
                    .padding(.horizontal, 20)

                    // MARK: Graph
                    
                    AnalyticsGraph(viewModel: viewModel)
                        .padding(.horizontal, 20)

                    // MARK: Analytics
                    
                    Analytics(viewModel: viewModel)
                }
                .padding(.top, 10)
            }
        }
        .navigationTitle("Spending")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.refresh()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    TransactionView()
                } label: {
                    Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                }
                .padding(4)
            }
        }
        .sheet(isPresented: $showingMonthPicker) {
            MonthPickerSheet(viewModel: viewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}


#Preview {
    let context = PersistenceController.preview.container.viewContext
    let session = AppSession()
    let store = AccountStore(context: context, session: session)
    return NavigationStack {
        SpendingView()
            .environmentObject(SpendingViewModel(store: store))
    }
}
