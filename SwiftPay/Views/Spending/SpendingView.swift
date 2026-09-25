//
//  SpendingView.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 24/09/26.
//

import SwiftUI


struct SpendingView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SpendingViewModel()
    /// Selected card page — drives the custom dot indicator below the carousel.
    @State private var selectedCardIndex = 0
    /// Presents the month-only picker for the current year.
    @State private var showingMonthPicker = false
    /// Number of cards in the carousel. Keep in sync with the TabView pages.
    private let cardCount = 3

    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {

                VStack(spacing: 10) {

                    // MARK: Cards
                    
                    TabView(selection: $selectedCardIndex) {
                        CompactCard()
                            .padding(.horizontal, 20)
                            .tag(0)
                        CompactCard()
                            .padding(.horizontal, 20)
                            .tag(1)
                        CompactCard()
                            .padding(.horizontal, 20)
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(height: 120)

                    // Custom page dots.
                    HStack(spacing: 6) {
                        ForEach(0..<cardCount, id: \.self) { index in
                            Circle()
                                .fill(Color.white.opacity(index == selectedCardIndex ? 0.9 : 0.25))
                                .frame(width: 6, height: 6)
                                .animation(.easeInOut(duration: 0.2), value: selectedCardIndex)
                        }
                    }
                    
                    
                    Spacer()

                    // MARK: Total spending + month picker

                    HStack(alignment: .bottom, spacing: 4) {
                        Text("$")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color("mutedText"))
                            .padding(.bottom, 5)

                        Text(viewModel.totalSpent.formatted(.number.precision(.fractionLength(2))))
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
                                Color.white.opacity(0.08),
                                in: RoundedRectangle(cornerRadius: 20)
                            )
                        }
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {

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

/// Month-only picker restricted to the current year.
///
/// Shows all 12 months of `viewModel.currentYear` in a grid. Months after
/// the current month are disabled so the user can only pick the current
/// (default) or past months — never future ones. Tapping a selectable
/// month updates the view model and dismisses the sheet.
private struct MonthPickerSheet: View {

    @ObservedObject var viewModel: SpendingViewModel
    @Environment(\.dismiss) private var dismiss

    /// Short month names (Jan...Dec) for grid cells.
    private var monthSymbols: [String] {
        Calendar.current.shortMonthSymbols
    }

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        VStack(spacing: 16) {
            // Year header — fixed to the current year, no year navigation.
            Text(String(viewModel.currentYear))
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(Color("primaryText"))
                .padding(.top, 8)

            // 12-month grid; future months are visible but disabled.
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(1...12, id: \.self) { month in
                    let isSelected = month == viewModel.selectedMonth
                    let isEnabled = viewModel.isMonthSelectable(month)

                    Button {
                        viewModel.selectMonth(month)
                        dismiss()
                    } label: {
                        Text(monthSymbols[month - 1])
                            .font(.system(size: 15, weight: isSelected ? .semibold : .medium))
                            .foregroundStyle(
                                isSelected ? .white :
                                isEnabled ? Color("primaryText") : Color("mutedText").opacity(0.5)
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                isSelected
                                    ? Color("accentColor")
                                    : Color.white.opacity(0.08).opacity(isEnabled ? 1 : 0.4),
                                in: RoundedRectangle(cornerRadius: 14)
                            )
                    }
                    .disabled(!isEnabled)
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("surface"))
    }
}


#Preview {
    NavigationStack {
        SpendingView()
    }
}
