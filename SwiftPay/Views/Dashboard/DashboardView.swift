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
    @EnvironmentObject var uservm: UserDetailsViewModel
    @EnvironmentObject var transferVM: TransferViewModel
    @EnvironmentObject var transactionVM: TransactionViewModel

    @State private var showTransfer: Bool = false
    @State private var showingAddContact: Bool = false
    @State private var isExpanded: Bool = false
    @State private var isExpanding: Bool = false
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: 4),
        count: 5
    )
    
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
                               uservm.profileImage
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
                        
                        // MARK: Credit card

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
                                .environmentObject(viewModel)
                        } label: {
                            QuickAction(
                                title: "Add account",
                                icon: "plus"
                            )
                        }

                        // transfer money
                        Button {
                            transferVM.startNewTransfer()
                            showTransfer = true
                        } label: {
                            QuickAction(
                                title: "Transfer",
                                icon: "arrow.up.right"
                            )
                        }
                        
                        // spending
                        NavigationLink {
                            SpendingView()
                        } label:{
                            QuickAction(
                                title: "Spending",
                                icon: "chart.line.uptrend.xyaxis"
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
                    
                    if !viewModel.hasContacts {
                            Button {
                                showingAddContact = true
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "plus.circle")
                                        .font(.title)
                                        .foregroundStyle(Color("mutedText"))
                                        .frame(width: 70, height: 70)
                                        .background(Color("surface"))
                                        .clipShape(Circle())
                                    Text("Add contact")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(Color("secondaryText"))
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.plain)
                        
                    }
                    
                    if viewModel.hasContacts {
                        
                        LazyVGrid(columns: columns, spacing: 15) {

                            
                            ForEach(viewModel.contacts.prefix(isExpanded ? 9 : 4)) { contact in
                                Button {
                                    transferVM.startNewTransfer(recipient: contact)
                                    showTransfer = true
                                } label: {
                                    RecentTransfer(
                                        name: contact.name,
                                        icon: "person.fill",
                                        imageData: contact.imageData
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            

                            if viewModel.contacts.count >= 5 {
                                Button {
                                    guard !isExpanding else {return}
                                    isExpanding = true

                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                        isExpanded.toggle()
                                    }

                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                        isExpanding = false
                                    }
                                } label: {
                                    RecentTransfer(
                                        name: isExpanded ? "See less" : "See more",
                                        icon: isExpanded ? "chevron.up" :  "chevron.down"
                                    )
                                }
                                .buttonStyle(.plain)
                                .disabled(isExpanding)
                            } else {
                                Button {
                                    showingAddContact = true
                                } label: {
                                    VStack(spacing: 4) {
                                        Image(systemName: "plus.circle")
                                            .font(.title)
                                            .foregroundStyle(Color("mutedText"))
                                            .frame(width: 70, height: 70)
                                            .background(Color("surface"))
                                            .clipShape(Circle())
                                        Text("Add contact")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundStyle(Color("secondaryText"))
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                            
                        }
                        .padding(.top, 10)
                    }
                    
                    
                    
                    // MARK: Transactions
                    
                    HStack {
                        
                        Text("Transactions")
                            .font(.title3)
                            .fontWeight(.medium)
                            .foregroundStyle(
                                Color("primaryText")
                            )
                        
                        Spacer()
                        
                        NavigationLink {
                            TransactionView()
                        } label: {
                            Text("See all")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundStyle(
                                    Color("mutedText")
                                )
                        }
                    }
                    .padding(.top, 20)
                    
                    VStack(spacing: 12) {
                        
                        if viewModel.hasTransactions {
                            ForEach(viewModel.recentTransactions) { transaction in
                                
                                NavigationLink {
                                    TransactionDetailsView(transaction: transaction)
                                } label: {
                                    TransactionRow(
                                        transaction: transaction
                                    )
                                }
                            }
                        } else {
                            // Empty state with icon + hint
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
            .onAppear {
                viewModel.refresh()
            }
            .navigationDestination(isPresented: $showTransfer) {
                TransferView()
            }
            .sheet(isPresented: $showingAddContact) {
                AddContactSheet(onAddContact: { name, phone, image in
                    transferVM.addContact(name: name, phone: phone, image: image)
                })
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
            }
            // After the success animation, push the new transfer's details on the
            .navigationDestination(item: $transferVM.completedTransaction) { transaction in
                TransactionDetailsView(transaction: transaction)
            }
            .onChange(of: transferVM.completedTransaction) { _, newValue in
                guard newValue != nil else { return }
                // Refresh so Edit/Delete resolve the new entity, then pop the
                // transfer screen so the stack becomes [details] on dashboard.
                transactionVM.refresh()
                showTransfer = false
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let session = AppSession()
    let store = AccountStore(context: context, session: session)
    return DashboardView()
        .environmentObject(session)
        .environmentObject(DashboardViewModel(store: store))
        .environmentObject(TransferViewModel(store: store, session: session))
        .environmentObject(TransactionViewModel(session: session, store: store))
        .environmentObject(BankDetailsViewModel(store: store))
        .environmentObject(UserDetailsViewModel(session: session))
        .environment(
            \.managedObjectContext,
            context
        )
}
