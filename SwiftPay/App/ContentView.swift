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

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        let session = AppSession()
        let store = AccountStore(context: context, session: session)
        _session = StateObject(wrappedValue: session)
        _authVM = StateObject(wrappedValue: AuthViewModel(context: context))
        _accountStore = StateObject(wrappedValue: store)
        _dashboardVM = StateObject(wrappedValue: DashboardViewModel(store: store))
        _transferVM = StateObject(wrappedValue: TransferViewModel(store: store, session: session))
        _spendingVM = StateObject(wrappedValue: SpendingViewModel(store: store))
        _router = StateObject(wrappedValue: AppRouter())
    }

    var body: some View {

            RootView()
            .environmentObject(router)
            .environmentObject(session)
            .environmentObject(authVM)
            .environmentObject(dashboardVM)
            .environmentObject(transferVM)
            .environmentObject(spendingVM)
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext,
                      PersistenceController.preview.container.viewContext)
}
