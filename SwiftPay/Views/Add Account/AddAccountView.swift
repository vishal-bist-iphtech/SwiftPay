//
//  AddAccountView.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 28/09/26.
//

import SwiftUI
import CoreData


struct AddAccountView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var session: AppSession

    @State private var selectedType: AddAccountType = .bank
    @State private var bank: String = ""
    @State private var accountNumber: String = ""
    @State private var accountName: String = ""
    @State private var lastFour: String = ""
    @State private var cvvNumber: String = ""
    @State private var cardNetwork: String = ""

    @State private var errorMessage: String?
    @State private var isSaving = false

    @FocusState private var focusedField: AddAccountField?

    var onSave: (() -> Void)? = nil

    private let banks = ["State Bank of India", "HDFC Bank", "ICICI Bank", "Axis Bank"]
    private let cardNetworks = ["Visa", "Mastercard", "RuPay"]

    var body: some View {

        ZStack {

            Color("background")
                .ignoresSafeArea()
                .onTapGesture {
                    focusedField = nil
                }

            ScrollView(showsIndicators: false) {

                VStack(alignment: .leading, spacing: 0) {

                    Text("Connect your money")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(Color("primaryText"))

                    Text("Add an account to see your full financial picture in one place.")
                        .font(.system(size: 13))
                        .foregroundStyle(Color("secondaryText"))
                        .padding(.vertical, 6)

                    // MARK: Account type
                    HStack(spacing: 12) {
                        ForEach(AddAccountType.allCases) { type in
                            AccountType(
                                type: type,
                                selected: type == selectedType
                            ) {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    selectedType = type
                                }
                            }
                        }
                    }
                    .padding(.top, 10)

                    // MARK: Account Number
                    FieldLabel("Account Number")
                        .padding(.top, 18)

                    TextField("", text: $accountNumber, prompt: Text("Account number").foregroundStyle(Color("mutedText")))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color("primaryText"))
                        .keyboardType(.numberPad)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .accountNumber)
                        .onSubmit { focusedField = .accountName }
                        .onChange(of: accountNumber) { _, newValue in
                            let digits = newValue.filter(\.isNumber)
                            accountNumber = String(digits.prefix(16))
                            if digits.count >= 4 {
                                lastFour = String(digits.suffix(4).prefix(4))
                            }
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 52)
                        .background(Color("surface"))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color("border").opacity(0.3), lineWidth: 1)
                        }
                        .padding(.top, 10)

                    // MARK: Bank
                    FieldLabel("Bank")
                        .padding(.top, 18)

                   DropdownField(value: bank, placeholder: "Select your bank") {
                        ForEach(banks, id: \.self) { item in
                            Button(item) { bank = item }
                        }
                    }
                    .padding(.top, 10)

                    // MARK: Account name
                    FieldLabel("User Name")
                        .padding(.top, 18)

                    TextField("", text: $accountName, prompt: Text("Account holder name").foregroundStyle(Color("mutedText")))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color("primaryText"))
                        .keyboardType(.default)
                        .textContentType(.name)
                        .autocorrectionDisabled()
                        .submitLabel(.next)
                        .focused($focusedField, equals: .accountName)
                        .onSubmit { focusedField = .lastFour }
                        .padding(.horizontal, 16)
                        .frame(height: 52)
                        .background(Color("surface"))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color("border").opacity(0.3), lineWidth: 1)
                        }
                        .padding(.top, 10)


                    // MARK: Card details
                    CardDetails(
                        lastFour: $lastFour,
                        cvvNumber: $cvvNumber,
                        cardNetwork: $cardNetwork,
                        cardNetworks: cardNetworks,
                        focusedField: $focusedField
                    )
                    .padding(.top, 16)

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color("accentColor"))
                            .padding(.top, 12)
                    }

                    // MARK: Save
                    SaveButton(
                        isSaving: isSaving,
                        isEnabled: isFormValid
                    ) {
                        saveAccount()
                    }
                    .padding(.top, 22)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle("Add account")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {

                } label: {
                    Text("Help")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color("accentColor"))
                }
            }
            .sharedBackgroundVisibility(.hidden)

            // Dismisses the keyboard from any text field.
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    focusedField = nil
                }
                .font(.system(size: 15, weight: .semibold))
            }
        }
    }

    // MARK: - Validation

    private var isFormValid: Bool {
        validationError() == nil
    }

    private func validationError() -> String? {
        let numberDigits = accountNumber.filter(\.isNumber)
        if numberDigits.count < 8 {
            return "Enter a valid account number (min 8 digits)."
        }
        if bank.isEmpty {
            return "Please select your bank."
        }
        if accountName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Enter the account holder name."
        }
        if lastFour.filter(\.isNumber).count != 4 {
            return "Enter the last 4 digits of your card."
        }
        if cvvNumber.filter(\.isNumber).count < 3 {
            return "Enter a valid CVV."
        }
        if cardNetwork.isEmpty {
            return "Please select your card network."
        }
        return nil
    }

    // MARK: - Core Data save

    private func saveAccount() {
        errorMessage = nil

        if let validation = validationError() {
            errorMessage = validation
            return
        }

        guard let currentUser = session.currentUser else {
            errorMessage = "No logged-in user. Please log in again."
            return
        }

        focusedField = nil
        isSaving = true

        // Flush any pending keyboard state before hitting Core Data.
        DispatchQueue.main.async {
            let service = CoreDataService(context: viewContext)
            do {
                try service.createAccount(
                    for: currentUser,
                    accountNumber: accountNumber.filter(\.isNumber),
                    bankName: bank,
                    accountType: "saving",
                    balance: NSDecimalNumber(value: 6000),
                    currencyCode: "USD"
                )
                isSaving = false
                if let onSave {
                    onSave()
                } else {
                    dismiss()
                }
            } catch {
                isSaving = false
                errorMessage = "Could not save account. \(error.localizedDescription)"
            }
        }
    }
}


#Preview {
    NavigationStack {
        AddAccountView()
            .environmentObject(AppSession())
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
    .preferredColorScheme(.dark)
}
