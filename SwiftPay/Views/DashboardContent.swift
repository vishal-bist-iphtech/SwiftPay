//
//  DashboardContent.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 21/09/26.
//

import SwiftUI

struct DashboardContent: View {
    
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        
        ScrollView(showsIndicators: false) {
            
            VStack(alignment: .leading, spacing: 0) {
                
                // MARK: Header
                
                HStack {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        
                        Text("Good morning")
                            .font(.system(size: 13))
                            .foregroundStyle(
                                Color("secondaryText")
                            )
                        
                        Text("Alex")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(
                                Color("primaryText")
                            )
                    }
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        Image(systemName: "bell")
                            .foregroundStyle(
                                Color("primaryText")
                            )
                            .frame(width: 44, height: 44)
                            .background(
                                Color("surface")
                            )
                            .clipShape(Circle())
                    }
                }
                
                // MARK: Balance card
                
                VStack(alignment: .leading, spacing: 18) {
                    
                    HStack {
                        
                        Text("TOTAL BALANCE")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(
                                Color("secondaryText")
                            )
                        
                        Spacer()
                        
                        Image(systemName: "eye")
                            .foregroundStyle(
                                Color("secondaryText")
                            )
                    }
                    
                    Text(
                        viewModel.balance,
                        format: .currency(code: "USD")
                    )
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(
                        Color("primaryText")
                    )
                    
                    HStack(spacing: 12) {
                        
                        QuickAction(
                            title: "Add money",
                            icon: "plus"
                        )
                        
                        QuickAction(
                            title: "Transfer",
                            icon: "arrow.up.right"
                        )
                        
                        QuickAction(
                            title: "More",
                            icon: "square.grid.2x2"
                        )
                    }
                }
                .padding(20)
                .background(
                    LinearGradient(
                        colors: [
                            Color("darkRed"),
                            Color("accentColor").opacity(0.45),
                            Color("surface")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 28)
                )
                .padding(.top, 28)
                
                // MARK: Recipients
                
                HStack {
                    
                    Text("Recent recipients")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(
                            Color("primaryText")
                        )
                    
                    Spacer()
                    
                    Text("View all")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(
                            Color("accentColor")
                        )
                }
                .padding(.top, 30)
                
                HStack(spacing: 18) {
                    
                    RecipientView(
                        name: "Add",
                        icon: "plus"
                    )
                    
                    RecipientView(
                        name: "Emma",
                        icon: "person.fill"
                    )
                    
                    RecipientView(
                        name: "James",
                        icon: "person.fill"
                    )
                    
                    RecipientView(
                        name: "Olivia",
                        icon: "person.fill"
                    )
                    
                    RecipientView(
                        name: "More",
                        icon: "ellipsis"
                    )
                }
                .padding(.top, 18)
                
                // MARK: Transactions
                
                HStack {
                    
                    Text("Transactions")
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(
                            Color("primaryText")
                        )
                    
                    Spacer()
                    
                    Text("See all")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(
                            Color("accentColor")
                        )
                }
                .padding(.top, 34)
                
                VStack(spacing: 12) {
                    
                    ForEach(viewModel.transactions) { transaction in
                        
                        TransactionRow(
                            transaction: transaction
                        )
                    }
                }
                .padding(.top, 16)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 110)
        }
    }
}
