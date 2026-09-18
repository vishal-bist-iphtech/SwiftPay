//
//  AuthView.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 18/09/26.
//

import SwiftUI

struct AuthView: View {
    
    @EnvironmentObject var router: AppRouter
    
    @StateObject private var authvm = AuthViewModel()
    
    var body: some View {
        
        ZStack {
            
            Color("background")
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                
                VStack(alignment: .leading, spacing: 0) {
                    
                    Button {
                        router.screen = .landing
                    } label: {
                        
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color("primaryText"))
                            .frame(width: 42, height: 42)
                            .background(Color("surface"))
                            .clipShape(Circle())
                    }
                    
                    Text(authvm.isLogin
                         ? "Welcome back."
                         : "Create account.")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(Color("primaryText"))
                    padding(.top, 40)
                    
                    Text(authvm.isLogin
                         ? "Sign in to continue managing your money."
                         : "Start taking control of you finances.")
                    .font(.system(size: 15))
                    .foregroundStyle(Color("secondaryText"))
                    .padding(.top, 10)
                    
                    HStack(spacing: 0) {
                        
                        AuthButton(
                            title: "Login",
                            selected: authvm.isLogin
                        ) {
                            authvm.isLogin = true
                        }
                        
                        AuthButton(
                            title: "Sign up",
                            selected: !authvm.isLogin
                        ) {
                            authvm.isLogin = false
                        }
                    }
                    .padding(4)
                    .background(Color("surface"))
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )
                    .padding(.top, 32)
                    
                    VStack(spacing: 16) {
                        
                        if !authvm.isLogin {
                            
                            LabelField(
                                title: "Full name",
                                text: $authvm.name,
                                icon: "person"
                            )
                            
                            LabelField(
                                title: "Email",
                                text: $authvm.email,
                                icon: "envelope",
                                keyboardType: .emailAddress
                            )
                        }
                        
                        LabelField(
                            title: "Phone",
                            text: $authvm.phone,
                            icon: "phone",
                            keyboardType: .numberPad
                        )
                        
                        PasswordField(
                            title: "Password",
                            text: $authvm.password,
                            icon: "lock"
                        )
                    }
                    .padding(.top, 30)
                    
                    if let error = authvm.errorMessage {
                        
                        Text(error)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color("accentColor"))
                            .padding(.top, 12)
                    }
                    
                    Button {
                        
                        if authvm.submit() {}
                    } label: {
                            
                            Text(authvm.isLogin ? "Login" : "Create Account")
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(Color("accentColor"))
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 18)
                                )
                        }
                        .padding(.top, 28)
                    }
                    .padding(24)
            }
        }
    }
}
