//
//  TransferCard.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 23/09/26.
//

import SwiftUI


struct TransferCard: View {
    
    let accountNumber = "123456789123456"
    var balance: Double = 1234
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 8) {
            
            VStack {
                HStack{
                    Text("From")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    CardMark(diameter: 22)
                        .frame(width: 50, height: 50)

                }
                
                Spacer(minLength: 10)
                
                VStack(alignment: .leading, spacing: 2) {
                    
                    HStack{
                        Text(maskedAccountNumber(accountNumber))
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .tracking(0.5)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {

                        Text(balanceFormatting(balance)
                        )
                        .font(.title)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.8)
                        .monospacedDigit()
                        .contentTransition(.numericText())
                        .lineLimit(1)
                    }

                }
            }
            .padding(16)
            .frame(maxWidth: 200)
            .frame(height: 160)
            .glassEffect(.clear, in: .rect(cornerRadius: 22))
            .overlay {
                RoundedRectangle(cornerRadius: 22)
                    .stroke(.white.opacity(0.12), lineWidth: 1)

            }
            
            VStack {
                HStack{
                    Text("To")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Image("demo_profile_image")
                        .resizable()
                        .scaledToFill()
                        .font(.system(size: 30))
                        .frame(width: 50, height: 50)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(Color("mutedText"), lineWidth: 1)
                        )
                        .offset(y: 10)
                }
                
                Spacer(minLength: 10)
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack{
                        Text("Olivia Carter")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {

                        Text("+91 1234567899")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            Color("primaryText")
                                .opacity(0.7)
                        )
                    }

                }
            }
            .padding(16)
            .frame(maxWidth: 200)
            .frame(height: 160)
            .glassEffect( .clear ,in: .rect(cornerRadius: 22))
            .overlay {
                RoundedRectangle(cornerRadius: 22)
                    .stroke(.white.opacity(0.12), lineWidth: 1)

            }
        }
    }
    
    // formatting the balance with currency code
    private func balanceFormatting(_ value: Double) -> String {
        value.formatted(
            .currency(code: "USD")
            .precision(.fractionLength(2))
        )
    }
    
    // masking the account number -> (......1234)
    private func maskedAccountNumber(_ accountNumber: String, visibleDigits: Int = 4) -> String {
        
        let digitsOnly = accountNumber.filter { $0.isNumber }
        
        let lastDigits = digitsOnly.suffix(visibleDigits)
        return "••••• \(lastDigits)"
    }
}
