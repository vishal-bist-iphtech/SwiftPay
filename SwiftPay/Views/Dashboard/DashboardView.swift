//
//  DashboardView.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 21/09/26.
//

import SwiftUI
import CoreData // Preview environment only; all Core Data work lives in the ViewModels.

struct DashboardView: View {

    @EnvironmentObject var session: AppSession
    @EnvironmentObject var viewModel: DashboardViewModel
    @EnvironmentObject var transferVM: TransferViewModel

    @State private var showTransfer = false
    
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
                                    .frame(width: 60, height: 60)
                                    .background(
                                        Color("surface")
                                    )
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            
                            VStack(alignment: .leading, spacing: 2) {
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
                                    .font(.title2)
                                    .foregroundStyle(
                                        Color("primaryText")
                                    )
                                    .frame(width: 40, height: 40)
                                    .padding(3)
                                    .glassEffect(in: .circle)
                                    .clipShape(Circle())
                            }
                        }
                        
                        Spacer(minLength: 20)
                        
                        // MARK: Credit card (ViewModel owns the Core Data values)

                        CreditCard(
                            balance: viewModel.primaryBalance,
                            currencyCode: viewModel.primaryCurrencyCode,
                            bank: viewModel.primaryBankName,
                            accountNumber: "",
                            maskedNumber: viewModel.primaryMaskedNumber
                        )
                        
                    }
                    
                    Spacer(minLength: 30)
                        
                        
                    // MARK: Quick Actions
                    HStack(spacing: 12) {

                        // add account
                        NavigationLink {
                            AddAccountView()
                        } label: {
                            QuickAction(
                                title: "Add account",
                                icon: "plus"
                            )
                        }

                        // transfer money (fresh transfer, no preselected recipient)
                        Button {
                            transferVM.startNewTransfer()
                            showTransfer = true
                        } label: {
                            QuickAction(
                                title: "Transfer",
                                icon: "arrow.up.right"
                            )
                        }
                        .buttonStyle(.plain)
                        
                        // spending
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
                    }
                    .padding(.top, 20)
                    
                    HStack(spacing: 4) {

                        ForEach(Contact.all) { contact in
                            Button {
                                transferVM.startNewTransfer(recipient: contact)
                                showTransfer = true
                            } label: {
                                RecentTransfer(
                                    name: contact.name,
                                    icon: "person.fill",
                                    image: contact.imageName
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        Button {
                            transferVM.startNewTransfer()
                            showTransfer = true
                        } label: {
                            RecentTransfer(
                                name: "More",
                                icon: "plus",
                                image: "plus"
                            )
                        }
                        .buttonStyle(.plain)
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
                        
                        Text("See all")
                            .font(.headline)
                            .fontWeight(.medium)
                            .foregroundStyle(
                                Color("mutedText")
                            )
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 12) {

                        if viewModel.transactions.isEmpty {
                            Text("No transactions yet.")
                                .font(.subheadline)
                                .foregroundStyle(Color("secondaryText"))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 12)
                        } else {
                            ForEach(viewModel.transactions) { transaction in

                                TransactionRow(
                                    transaction: transaction
                                )
                            }
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 20)
            }
            .preferredColorScheme(.dark)
            .onAppear {
                viewModel.refresh()
            }
            .navigationDestination(isPresented: $showTransfer) {
                TransferView()
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let session = AppSession()
    return DashboardView()
        .environmentObject(session)
        .environmentObject(DashboardViewModel(context: context, session: session))
        .environmentObject(TransferViewModel(context: context, session: session))
        .environment(
            \.managedObjectContext,
            context
        )
}
