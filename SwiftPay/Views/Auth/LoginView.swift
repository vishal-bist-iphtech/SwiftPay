//
//  AuthView.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 18/09/26.
//

import SwiftUI
import CoreData

struct LoginView: View {
    
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var session: AppSession
    @EnvironmentObject var viewModel: AuthViewModel
    
    
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
                    
                    Spacer(minLength: 40)
                    
                    // App logo
                    HStack{
                            
                            Image(systemName: "wallet.bifold.fill")
                                .font(.largeTitle)
                                .foregroundStyle(Color("accentColor"))
                            
                            Text("SwiftPay")
                                .font(.title.bold())
                                .foregroundStyle(Color("primaryText"))
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    
                    Spacer(minLength: 40)
                    
                    Text(AppStrings.asHeading)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color("primaryText"))
                    .padding(.top, 30)
                    
                    Text(AppStrings.asSubheading)
                    .font(.system(size: 15))
                    .foregroundStyle(Color("secondaryText"))
                    .padding(.top, 10)
                    
                    
                    VStack(alignment: .leading, spacing: 10) {
                                                
                        LabelField(
                            placeholder: "Phone Number",
                            text: $viewModel.phone,
                            icon: "phone",
                            keyboardType: .numberPad
                        )
                    }
                    .padding(.top, 32)
                    
                    if let error = viewModel.errorMessage {
                        
                        Text(error)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color("accentColor"))
                            .padding(.top, 12)
                    }
                    
                    Button {
                        
                        // Single VM intent — validation + routing live in AuthViewModel.
                        viewModel.handleLoginTapped(session: session, router: router)
                        
                    } label: {
                            
                            Text("Continue")
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

#Preview {
    LoginView()
        .environmentObject(AppRouter())
        .environmentObject(AppSession())
        .environmentObject(AuthViewModel(context: PersistenceController.preview.container.viewContext))
        .environment(
            \.managedObjectContext,
            PersistenceController.preview.container.viewContext
        )
}
