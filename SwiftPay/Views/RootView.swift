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
    RootView()
        .environmentObject(AppRouter())
        .environmentObject(AppSession())
        .environmentObject(AuthViewModel(context: PersistenceController.preview.container.viewContext))
        .environmentObject(DashboardViewModel(context: context))
        .environment(
            \.managedObjectContext,
            PersistenceController.preview.container.viewContext
        )
}
