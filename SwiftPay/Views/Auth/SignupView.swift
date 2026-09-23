//
//  SignupView.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 21/09/26.
//

import SwiftUI
import CoreData

struct SignupView: View {
    
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var session: AppSession
    @EnvironmentObject var viewModel: AuthViewModel
   
    
    var body: some View {
        
        ZStack {
            
            Color("background")
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
            
                VStack(alignment: .leading, spacing: 16) {
                    
                    Spacer(minLength: 20)
                    
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
                    .padding(.top, 24)
                    
                    Spacer(minLength: 20)

                    // MARK: Heading
                    
                    Text(AppStrings.ssHeading)
                        .font(
                            .system(
                                size: 28,
                                weight: .bold
                            )
                        )
                        .foregroundStyle(
                            Color("primaryText")
                        )
                    
                    Text(AppStrings.ssSubheading)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(
                        Color("secondaryText")
                    )
                    .lineSpacing(4)
                    .padding(.top, 8)
                    
                    // MARK: Name
                    
                    LabelField(
                        placeholder: "Your name",
                        text: $viewModel.name,
                        icon: "person"
                    )
                    .padding(.top, 20)
                    
                    // MARK: Email
                    
                    LabelField(
                        placeholder: "example@email.com",
                        text: $viewModel.email,
                        icon: "envelope",
                        keyboardType: .emailAddress
                    )
                    .padding(.top, 16)
                    
                    // MARK: Error
                    
                    if let error = viewModel.errorMessage {
                        
                        Text(error)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(
                                Color("accentColor")
                            )
                            .padding(.top, 10)
                    }
                    
                    
                    
                    Spacer(minLength: 20)

                    // MARK: Create Button
                    Button {
                        
                        guard let user = viewModel.signup()
                        else {return}
                        
                        session.login(user: user)
                        
                        router.screen = .main
                        
                    } label: {
                        
                        Text("Create account")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                Color("accentColor")
                            )
                            .clipShape(
                                RoundedRectangle(
                                    cornerRadius: 18
                                )
                            )
                    }
                }
                .padding(24)
            }
        }
    }
}

#Preview {
    SignupView()
    .environmentObject(AppRouter())
    .environmentObject(AppSession())
    .environmentObject(AuthViewModel(context: PersistenceController.preview.container.viewContext))
}
