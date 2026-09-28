//
//  ProfileView.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 23/09/26.
//

import SwiftUI
import CoreData

struct ProfileView: View {

    @EnvironmentObject var session: AppSession
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var authVM: AuthViewModel

    @State private var pushNotifications = true
    @State private var darkMode = true
    @State private var showLogoutConfirm = false

    var body: some View {

        ZStack {

            Color("background")
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {

                VStack(alignment: .leading, spacing: 0) {

                    // MARK: Header
                    HStack {
                        Text("Profile")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(Color("primaryText"))
                    }
                    .padding(.top, 8)

                    // MARK: User card
                    HStack(spacing: 14) {

                        Image("demo_profile_image")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 64, height: 64)
                            .background(Color("surface"))
                            .clipShape(Circle())
                            .overlay(
                                Circle().stroke(Color("mutedText"), lineWidth: 1)
                            )

                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.currentUser?.name ?? "SwiftPay User")
                                .font(.title3.bold())
                                .foregroundStyle(Color("primaryText"))

                            Text(session.currentUser?.email ?? "example@email.com")
                                .font(.subheadline)
                                .foregroundStyle(Color("secondaryText"))

                            if let phone = session.currentUser?.phone, !phone.isEmpty {
                                Text("+\(phone)")
                                    .font(.caption)
                                    .foregroundStyle(Color("mutedText"))
                            }
                        }

                        Spacer()
                    }
                    .padding(16)
                    .glassEffect(.regular, in: .rect)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 22)
                    )
                    .padding(.top, 16)

                    // MARK: Account
                    ProfileSection(title: "Account") {
                        
                        ProfileRow(
                            icon: "person.fill",
                            title: "Personal details",
                            subtitle: "Name, email, phone"
                        )
                        
                        ProfileRow(
                            icon: "building.columns.fill",
                            title: "Bank accounts & cards",
                            subtitle: "Manage linked accounts"
                        )
                        
                    }

                    // MARK: Preferences section
                    ProfileSection(title: "Preferences") {
                        
                        ProfileToggleRow(
                            icon: "bell.fill",
                            title: "Push notifications",
                            isOn: $pushNotifications
                        )
                        
                        ProfileRow(
                            icon: "textformat.size",
                            title: "Language",
                            subtitle: "Select your language",
                            value: "Eng"
                        )
                        
                        ProfileToggleRow(
                            icon: "moon.fill",
                            title: "Dark mode",
                            isOn: $darkMode
                        )
                    }

                    // MARK: Security section
                    
                    ProfileSection(title: "Security") {
                        
                        ProfileRow(
                            icon: "lock.fill",
                            title: "Change PIN",
                            subtitle: "Update your transaction PIN"
                        )
                        
                        ProfileRow(
                            icon: "shield.fill",
                            title: "Privacy",
                            subtitle: "Control your data"
                        )
                        
                        ProfileRow(
                            icon: "exclamationmark.triangle.fill",
                            title: "Delete Account",
                            subtitle: "Delete your swiftpay account"
                        )
                        
                    }

                    // MARK: Support section
                    
                    ProfileSection(title: "Support") {
                        
                        ProfileRow(
                            icon: "questionmark.circle.fill",
                            title: "Help center"
                        )
                        
                        ProfileRow(
                            icon: "doc.fill",
                            title: "Terms & privacy"
                        )
                        
                        ProfileRow(
                            icon: "info.circle.fill",
                            title: "About SwiftPay",
                            value: "v1.0"
                        )
                        
                    }

                    // MARK: Logout
                    
                    Button {
                        showLogoutConfirm = true
                    } label: {
                        HStack {
                            Spacer()
                            
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.title3)
                            
                            Text("Log out")
                                .font(.title3)
                            
                            Spacer()
                        }
                        .foregroundStyle(.white)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            Color("red")
                        )
                        .clipShape(
                            RoundedRectangle(cornerRadius: 18)
                        )
                    }
                    .padding(.top, 24)
                    
                    Text("SwiftPay v1.0")
                        .font(.caption)
                        .foregroundStyle(
                            Color("mutedText")
                        )
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 16)
                        .padding(.bottom, 30)
                }
                .padding(.horizontal, 20)
            }
        }
        .preferredColorScheme(.dark)
        .alert("Log out?", isPresented: $showLogoutConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Log out", role: .destructive) {
                logout()
            }
        } message: {
            Text(AppStrings.logoutMessage)
        }
    }

    private func logout() {
        // Single VM intent — session clear + form reset + routing live in AuthViewModel.
        authVM.handleLogout(session: session, router: router)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppSession())
        .environmentObject(AppRouter())
        .environmentObject(AuthViewModel(context: PersistenceController.preview.container.viewContext))
}
