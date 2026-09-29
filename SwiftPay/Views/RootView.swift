//
//  RootView.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 18/09/26.
//

import SwiftUI
import CoreData

struct RootView: View {
    
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        
        Group {
            
            // AppRouter switch
            switch router.screen {
                
            case .splash:
                SplashScreenView()
            case .landing:
                LandingScreenView()
            case .login:
                LoginView()
            case .signup:
                SignupView()
            case .main:
                DashboardView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let session = AppSession()
    let store = AccountStore(context: context, session: session)
    return RootView()
        .environmentObject(AppRouter())
        .environmentObject(session)
        .environmentObject(AuthViewModel(context: context))
        .environmentObject(DashboardViewModel(store: store, context: context))
        .environmentObject(TransferViewModel(store: store, session: session))
        .environmentObject(SpendingViewModel(store: store))
        .environmentObject(BankDetailsViewModel(store: store))
        .environmentObject(UserDetailsViewModel(context: context, session: session))
        .environmentObject(store)
        .environment(
            \.managedObjectContext,
            context
        )
}
