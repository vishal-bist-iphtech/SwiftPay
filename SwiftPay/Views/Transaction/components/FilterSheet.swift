//
//  FilterSheet.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 30/09/26.
//

import SwiftUI

// MARK: - Category filter sheet
struct CategoryFilterSheet: View {

    @ObservedObject var viewModel: TransactionViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        viewModel.selectedCategory = nil
                        dismiss()
                    } label: {
                        HStack {
                            Text("All transactions")
                            Spacer()
                            if viewModel.selectedCategory == nil {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
                Section("Categories") {
                    ForEach(viewModel.availableCategories, id: \.self) { cat in
                        Button {
                            viewModel.selectedCategory = cat
                            dismiss()
                        } label: {
                            HStack {
                                Image(systemName: TransactionViewModel.icon(for: cat, isIncome: false))
                                    .foregroundStyle(
                                        TransactionViewModel.iconColor(for: cat, isIncome: false)
                                    )
                                    .frame(width: 24)
                                Text(cat)
                                Spacer()
                                if viewModel.selectedCategory == cat {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
                if viewModel.selectedCategory != nil {
                    Section {
                        Button("Clear filter", role: .destructive) {
                            viewModel.selectedCategory = nil
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
