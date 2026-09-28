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
    @StateObject private var dashboardVM: DashboardViewModel
    @StateObject private var transferVM: TransferViewModel
    @StateObject private var spendingVM: SpendingViewModel

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        let session = AppSession()
        _session = StateObject(wrappedValue: session)
        _authVM = StateObject(wrappedValue: AuthViewModel(context: context))
        _dashboardVM = StateObject(wrappedValue: DashboardViewModel(context: context, session: session))
        _transferVM = StateObject(wrappedValue: TransferViewModel(context: context, session: session))
        _spendingVM = StateObject(wrappedValue: SpendingViewModel(context: context, session: session))
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
