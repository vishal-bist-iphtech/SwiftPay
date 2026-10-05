//
//  ContentView.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 18/09/26.
//

import SwiftUI
import CoreData

struct ContentView: View {

    @StateObject private var router: AppRouter
    @StateObject private var session: AppSession
    @StateObject private var authVM: AuthViewModel
    @StateObject private var accountStore: AccountStore
    @StateObject private var dashboardVM: DashboardViewModel
    @StateObject private var transferVM: TransferViewModel
    @StateObject private var spendingVM: SpendingViewModel
    @StateObject private var bankDetailsVM: BankDetailsViewModel
    @StateObject private var userDetailsVM: UserDetailsViewModel
    @StateObject private var transactionVM: TransactionViewModel
    @StateObject private var theme: ThemeManager
    @StateObject private var notifications: NotificationService

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        let session = AppSession()
        let store = AccountStore(context: context, session: session)
        let notifications = NotificationService()
        _session = StateObject(wrappedValue: session)
        _authVM = StateObject(wrappedValue: AuthViewModel())
        _accountStore = StateObject(wrappedValue: store)
        _dashboardVM = StateObject(wrappedValue: DashboardViewModel(store: store))
        _transferVM = StateObject(wrappedValue: TransferViewModel(store: store, session: session, notifications: notifications))
        _spendingVM = StateObject(wrappedValue: SpendingViewModel(store: store))
        _bankDetailsVM = StateObject(wrappedValue: BankDetailsViewModel(store: store))
        _userDetailsVM = StateObject(wrappedValue: UserDetailsViewModel(session: session))
        _transactionVM = StateObject(wrappedValue: TransactionViewModel(session: session, store: store))
        _router = StateObject(wrappedValue: AppRouter())
        _theme = StateObject(wrappedValue: ThemeManager())
        _notifications = StateObject(wrappedValue: notifications)
    }

    var body: some View {

            RootView()
            .environmentObject(router)
            .environmentObject(session)
            .environmentObject(authVM)
            .environmentObject(dashboardVM)
            .environmentObject(transferVM)
            .environmentObject(spendingVM)
            .environmentObject(bankDetailsVM)
            .environmentObject(userDetailsVM)
            .environmentObject(transactionVM)
            .environmentObject(accountStore)
            .environmentObject(theme)
            .environmentObject(notifications)
            .onAppear {
                notifications.requestPermissionIfNeeded()
            }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext,
                      PersistenceController.preview.container.viewContext)
}
