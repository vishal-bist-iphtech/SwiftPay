//
//  TransactionRow.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 22/09/26.
//

import SwiftUI


struct TransactionRow: View {
    
    let transaction: Transaction
    
    var body: some View {
        
        HStack(spacing: 14) {
            
            Image(systemName: transaction.icon)
                .font(.title)
                .foregroundStyle(
                    Color("primaryText")
                )
                .frame(width: 50, height: 50)
                .background(
                    Color("surface")
                )
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text(transaction.title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(
                        Color("primaryText")
                    )
                
                Text(transaction.category)
                    .font(.subheadline)
                    .foregroundStyle(
                        Color("secondaryText")
                    )
            }
            
            Spacer()
            
            Text(
                transaction.amount,
                format: .currency(code: "USD")
            )
            .font(.title3)
            .fontWeight(.semibold)
            .foregroundStyle(
                transaction.isIncome
                ? Color.green
                : Color("primaryText")
            )
        }
        .padding(14)
        .glassEffect(.regular, in: .rect)
        .clipShape(
            RoundedRectangle(cornerRadius: 18)
        )
        
    }
}
