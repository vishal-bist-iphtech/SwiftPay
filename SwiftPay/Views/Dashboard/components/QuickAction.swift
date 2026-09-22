//
//  QuickAction.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 22/09/26.
//

import SwiftUI

struct QuickAction: View {
    
    let title: String
    let icon: String
    
    var body: some View {
        
        VStack(spacing: 8) {
            
            Image(systemName: icon)
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .foregroundStyle(
            Color("primaryText")
        )
        .frame(width: 100, height: 70)
        .padding(2)
        .background(.ultraThinMaterial).opacity(0.8)
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
    }
}

