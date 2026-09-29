//
//  MetaRow.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 29/09/26.
//

import SwiftUI

struct MetaRow: View {
    
    var label: String
    var value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color("secondaryText"))
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color("primaryText"))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}
