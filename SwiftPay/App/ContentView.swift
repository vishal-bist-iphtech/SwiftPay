//
//  ContentView.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 18/09/26.
//

import SwiftUI
import CoreData

struct ContentView: View {

    @StateObject private var router = AppRouter()
    @StateObject private var session = AppSession()
    @StateObject private var authVM: AuthViewModel
    @StateObject private var dashboardVM: DashboardViewModel

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        _authVM = StateObject(wrappedValue: AuthViewModel(context: context))
        _dashboardVM = StateObject(wrappedValue: DashboardViewModel(context: context))
    }

    var body: some View {

            RootView()
            .environmentObject(router)
            .environmentObject(session)
            .environmentObject(authVM)
            .environmentObject(dashboardVM)
            .onAppear {
                dashboardVM.observe(session: session)
            }
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext,
                      PersistenceController.preview.container.viewContext)
}
