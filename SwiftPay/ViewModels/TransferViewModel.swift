//
//  TransferViewModel.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 28/09/26.
//

import Foundation
import Combine
import CoreData


final class TransferViewModel: ObservableObject {

    // MARK: - Transfer input

    @Published var transferAmount = ""
    @Published var sentAmount = ""
    @Published var isProcessing = false
    @Published var showSuccess = false
    @Published var errorMessage: String?

    // MARK: - Recipient

    @Published var selectedRecipient: Contact?
    @Published var showingContactPicker = false

    // MARK: - Primary account

    @Published var bankName = "No account"
    @Published var maskedNumber = "••••• ••••"
    @Published var balance: Double = 0
    @Published var currencyCode = "USD"
    @Published var hasAccount = false

    var formattedAvailableBalance: String {
        AccountFormatting.formattedBalance(balance, currencyCode: currencyCode)
    }

    // Amount caps
    let intCap = 7
    let fraCap = 2

        private let store: AccountStore
    private let session: AppSession
    private var cancellables = Set<AnyCancellable>()

    init(store: AccountStore, session: AppSession) {
        self.store = store
        self.session = session

        mapPrimary(store.accounts)

        store.$accounts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.mapPrimary($0) }
            .store(in: &cancellables)

        // Clear any in-progress transfer (recipient, amount, errors) when
        // the user changes, so one account never sees another's draft.
        session.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.resetTransferState()
            }
            .store(in: &cancellables)
    }

    /// Reloads the primary account for the current session user.
    func refresh() {
        store.refresh()
    }

    /// Starts a fresh transfer.
    func startNewTransfer(recipient: Contact? = nil) {
        resetTransferState()
        selectedRecipient = recipient
    }

    // MARK: - Recipient

    func selectRecipient(_ recipient: Contact) {
        selectedRecipient = recipient
        showingContactPicker = false
        if errorMessage == AppStrings.noRecipient {
            errorMessage = nil
        }
    }

    // MARK: - Validation

    var isAmountValid: Bool {
        guard let value = Double(transferAmount) else { return false }
        return value > 0
    }

    var exceedsBalance: Bool {
        guard hasAccount, let amount = Double(transferAmount) else { return false }
        return amount > 0 && amount > balance
    }

    // MARK: - Amount

    func updateAmount(_ newValue: String) {
        transferAmount = sanitizedAmount(newValue)
        if let amount = Double(transferAmount), amount <= balance {
            if errorMessage == AppStrings.insufficientBal { errorMessage = nil }
        }
    }

    func sanitizedAmount(_ value: String) -> String {
        var filtered = value.filter { "0123456789".contains($0) || $0 == "." }
        let parts = filtered.split(separator: ".", omittingEmptySubsequences: false)
        if parts.count > 2 {
            filtered = String(parts[0]) + "." + parts[1...].joined()
        }

        if filtered.contains(".") {
            let amnt = filtered.split(separator: ".", omittingEmptySubsequences: false)
            var intPart = String(amnt[0])
            var fracPart = amnt.count > 1 ? String(amnt[1]) : ""
            if intPart.count > intCap { intPart = String(intPart.prefix(intCap)) }
            if fracPart.count > fraCap { fracPart = String(fracPart.prefix(fraCap)) }
            if amnt.count > 1 && fracPart.isEmpty && filtered.hasSuffix(".") {
                return intPart + "."
            }
            return intPart + "." + fracPart
        } else {
            if filtered.count > intCap {
                filtered = String(filtered.prefix(intCap))
            }
            return filtered
        }
    }

    // MARK: - Send

    func send() {
        guard !isProcessing else { return }
        errorMessage = nil

        guard let recipient = selectedRecipient else {
            errorMessage = AppStrings.noRecipient
            return
        }

        guard let account = store.accounts.first(where: { $0.isPrimary }) ?? store.accounts.first else {
            errorMessage = AppStrings.noAccount
            return
        }

        guard isAmountValid, let amount = Double(transferAmount) else { return }

        guard amount <= balance else {
            errorMessage = AppStrings.insufficientBal
            return
        }

        isProcessing = true

        // Simulating the API call, then committing to Core Data.
        // The store refetches once, which updates every observer.
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            guard let self else { return }
            do {
                try self.store.applyTransfer(
                    amount: amount,
                    from: account,
                    recipientName: recipient.name
                )
                self.sentAmount = self.transferAmount
                self.transferAmount = ""
                self.isProcessing = false
                self.showSuccess = true
            } catch {
                self.isProcessing = false
                self.errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Private

    private func resetTransferState() {
        selectedRecipient = nil
        transferAmount = ""
        sentAmount = ""
        errorMessage = nil
        isProcessing = false
        showSuccess = false
        showingContactPicker = false
    }

    private func mapPrimary(_ accounts: [AccountEntity]) {
        guard let account = accounts.first(where: { $0.isPrimary }) ?? accounts.first else {
            hasAccount = false
            bankName = "No account"
            maskedNumber = "••••• ••••"
            balance = 0
            currencyCode = "USD"
            return
        }

        hasAccount = true
        bankName = account.bankName ?? "No account"
        if let masked = account.maskedNumber, !masked.isEmpty {
            maskedNumber = masked
        } else if let number = account.accountNumber, !number.isEmpty {
            maskedNumber = AccountFormatting.maskedAccountNumber(number)
        } else {
            maskedNumber = "••••• ••••"
        }
        balance = (account.balance as NSDecimalNumber?)?.doubleValue ?? 0
        currencyCode = account.currencyCode ?? "USD"
    }
}
