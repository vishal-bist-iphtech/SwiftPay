//
//  SplashScreenView.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 18/09/26.
//

import SwiftUI

struct SplashScreenView: View {
    
    @EnvironmentObject var router: AppRouter
    
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0.0
    
    var body: some View {
        
        ZStack {
            Color("background")
                .ignoresSafeArea()
            
            VStack(spacing: 14) {
                
                Image(systemName: "wallet.bifold.fill")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(Color("accentColor"))
                    .scaleEffect(scale)
                
                Text("SwiftPay")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color("primaryText"))
                
                Text("Spend Smarter.")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(Color("secondaryText"))
            }
            .opacity(opacity)
        }
        .task {
            withAnimation(.easeOut(duration: 0.7)) {
                scale = 1
                opacity = 1
            }
            
            try? await Task.sleep(for: .seconds(1.6))
            
            withAnimation(.easeInOut(duration: 0.45)) {
                router.screen = .landing
            }
        }
    }
}
