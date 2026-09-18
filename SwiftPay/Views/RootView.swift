//
//  RootView.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 18/09/26.
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        
        Group {
            
            switch router.screen {
                
            case .splash:
                SplashScreenView()
            case .landing:
                LandingScreenView()
            case .auth:
                AuthView()
            }
        }
        .preferredColorScheme(.dark)
    }
}
