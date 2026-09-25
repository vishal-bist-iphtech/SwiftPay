//
//  CreditCard.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 22/09/26.
//

import SwiftUI


/// Account card. Pure presentational View — all data comes from the caller
/// (DashboardView binds it to DashboardViewModel). Shows placeholders when
/// there is no linked account.
struct CreditCard: View {
    
    @State private var isBalanceVisible: Bool = false

    var balance: Double = 0
    var currencyCode: String = "USD"
    
    var bank: String = ""
    /// Already-masked number (e.g. "••••• 3456"). Empty when no account.
    var maskedNumber: String = ""

    var body: some View {
        
        ZStack {
            VStack(alignment: .leading, spacing: 0) {

                // MARK: Top row
                HStack(alignment: .center) {

                    Text("Card balance")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.75))

                    Spacer()

                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            isBalanceVisible.toggle()
                        }
                    } label: {
                        Image(
                            systemName: isBalanceVisible
                            ? "eye.fill"
                            : "eye.slash.fill"
                        )
                            .font(.title2)
                            .fontWeight(.medium)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }

                // MARK: Middle row
                HStack(alignment: .firstTextBaseline, spacing: 4) {

                    Text(
                        isBalanceVisible
                        ? balanceFormatting(balance)
                        : "xxxx"
                    )
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.8)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .lineLimit(1)

                    if isBalanceVisible {
                        Text(currencyCode)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.leading, 2)
                    }
                }
                .padding(.top, 10)

                Spacer(minLength: 12)

                // MARK: Bottom row
                HStack(alignment: .bottom) {

                    // Bank name
                    HStack(spacing: 6) {

                        Text(bank.isEmpty ? AppStrings.emptyStateNoAccount : bank)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)

                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(
                        Color("surface").opacity(0.28)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    Spacer()

                    // cardtype + masked number
                    VStack(alignment: .trailing, spacing: 8) {

                        CardMark(diameter: 22)
                        
                        Text(maskedNumber.isEmpty ? "credit/debit card" : maskedNumber)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .tracking(0.5)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .frame(height: 178)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .overlay {
                RoundedRectangle(cornerRadius: 22)
                    .stroke(.white.opacity(0.12), lineWidth: 1)
            }
            .shadow(color: Color(red: 0.95, green: 0.35, blue: 0.15).opacity(0.35), radius: 24, x: 3, y: 5)
            .padding(.top, 4)
            .zIndex(1)
            
            RoundedRectangle(cornerRadius: 22)
                .frame(maxWidth: 340)
                .frame(height: 50)
                .foregroundStyle(.orange.opacity(0.4))
                .offset(x: 0,y: 80)
        }
    }

    // Gradient background
    private var cardBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.48, blue: 0.22),
                    Color(red: 0.91, green: 0.29, blue: 0.12),
                    Color(red: 0.55, green: 0.14, blue: 0.08),
                    Color(red: 0.32, green: 0.09, blue: 0.06)
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
                    .offset(x: 58, y: 58)
            }
        }
    }
    
    // balance formatting
    private func balanceFormatting(_ value: Double) -> String {
        value.formatted(
            .currency(code: "USD")
            .precision(.fractionLength(2))
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

struct CardMark: View {

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
    ZStack {
        Color(red: 0.07, green: 0.07, blue: 0.08)
            .ignoresSafeArea()
        CreditCard(balance: 1234, bank: "xyz bank", maskedNumber: "••••• 3456")
            .padding(.horizontal, 20)
    }
}
