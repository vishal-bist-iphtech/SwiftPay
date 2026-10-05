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
    @EnvironmentObject var theme: ThemeManager
    @EnvironmentObject var notifications: NotificationService

    @State private var showLogoutConfirm = false
    @State private var showDeleteConfirm = false
    @State private var showDeleteError = false

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

                        profileAvatar
                            

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

                        NavigationLink {
                            UserDetailsView()
                        } label: {
                            ProfileRow(
                                icon: "person.fill",
                                title: "Personal details",
                                subtitle: "Name, email, phone"
                            )
                        }
                        .buttonStyle(.plain)

                        NavigationLink {
                            BankDetailsView()
                        } label: {
                            ProfileRow(
                                icon: "building.columns.fill",
                                title: "Bank accounts & cards",
                                subtitle: "Manage linked accounts"
                            )
                        }
                        .buttonStyle(.plain)

                    }

                    // MARK: Preferences section
                    ProfileSection(title: "Preferences") {
                        
                        ProfileToggleRow(
                            icon: "bell.fill",
                            title: "Push notifications",
                            isOn: $notifications.isPushEnabled
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
                            isOn: $theme.isDarkMode
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

                        Button {
                            showDeleteConfirm = true
                        } label: {
                            ProfileRow(
                                icon: "exclamationmark.triangle.fill",
                                title: "Delete Account",
                                subtitle: "Delete your swiftpay account"
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(authVM.isDeletingAccount)

                    }

                    // MARK: Support section
                    
                    ProfileSection(title: "Support") {
                        
                        NavigationLink {
                            HelpCenterView()
                        } label: {
                            ProfileRow(
                                icon: "questionmark.circle.fill",
                                title: "Help center"
                            )
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink {
                            TermsPrivacyView()
                        } label: {
                            ProfileRow(
                                icon: "doc.fill",
                                title: "Terms & privacy"
                            )
                        }
                        .buttonStyle(.plain)
                        
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
                            Color("appRed")
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
        .alert("Log out?", isPresented: $showLogoutConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Log out", role: .destructive) {
                logout()
            }
        } message: {
            Text(AppStrings.logoutMessage)
        }
        .alert("Delete account?", isPresented: $showDeleteConfirm) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteAccount()
            }
        } message: {
            Text(AppStrings.deleteAccountMessage)
        }
        .alert("Could not delete account", isPresented: $showDeleteError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(authVM.errorMessage ?? AppStrings.deleteAccountFailed)
        }
    }

    private func logout() {
        // Single VM intent — session clear + form reset + routing live in AuthViewModel.
        authVM.handleLogout(session: session, router: router)
    }

    private func deleteAccount() {
        // Session clear + routing live in AuthViewModel; store/VMs observe
        // the session change and empty themselves. Stays on profile on failure.
        let ok = authVM.handleDeleteAccount(session: session, router: router)
        if !ok {
            showDeleteError = true
        }
    }

    /// Avatar backed by Core Data `profileImage` when present.
    @ViewBuilder
    private var profileAvatar: some View {
        if let data = session.currentUser?.profileImage,
           let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .background(Color("surface"))
                .clipShape(Circle())
        } else {
            Image("demo_image1")
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .background(Color("surface"))
                .clipShape(Circle())
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let session = AppSession()
    let store = AccountStore(context: context, session: session)
    return NavigationStack {
        ProfileView()
    }
    .environmentObject(session)
    .environmentObject(AppRouter())
    .environmentObject(AuthViewModel())
    .environmentObject(BankDetailsViewModel(store: store))
    .environmentObject(UserDetailsViewModel(session: session))
    .environmentObject(ThemeManager())
    .environmentObject(NotificationService())
    .environment(\.managedObjectContext, context)
}
