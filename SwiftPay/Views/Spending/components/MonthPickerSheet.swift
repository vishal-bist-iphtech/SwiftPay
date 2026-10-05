//
//  MonthPickerSheet.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 01/10/26.
//

import SwiftUI

// Month Picker Sheet
struct MonthPickerSheet: View {

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
                                    : Color("primaryText").opacity(isEnabled ? 0.08 : 0.04),
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
