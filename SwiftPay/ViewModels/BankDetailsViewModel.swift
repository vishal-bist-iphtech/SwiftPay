//
//  BankDetailsViewModel.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 29/09/26.
//

import Foundation
import Combine
import CoreData


final class BankDetailsViewModel: ObservableObject {

    @Published private(set) var accounts: [BankAccount] = []
    @Published var errorMessage: String?

    var hasAccounts: Bool { !accounts.isEmpty }
    var primaryRow: BankAccount? { accounts.first(where: \.isPrimary) ?? accounts.first }

    private let store: AccountStore
    private var cancellables = Set<AnyCancellable>()

    init(store: AccountStore) {
        self.store = store
        map(store.accounts)
        store.$accounts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.map($0) }
            .store(in: &cancellables)
    }

    /// Re-runs the shared AccountStore fetch.
    func refresh() {
        errorMessage = nil
        store.refresh()
    }

    /// Marks the selected account as primary. Store reloads on success.
    func setPrimary(_ selected : BankAccount) {
        guard !selected.isPrimary else { return }
        errorMessage = nil
        do {
            try store.setPrimaryAccount(id: selected.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Deletes the selected bank account.
    func delete(_ selected: BankAccount) {
        errorMessage = nil
        do {
            try store.deleteBankAccount(id: selected.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Private
    
    /// Primary first, then newest — so the primary badge is always on top.
    private func map(_ items: [AccountEntity]) {
        let sorted = items.sorted { lhs, rhs in
            if lhs.isPrimary != rhs.isPrimary { return lhs.isPrimary && !rhs.isPrimary }
            return (lhs.createdAt ?? .distantPast) > (rhs.createdAt ?? .distantPast)
        }
        accounts = sorted.map { BankAccount(id: $0.id ?? UUID(), account: $0) }
    }
}
