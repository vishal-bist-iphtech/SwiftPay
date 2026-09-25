//
//  U.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 24/09/26.
//

import SwiftUI

struct CompactCard: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 30) {

            HStack {
                Text("Card balance")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.95))

                Spacer(minLength: 5)

                Text(maskedAccountNumber("123456789123456"))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
            }

            HStack(alignment: .firstTextBaseline, spacing: 5) {

                Text("$")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))

                Text(balanceFormatting(1234, currencyCode: false))
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)

                Spacer(minLength: 5)

                CardMark()
            }
        }
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity)
        .frame(height: 120)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
    
    var cardBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.90, green: 0.55, blue: 0.50),
                    Color(red: 0.90, green: 0.28, blue: 0.05),
                    Color(red: 0.75, green: 0.20, blue: 0.05),
                    Color(red: 0.75, green: 0.14, blue: 0.08),
                    Color(red: 0.90, green: 0.28, blue: 0.22),
                    Color(red: 0.80, green: 0.20, blue: 0.15)
                ],
                startPoint: .topTrailing,
                endPoint: .bottomLeading
            )

            // Soft top-right glow
            Circle()
                .fill(.white.opacity(0.14))
                .frame(width: 220, height: 220)
                .blur(radius: 60)
                .offset(x: 110, y: -90)

            // Deep bottom-left shade
            Circle()
                .fill(.black.opacity(0.22))
                .frame(width: 200, height: 200)
                .blur(radius: 50)
                .offset(x: -110, y: 80)

            // Bubble cluster
            Group {
                Circle()
                    .stroke(.white.opacity(0.16), lineWidth: 1.2)
                    .frame(width: 110, height: 110)
                    .offset(x: 118, y: -12)

                Circle()
                    .stroke(.white.opacity(0.13), lineWidth: 1)
                    .frame(width: 72, height: 72)
                    .offset(x: 96, y: 48)

                Circle()
                    .stroke(.white.opacity(0.15), lineWidth: 1)
                    .frame(width: 34, height: 34)
                    .offset(x: 68, y: -48)

                Circle()
                    .fill(.white.opacity(0.06))
                    .frame(width: 22, height: 22)
                    .offset(x: 48, y: -68)
                
                Circle()
                    .fill(.white.opacity(0.06))
                    .frame(width: 22, height: 22)
                    .offset(x: 40, y: 18)
                
                Circle()
                    .fill(.white.opacity(0.06))
                    .frame(width: 22, height: 22)
                    .offset(x: 80, y: 30)
            }
        }
    }
            
    private func balanceFormatting(_ value: Double, currencyCode: Bool = true) -> String {
        if currencyCode {
            return value.formatted(
                .currency(code: "USD")
                .precision(.fractionLength(2))
            )
        }
        return value.formatted(
            .number.precision(.fractionLength(2))
        )
    }
    
    // account number masking
    private func maskedAccountNumber(_ accountNumber: String, visibleDigits: Int = 4) -> String {
        let digitsOnly = accountNumber.filter { $0.isNumber }
        
        guard digitsOnly.count > visibleDigits else {
            return digitsOnly
        }
        
        let lastDigits = digitsOnly.suffix(visibleDigits)
        return "••••• \(lastDigits)"
    }
}

private struct CardMark: View {

    var diameter: CGFloat = 22

    var body: some View {

        HStack(spacing: -(diameter * 0.45)) {

            Circle()
                .fill(Color(red: 0.92, green: 0.12, blue: 0.16))
                .frame(width: diameter, height: diameter)

            Circle()
                .fill(Color(red: 1.0, green: 0.62, blue: 0.15).opacity(0.9))
                .frame(width: diameter, height: diameter)
        }
    }
}


#Preview {
    CompactCard()
}
