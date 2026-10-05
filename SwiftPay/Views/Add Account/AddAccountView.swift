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
    @EnvironmentObject var viewModel: DashboardViewModel

    @State private var selectedType: AddAccountType = .bank
    @State private var bank: String = ""
    @State private var accountNumber: String = ""
    @State private var accountName: String = ""
    @State private var lastFour: String = ""
    @State private var cvvNumber: String = ""
    @State private var cardNetwork: String = ""

    @State private var errorMessage: String?
    @State private var isSaving = false
    @State private var hasAttemptedSave = false

    @FocusState private var focusedField: AddAccountField?

    var onSave: (() -> Void)? = nil

    var body: some View {

        ZStack {

            Color("background")
                .ignoresSafeArea()
                .onTapGesture {
                    focusedField = nil
                }

            ScrollView(showsIndicators: false) {

                VStack(alignment: .leading, spacing: 0) {

                    Text(AppStrings.aaHeading)
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(Color("primaryText"))

                    Text(AppStrings.aaSubheading)
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

                    TextField("", text: $accountNumber, prompt: Text("Account number (12–19 digits)").foregroundStyle(Color("mutedText")))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color("primaryText"))
                        .keyboardType(.numberPad)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .accountNumber)
                        .onSubmit { focusedField = .accountName }
                        .onChange(of: accountNumber) { _, newValue in
                            let digits = newValue.filter(\.isNumber)
                            let capped = String(digits.prefix(19))
                            if capped != newValue { accountNumber = capped }
                            if hasAttemptedSave { errorMessage = validationError() }
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 52)
                        .background(Color("surface"))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(fieldBorderColor(for: accountNumberError), lineWidth: 1)
                        }
                        .padding(.top, 10)

                    if let err = inlineError(accountNumberError, isEmpty: accountNumber.isEmpty) {
                        fieldErrorText(err)
                    }

                    // MARK: Bank
                    FieldLabel("Bank")
                        .padding(.top, 18)

                   DropdownField(value: bank, placeholder: "Select your bank") {
                        ForEach(viewModel.Banks, id: \.self) { item in
                            Button(item) {
                                bank = item
                                if hasAttemptedSave { errorMessage = validationError() }
                            }
                        }
                    }
                    .padding(.top, 10)

                    if let err = inlineError(bankError, isEmpty: bank.isEmpty) {
                        fieldErrorText(err)
                    }

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
                        .onChange(of: accountName) { _, _ in
                            if hasAttemptedSave { errorMessage = validationError() }
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 52)
                        .background(Color("surface"))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(fieldBorderColor(for: accountNameError), lineWidth: 1)
                        }
                        .padding(.top, 10)

                    if let err = inlineError(accountNameError, isEmpty: accountName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) {
                        fieldErrorText(err)
                    }


                    // MARK: Card details
                    CardDetails(
                        lastFour: $lastFour,
                        cvvNumber: $cvvNumber,
                        cardNetwork: $cardNetwork,
                        cardNetworks: viewModel.CardNetworks,
                        focusedField: $focusedField
                    )
                    .padding(.top, 16)
                    .onChange(of: lastFour) { _, _ in
                        if hasAttemptedSave { errorMessage = validationError() }
                    }
                    .onChange(of: cvvNumber) { _, _ in
                        if hasAttemptedSave { errorMessage = validationError() }
                    }
                    .onChange(of: cardNetwork) { _, _ in
                        if hasAttemptedSave { errorMessage = validationError() }
                    }

                    if let err = inlineError(lastFourError, isEmpty: lastFour.isEmpty) {
                        fieldErrorText(err)
                    }
                    if let err = inlineError(cvvError, isEmpty: cvvNumber.isEmpty) {
                        fieldErrorText(err)
                    }
                    if let err = inlineError(cardNetworkError, isEmpty: cardNetwork.isEmpty) {
                        fieldErrorText(err)
                    }

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
        }
    }

    // MARK: - Validation

    private var isFormValid: Bool {
        validationError() == nil
    }

    private var accountNumberError: String? {
        let digits = accountNumber.filter(\.isNumber)
        if digits.isEmpty { return AppStrings.inValidAcc }
        if digits.count < 12 || digits.count > 19 { return AppStrings.inValidAcc }
        if digits != accountNumber && !accountNumber.isEmpty {
            // Contains non-digits (will be stripped) — still invalid until cleaned.
            return AppStrings.inValidAcc
        }
        if isDuplicateAccountNumber(digits) { return AppStrings.duplicateAccount }
        return nil
    }

    private var bankError: String? {
        if bank.isEmpty { return AppStrings.selectBank }
        if !viewModel.Banks.contains(bank) { return AppStrings.invalidBank }
        return nil
    }

    private var accountNameError: String? {
        let trimmed = accountName.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return AppStrings.noAccName }
        if !isValidAccountName(trimmed) { return AppStrings.inValidName }
        return nil
    }

    private var lastFourError: String? {
        let digits = lastFour.filter(\.isNumber)
        if digits.count != 4 { return AppStrings.last4digits }
        let acctDigits = accountNumber.filter(\.isNumber)
        if acctDigits.count >= 4, String(acctDigits.suffix(4)) != digits {
            return AppStrings.last4Mismatch
        }
        return nil
    }

    private var cvvError: String? {
        let digits = cvvNumber.filter(\.isNumber)
        if digits.count < 3 || digits.count > 4 { return AppStrings.invalidCVVLength }
        return nil
    }

    private var cardNetworkError: String? {
        if cardNetwork.isEmpty { return AppStrings.selectCardNtw }
        if !viewModel.CardNetworks.contains(cardNetwork) { return AppStrings.invalidCardNtw }
        return nil
    }

    private func validationError() -> String? {
        if let err = accountNumberError { return err }
        if let err = bankError { return err }
        if let err = accountNameError { return err }
        if let err = lastFourError { return err }
        if let err = cvvError { return err }
        if let err = cardNetworkError { return err }
        return nil
    }

    private func isValidAccountName(_ name: String) -> Bool {
        guard (2...50).contains(name.count) else { return false }
        let allowed = CharacterSet.letters.union(.whitespaces)
        return name.unicodeScalars.allSatisfy { allowed.contains($0) }
    }

    private func isDuplicateAccountNumber(_ digits: String) -> Bool {
        guard let user = session.currentUser, let userId = user.id else { return false }
        let service = CoreDataService(context: viewContext)
        guard let current = service.fetchUser(id: userId) else { return false }
        return service.fetchAllAccounts(for: current).contains {
            ($0.accountNumber ?? "").filter(\.isNumber) == digits
        }
    }

    private func inlineError(_ error: String?, isEmpty: Bool) -> String? {
        guard let error else { return nil }
        // Show live once the user typed something, or after first save attempt.
        if hasAttemptedSave || !isEmpty { return error }
        return nil
    }

    private func fieldBorderColor(for error: String?) -> Color {
        if error != nil && hasAttemptedSave {
            return Color("accentColor").opacity(0.7)
        }
        return Color("border").opacity(0.3)
    }

    private func fieldErrorText(_ message: String) -> some View {
        Text(message)
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Color("accentColor"))
            .padding(.top, 6)
    }

    // MARK: - Core Data save

    private func saveAccount() {
        hasAttemptedSave = true
        errorMessage = nil

        if let validation = validationError() {
            errorMessage = validation
            return
        }

        guard let currentUser = session.currentUser else {
            errorMessage = AppStrings.notLoggedIn
            return
        }

        focusedField = nil
        isSaving = true

        DispatchQueue.main.async {
            let service = CoreDataService(context: viewContext)
            do {
                try service.createBankAccount(
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
    
    let context = PersistenceController.preview.container.viewContext
    let session = AppSession()
    let store = AccountStore(context: context, session: session)
    
    NavigationStack {
        AddAccountView()
            .environmentObject(AppSession())
            .environmentObject(DashboardViewModel(store: store))
            .environment(\.managedObjectContext, context)
    }
    .preferredColorScheme(.dark)
}
