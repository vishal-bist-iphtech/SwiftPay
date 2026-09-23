//
//  AuthFields.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 18/09/26.
//

import SwiftUI

struct LabelField: View {
    
    let placeholder: String
    @Binding var text: String
    let icon: String
    
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        
        HStack(spacing: 14) {
            
            Image(systemName: icon)
                .foregroundStyle(Color("secondaryText"))
            
            TextField(
                "",
                text: $text,
                prompt: Text(placeholder)
                .foregroundStyle(
                    Color("secondaryText")
                                )
            )
            .foregroundStyle(
                Color("primaryText")
            )
            .keyboardType(keyboardType)
            .textInputAutocapitalization(.never)
        }
        .padding(.horizontal, 18)
        .frame(height: 56)
        .background(Color("surface"))
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    Color("border")
                        .opacity(0.35),
                    lineWidth: 1
                )
        }
    }
}

struct PasswordField: View {
    
    let title: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        
        HStack(spacing: 14) {
            
            Image(systemName: icon)
                .foregroundStyle(Color("secondaryText"))
            
            SecureField(title, text: $text)
                .foregroundStyle(Color("primaryText"))
                .textInputAutocapitalization(.never)
        }
        .padding(.horizontal, 18)
        .frame(height: 56)
        .background(Color("surface"))
        .clipShape(
            RoundedRectangle(cornerRadius: 16)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    Color("border")
                        .opacity(0.35),
                    lineWidth: 1
                )
        }
    }
}

struct AuthButton: View {
    
    let title: String
    let selected: Bool
    let action: () -> Void
    
    var body: some View {
        
        Button(action: action) {
            
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(
                    selected
                    ? Color("primaryText")
                    : Color("secondaryText")
                )
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    selected
                    ? Color("accentColor")
                    : Color.clear
                )
                .clipShape(
                    RoundedRectangle(cornerRadius: 12)
                )
        }
    }
}

