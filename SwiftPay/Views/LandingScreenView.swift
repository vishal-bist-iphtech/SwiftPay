//
//  LandingScreenView.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 18/09/26.
//

import SwiftUI

struct LandingScreenView: View {
    
    @EnvironmentObject var router: AppRouter
    
    var body: some View {
        
        ZStack {
            
            Color("background")
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Spacer(minLength: 40)
                    
                    // App logo
                    HStack {
                        
                        Image(systemName: "wallet.bifold.fill")
                            .font(.largeTitle)
                            .foregroundStyle(Color("accentColor"))
                        
                        Text("SwiftPay")
                            .font(.title.bold())
                            .foregroundStyle(Color("primaryText"))
                    }
                    
                    Spacer(minLength: 40)
                    
                    Text("Your Money")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(Color("primaryText"))
                    
                    Text("Your Control")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundStyle(Color("accentColor"))
                    
                    Text(
                        "Track spending, manage your budget, "
                        + "and understand your finances in one place."
                    )
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundStyle(Color("secondaryText"))
                    .lineSpacing(5)
                    .padding(.top, 8)
                    
                    // MARK: Credit card preview                   
                    Image("credit-card")
                        .resizable()
                        .scaledToFit()
                        .padding(.top, 40)
                        .shadow(color: .white, radius: 2, x: 0, y: 2)
                    
                    Spacer(minLength: 40)
                    
                    Button {
                        router.screen = .auth
                    } label: {
                        
                        Text("Get Started")
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(Color("accentColor"))
                            .clipShape(
                                RoundedRectangle(cornerRadius: 18)
                            )
                    }
                    
                    Button {
                        router.screen = .auth
                    } label: {
                        
                        Text("Already have an account?")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(Color("secondaryText"))
                            .frame(maxWidth: .infinity)
                            .padding(.top, 20)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
            }
        }
        
    }
}


#Preview {
    LandingScreenView()
}
