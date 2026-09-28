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
    @Published var transferError: String?

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

    static let noRecipientMessage = "Please select a recipient."

    private let context: NSManagedObjectContext
    private let session: AppSession
    private var cancellables = Set<AnyCancellable>()

    init(context: NSManagedObjectContext, session: AppSession) {
        self.context = context
        self.session = session

        loadPrimaryAccount()

        // Stay in sync with login/logout without any View involvement.
        session.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadPrimaryAccount()
            }
            .store(in: &cancellables)
    }

    /// Reloads the primary account for the current session user.
    func refresh() {
        loadPrimaryAccount()
    }

    /// Starts a fresh transfer.
    func startNewTransfer(recipient: Contact? = nil) {
        selectedRecipient = recipient
        transferAmount = ""
        sentAmount = ""
        transferError = nil
        isProcessing = false
        showSuccess = false
        showingContactPicker = false
    }

    // MARK: - Recipient

    func selectRecipient(_ recipient: Contact) {
        selectedRecipient = recipient
        showingContactPicker = false
        if transferError == Self.noRecipientMessage {
            transferError = nil
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
            if transferError == "Insufficient balance." { transferError = nil }
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
        transferError = nil

        guard let recipient = selectedRecipient else {
            transferError = Self.noRecipientMessage
            return
        }

        guard let account = primaryAccount() else {
            transferError = "No account found. Please add an account first."
            return
        }

        guard isAmountValid, let amount = Double(transferAmount) else { return }

        guard amount <= balance else {
            transferError = "Insufficient balance."
            return
        }

        isProcessing = true
        let service = CoreDataService(context: context)

        // Simulating the API call, then committing to Core Data.
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            guard let self else { return }
            do {
                try service.TransferSuccess(
                    amount: amount,
                    from: account,
                    recipientName: recipient.name
                )
                self.sentAmount = self.transferAmount
                self.transferAmount = ""
                self.balance -= amount
                self.isProcessing = false
                self.showSuccess = true
            } catch {
                self.isProcessing = false
                self.transferError = error.localizedDescription
            }
        }
    }

    // MARK: - Private loading

    private func currentUser() -> UserEntity? {
        guard let user = session.currentUser else { return nil }
        return try? context.existingObject(with: user.objectID) as? UserEntity
    }

    private func primaryAccount() -> AccountEntity? {
        guard let user = currentUser() else { return nil }
        let request = NSFetchRequest<AccountEntity>(entityName: "AccountEntity")
        request.predicate = NSPredicate(format: "owner == %@", user)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \AccountEntity.createdAt, ascending: false)]

        do {
            let accounts = try context.fetch(request)
            return accounts.first(where: { $0.isPrimary }) ?? accounts.first
        } catch {
            print("Failed to load primary account:", error.localizedDescription)
            return nil
        }
    }

    private func loadPrimaryAccount() {
        guard let account = primaryAccount() else {
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
