//
//  DashboardView.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 21/09/26.
//

import SwiftUI
import CoreData

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
                                Image("demo_profile_image")
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
                                    .overlay(
                                        Circle().stroke(Color("mutedText"), lineWidth: 1)
                                    )
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
                        
                        CreditCard(
                            balance: viewModel.balance,
                            bank: viewModel.bankName,
                            maskedNumber: viewModel.maskedAccountNumber
                        )
                        
                    }
                    
                    Spacer(minLength: 30)
                        
                        
                    // MARK: Quick Actions
                    HStack(spacing: 12) {
                        
                        QuickAction(
                            title: "Add account",
                            icon: "plus"
                        )
                        
                        NavigationLink {
                            TransferView()
                        } label: {
                            QuickAction(
                                title: "Transfer",
                                icon: "arrow.up.right"
                            )
                        }
                                               
                        QuickAction(
                            title: "More",
                            icon: "square.grid.2x2"
                        )
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
                    }
                    .padding(.top, 20)
                    
                    HStack(spacing: 4) {
                        
                        if viewModel.hasContacts {
                            ForEach(viewModel.contacts.prefix(4)) { contact in
                                RecentTransfer(
                                    name: contact.name,
                                    icon: "person.fill"
                                )
                            }
                            
                            RecentTransfer(
                                name: "More",
                                icon: "chevron.down"
                            )
                        } else {
                            // Empty state — keeps layout height stable.
                            VStack(spacing: 4) {
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .font(.title)
                                    .foregroundStyle(Color("mutedText"))
                                    .frame(width: 70, height: 70)
                                    .background(Color("surface"))
                                    .clipShape(Circle())
                                
                                Text(AppStrings.emptyStateNoContacts)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color("mutedText"))
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 4)
                        }
                    }
                    .padding(.top, 10)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.hasContacts)
                    
                    
                    // MARK: Transactions
                    
                    HStack {
                        
                        Text("Transactions")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(
                                Color("primaryText")
                            )
                        
                        Spacer()
                        
                        Text("See all")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundStyle(
                                Color("mutedText")
                            )
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 12) {
                        
                        if viewModel.hasTransactions {
                            ForEach(viewModel.transactions) { transaction in
                                
                                TransactionRow(
                                    transaction: transaction
                                )
                            }
                        } else {
                            // Empty state with icon + hint instead of a bare label.
                            VStack(spacing: 8) {
                                Image(systemName: "tray")
                                    .font(.title)
                                    .foregroundStyle(Color("mutedText"))
                                
                                Text(AppStrings.emptyStateNoTransactions)
                                    .font(.headline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(Color("primaryText"))
                                
                                Text(AppStrings.emptyStateNoTransactionsHint)
                                    .font(.subheadline)
                                    .foregroundStyle(Color("mutedText"))
                            }
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, 20)
                            .background(Color("surface").opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                    }
                    .padding(.top, 4)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.hasTransactions)
                }
                .padding(.horizontal, 20)
            }
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    
    let context = PersistenceController.preview.container.viewContext
    
    DashboardView()
        .environmentObject(AppSession())
        .environmentObject(DashboardViewModel(context: context))
}
