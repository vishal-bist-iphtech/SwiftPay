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
    @Published var noteText = ""
    @Published var sentAmount = ""
    @Published var isProcessing = false
    @Published var showSuccess = false
    @Published var errorMessage: String?

    /// Max note length
    let noteCap = 140


    @Published var completedTransaction: Transaction?
    private var pendingCompletedTransaction: Transaction?

    // MARK: - Recipient

    @Published var selectedRecipient: Contact?
    @Published var showingAddContact = false

    /// Saved recipients from `ContactEntity`, most recent first.
    @Published var savedContacts: [Contact] = []

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
    private let coredata = CoreDataService.shared

    init(store: AccountStore, session: AppSession) {
        self.store = store
        self.session = session

        mapPrimary(store.accounts)
        mapContacts(store.contacts)

        store.$accounts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.mapPrimary($0) }
            .store(in: &cancellables)

        store.$contacts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.mapContacts($0) }
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
        showingAddContact = false
        if errorMessage == AppStrings.noRecipient {
            errorMessage = nil
        }
    }

    /// Adds a recipient to `ContactEntity`. Returns an error message, or nil
    /// on success (the new contact is auto-selected).
    @discardableResult
    func addContact(name: String, phone: String, image: Data? = nil) -> String? {
        guard let user = currentUser() else {
            return AppStrings.notLoggedIn
        }
        do {
            let entity = try coredata.createContact(name: name, phone: phone, image: image, owner: user)
            store.refresh()
            let contact = Contact(entity: entity)
            mapContacts(store.contacts)
            if !savedContacts.contains(contact) {
                savedContacts.insert(contact, at: 0)
            }
            selectedRecipient = contact
            showingAddContact = false
            if errorMessage == AppStrings.noRecipient {
                errorMessage = nil
            }
            return nil
        } catch {
            return error.localizedDescription
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

    // MARK: - Note

    func updateNoteText(_ newValue: String) {
        noteText = String(newValue.prefix(noteCap))
    }

    // MARK: - Amount

    func updateAmount(_ newValue: String) {        transferAmount = sanitizedAmount(newValue)
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

        guard let account = store.accounts.first(where: { $0.isPrimary }) ?? store.accounts.first
        else {return}

        guard isAmountValid,
              let amount = Double(transferAmount) else { return }

        guard amount <= balance else {
            errorMessage = AppStrings.insufficientBal
            return
        }

        let note = String(noteText.trimmingCharacters(in: .whitespacesAndNewlines).prefix(noteCap))
        isProcessing = true

        // Simulating the API call, then committing to Core Data.
        // The store refetches once, which updates every observer.
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) { [weak self] in
            guard let self else { return }
            do {
                let created = try self.store.applyMoneyTransfer(
                    amount: amount,
                    from: account,
                    recipientName: recipient.name,
                    note: note
                )
                self.pendingCompletedTransaction = Self.map(created)
                self.sentAmount = self.transferAmount
                self.transferAmount = ""
                self.noteText = ""
                self.isProcessing = false
                self.showSuccess = true
            } catch {
                self.isProcessing = false
                self.errorMessage = error.localizedDescription
            }
        }
    }

   
    /// Dashboard pushes the details screen; back returns to dashboard.
    func finishSuccess() {
        let pending = pendingCompletedTransaction
        pendingCompletedTransaction = nil
        if let tx = pending {
            completedTransaction = tx
        }
        DispatchQueue.main.async { [weak self] in
            self?.showSuccess = false
        }
    }

    /// Clears the pushed details state (e.g. when starting a new transfer).
    func clearCompletedTransaction() {
        completedTransaction = nil
        pendingCompletedTransaction = nil
    }

    // MARK: - Private

    /// Resolves the session user in this VM's Core Data context.
    private func currentUser() -> UserEntity? {
        guard let sessionUser = session.currentUser,
              let id = sessionUser.id else { return nil }
        return coredata.fetchUser(id: id)
    }

    /// Maps the created entity to the UI model (same fields as `TransactionViewModel.map`).
    private static func map(_ entity: TransactionEntity) -> Transaction {
        let amount: Double = {
            if let n = entity.amount as? NSDecimalNumber { return n.doubleValue }
            if let n = entity.amount as? NSNumber { return n.doubleValue }
            return 0
        }()
        return Transaction(
            id: entity.id ?? UUID(),
            title: entity.title ?? "",
            category: (entity.category?.isEmpty == false) ? entity.category! : "Money Transfer",
            amount: amount,
            isIncome: entity.isIncome,
            date: entity.date ?? Date(),
            status: (entity.status?.isEmpty == false) ? entity.status! : "Completed",
            note: entity.note ?? "",
            paidTo: entity.paidTo ?? "",
            paidWith: entity.paidWith ?? ""
        )
    }

    private func resetTransferState() {
        selectedRecipient = nil
        transferAmount = ""
        noteText = ""
        sentAmount = ""
        errorMessage = nil
        isProcessing = false
        showSuccess = false
        showingAddContact = false
        completedTransaction = nil
        pendingCompletedTransaction = nil
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

    /// Maps saved contacts (most recent first) for the recipient picker.
    private func mapContacts(_ entities: [ContactEntity]) {
        savedContacts = entities.map(Contact.init(entity:))
    }
}
