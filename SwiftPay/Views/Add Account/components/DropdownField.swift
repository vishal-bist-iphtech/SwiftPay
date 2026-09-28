//
//  DropdownField.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 28/09/26.
//

import SwiftUI

struct DropdownField<Content: View>: View {
    let value: String
    var placeholder: String = "Select"
    var width: CGFloat? = nil
    var height: CGFloat = 52
    var fontSize: CGFloat = 15
    @ViewBuilder let menuContent: Content

    var body: some View {
        Menu {
            menuContent
        } label: {
            HStack {
                Text(value.isEmpty ? placeholder : value)
                    .font(.system(size: fontSize, weight: .medium))
                    .foregroundStyle(value.isEmpty ? Color("mutedText") : Color("primaryText"))
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color("mutedText"))
            }
            .padding(.horizontal, 16)
            .frame(height: height)
            .frame(maxWidth: width ?? .infinity)
            .background(width != nil ? Color.white.opacity(0.06) : Color("surface"))
            .clipShape(RoundedRectangle(cornerRadius: width != nil && height < 52 ? 12 : 14))
            .overlay {
                RoundedRectangle(cornerRadius: width != nil && height < 52 ? 12 : 14)
                    .stroke(Color("border").opacity(0.3), lineWidth: 1)
            }
        }
        .frame(maxWidth: width ?? .infinity)
    }
}
