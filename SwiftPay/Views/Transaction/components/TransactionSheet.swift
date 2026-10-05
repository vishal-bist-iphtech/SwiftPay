//
//  AddEditTransaction.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 30/09/26.
//

import SwiftUI

// MARK: - Add / Edit sheet (Create + Update)

struct TransactionSheet: View {

    @ObservedObject var viewModel: TransactionViewModel
    let transaction: Transaction?
    
    var onDelete: ((Transaction) -> Void)? = nil

    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var category = "Food"
    @State private var amountText = ""
    @State private var isIncome = false
    @State private var date = Date()
    @State private var note = ""
    @State private var paidTo = ""
    @State private var paidWith = ""

    private var isEditing: Bool { transaction != nil }

    private let categories = [
        "Bills", "Food", "Entertainment", "Grocery", "Shopping",
        "Subscription", "Transport", "Income", "Money Transfer", "Others"
    ]


    private var pickerCategories: [String] {
        if category.isEmpty || categories.contains(category) { return categories }
        return categories + [category]
    }

    /// Saved contacts for Paid-To suggestions
    private var contacts: [Contact] { viewModel.contactSuggestions() }

    /// Bank accounts for Paid-With suggestions 
    private var accountOptions: [String] { viewModel.accountSuggestions() }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title (e.g. Breakfast, taxi fare)", text: $title)
                    Picker("Category", selection: $category) {
                        ForEach(pickerCategories, id: \.self) { Text($0).tag($0) }
                    }
                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)
                    Toggle("Income", isOn: $isIncome)
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }

                // MARK: Paid To — contacts + custom text
                Section {
                    TextField("Paid to", text: $paidTo)
                        .textContentType(.name)
                } header: {
                    Text("Paid To")
                } footer: {
                    if !contacts.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(contacts) { contact in
                                    Button {
                                        paidTo = contact.name
                                    } label: {
                                        HStack(spacing: 6) {
                                            if let imageData = contact.imageData,
                                               let uiImage = UIImage(data: imageData) {
                                                Image(uiImage: uiImage)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 24, height: 24)
                                                    .clipShape(Circle())
                                            } else {
                                                Text(contact.initials)
                                                    .font(.system(size: 9, weight: .semibold))
                                                    .foregroundStyle(.white)
                                                    .frame(width: 24, height: 24)
                                                    .background(Color(red: 0.95, green: 0.45, blue: 0.2).opacity(0.8))
                                                    .clipShape(Circle())
                                            }
                                            Text(contact.name)
                                                .font(.subheadline)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            paidTo == contact.name
                                            ? Color.accentColor.opacity(0.25)
                                            : Color.gray.opacity(0.15)
                                        )
                                        .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.top, 6)
                        }
                    }
                }

                // MARK: Paid With
                Section {
                    TextField("Paid with", text: $paidWith)
                } header: {
                    Text("Paid With")
                } footer: {
                    if !accountOptions.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(accountOptions, id: \.self) { option in
                                    Button {
                                        paidWith = option
                                    } label: {
                                        HStack(spacing: 6) {
                                            Image(systemName: "creditcard.fill")
                                                .font(.caption)
                                            Text(option)
                                                .font(.subheadline)
                                        }
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(
                                            paidWith == option
                                            ? Color.accentColor.opacity(0.25)
                                            : Color.gray.opacity(0.15)
                                        )
                                        .clipShape(Capsule())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.top, 6)
                        }
                    } else {
                        Text(AppStrings.noAccount)
                    }
                }

                Section("Note") {
                    TextField("Note", text: $note, axis: .horizontal)
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit transaction" : "Add transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditing ? "Save" : "Add") {
                        save()
                    }
                    .disabled(viewModel.isSaving)
                }
            }
            .onAppear {
                if let tx = transaction {
                    title = tx.title
                    category = tx.category.isEmpty ? "Others" : tx.category
                    amountText = String(tx.amount)
                    isIncome = tx.isIncome
                    date = tx.date
                    note = tx.note
                    paidTo = tx.paidTo
                    paidWith = tx.paidWith
                }
            }
        }
    }

    private func save() {
        guard let amount = Double(amountText) else {
            viewModel.errorMessage = AppStrings.inValidAmt
            return
        }
        let ok: Bool
        if let tx = transaction {
            ok = viewModel.updateTransaction(
                tx, title: title, category: category,
                amount: amount, isIncome: isIncome, date: date,
                note: note, paidTo: paidTo, paidWith: paidWith
            )
        } else {
            ok = viewModel.addTransaction(
                title: title, category: category,
                amount: amount, isIncome: isIncome, date: date,
                note: note, paidTo: paidTo, paidWith: paidWith
            )
        }
        if ok { dismiss() }
    }
}
