//
//  DashboardView.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 21/09/26.
//

import SwiftUI

struct DashboardView: View {
        
    @EnvironmentObject var session: AppSession
    @EnvironmentObject var viewModel: DashboardViewModel
    
    var body: some View {
        
        NavigationStack {
            
            ZStack{
                    
                LinearGradient(
                    colors: [Color.orange, Color("red").opacity(0.5), Color("background").opacity(0.7), Color("background"),Color("surface")],
                    startPoint: .topTrailing, endPoint: .bottomLeading
                )
                 .ignoresSafeArea()
                    
                ScrollView(showsIndicators: false) {
                    
                    VStack(alignment: .leading) {
                        
                        // MARK: Header
                            
                        HStack (spacing: 8) {

                            NavigationLink {
                                ProfileView()
                            } label: {
                                Image("demo_image1")
                                    .resizable()
                                    .scaledToFill()
                                    .font(.system(size: 50))
                                    .foregroundStyle(
                                        Color("primaryText")
                                    )
                                    .frame(width: 70, height: 70)
                                    .background(
                                        Color("surface")
                                    )
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Welcome, \(session.currentUser?.name ?? "user")")
                                    .font(.title2.bold())
                                    .foregroundStyle(
                                        Color("primaryText")
                                    )
                                
                                Text(session.currentUser?.email ?? "example@email.com")
                                    .font(.subheadline)
                            }
                            
                            Spacer()
                            
                            Button {
                                
                            } label: {
                                Image(systemName: "bell.fill")
                                    .font(.title)
                                    .foregroundStyle(
                                        Color("primaryText")
                                    )
                                    .frame(width: 50, height: 50)
                                    .padding(3)
                                    .glassEffect(in: .circle)
                                    .clipShape(Circle())
                            }
                        }
                        
                        Spacer(minLength: 20)
                        
                        // MARK: Credit card
                        
                        CreditCard()
                        
                    }
                    
                    Spacer(minLength: 30)
                        
                        
                    // MARK: Quick Actions
                    HStack(spacing: 12) {
                        
                        QuickAction(
                            title: "Add account",
                            icon: "plus"
                        )
                        
                        QuickAction(
                            title: "Transfer",
                            icon: "arrow.up.right"
                        )
                        
                        NavigationLink {
                            SpendingView()
                        } label:{
                            QuickAction(
                                title: "More",
                                icon: "square.grid.2x2"
                            )
                        }
                    }
                        
                    // MARK: Contacts
                    
                    HStack {
                        
                        Text("Quick Transfer")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(
                                Color("primaryText")
                            )
                        
                        Spacer()
                        
                        Text("View all")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundStyle(
                                Color("mutedText")
                            )
                    }
                    .padding(.top, 20)
                    
                    HStack(spacing: 4) {
                        
                        RecentTransfer(
                            name: "Emma",
                            icon: "person.fill",
                            image: "demo_image6"
                            
                        )
                        
                        RecentTransfer(
                            name: "James",
                            icon: "person.fill",
                            image: "demo_image7"
                        )
                        
                        RecentTransfer(
                            name: "Olivia",
                            icon: "person.fill",
                            image: "demo_image8"
                        )
                        
                        RecentTransfer(
                            name: "Jenny",
                            icon: "person.fill",
                            image: "demo_image5"
                        )
                        
                        RecentTransfer(
                            name: "Add",
                            icon: "plus",
                            image: "demo_image2"
                        )
                    }
                    .padding(.top, 10)
                    
                    
                    // MARK: Transactions
                    
                    HStack {
                        
                        Text("Transactions")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(
                                Color("primaryText")
                            )
                        
                        Spacer()
                        
                        Text("View all")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundStyle(
                                Color("mutedText")
                            )
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 12) {
                        
                        ForEach(viewModel.transactions) { transaction in
                            
                            TransactionRow(
                                transaction: transaction
                            )
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 20)
            }
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AppSession())
        .environmentObject(DashboardViewModel())
}
