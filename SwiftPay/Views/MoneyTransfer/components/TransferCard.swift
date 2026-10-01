//
//  TransferCard.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 23/09/26.
//

import SwiftUI


/// From/To cards on the Transfer screen.
///
/// - From: driven by the TransferViewModel (Core Data primary account).
///   Balance stays hidden until "Check balance".
/// - To: empty state until a recipient is picked; tapping opens the picker sheet.
struct TransferCard: View {

    // MARK: - From (from TransferViewModel — value types only)

    var bankName: String = "State Bank of India"
    var maskedNumber: String = "••••• 3456"
    var balance: Double = 6000
    var currencyCode: String = "USD"

    // MARK: - To

    var recipient: Contact?
    var onSelectRecipient: () -> Void = {}

    @State private var isBalanceVisible = false

    var body: some View {

        HStack(alignment: .center, spacing: 8) {

            // MARK: From
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

                VStack(alignment: .leading, spacing: 8) {

                    Text(maskedNumber)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .tracking(0.5)
                        .foregroundStyle(.white.opacity(0.85))
                        .lineLimit(1)

                    // bank + Check balance,
                    // toggles to balance + Hide once revealed.
                    if isBalanceVisible {
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(AccountFormatting.formattedBalance(balance, currencyCode: currencyCode))
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .minimumScaleFactor(0.8)
                                .monospacedDigit()
                                .contentTransition(.numericText())
                                .lineLimit(1)

                            Spacer(minLength: 4)

                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    isBalanceVisible = false
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "eye.slash.fill")
                                        .font(.caption2)
                                }
                                .foregroundStyle(.white.opacity(0.8))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5)
                                .background(.white.opacity(0.12), in: Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    } else {
                        HStack {
                            Text(bankName)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .lineLimit(1)

                            Spacer(minLength: 4)

                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    isBalanceVisible = true
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "eye.fill")
                                        .font(.caption2)
                                }
                                .foregroundStyle(.white.opacity(0.9))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 5)
                                .background(.clear)
                            }
                            .buttonStyle(.plain)
                        }
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

            // MARK: To (tappable — empty state until a recipient is chosen)
            Button(action: onSelectRecipient) {
                VStack {
                    HStack{
                        Text("To")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)

                        Spacer()

                        if let recipient {
                            if let imageData = recipient.imageData,
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 50, height: 50)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle().stroke(Color("mutedText"), lineWidth: 1)
                                    )
                                    .offset(y: 10)
                            } else {
                                Text(recipient.initials)
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 50, height: 50)
                                    .background(Color(red: 0.95, green: 0.45, blue: 0.2).opacity(0.8))
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle().stroke(Color("mutedText"), lineWidth: 1)
                                    )
                                    .offset(y: 10)
                            }
                        } else {
                            Image(systemName: "plus.circle.dashed")
                                .font(.system(size: 40))
                                .foregroundStyle(.white.opacity(0.5))
                                .frame(width: 50, height: 50)
                                .offset(y: 10)
                        }
                    }

                    Spacer(minLength: 10)

                    if let recipient {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(recipient.name)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white.opacity(0.85))
                                .lineLimit(1)

                            Text(recipient.phone.isEmpty ? "—" : recipient.phone)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(
                                    Color("primaryText")
                                        .opacity(0.7)
                                )
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Select recipient")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white.opacity(0.85))

                            Text("Tap to choose")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(
                                    Color("primaryText")
                                        .opacity(0.7)
                                )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(16)
                .frame(maxWidth: 200)
                .frame(height: 160)
                .glassEffect(.clear, in: .rect(cornerRadius: 22))
                .overlay {
                    if recipient == nil {
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(
                                .white.opacity(0.35),
                                style: StrokeStyle(lineWidth: 1, dash: [6, 4])
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 22)
                            .stroke(.white.opacity(0.12), lineWidth: 1)
                    }
                }
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ZStack {
        Color("background")
            .ignoresSafeArea()

        VStack(spacing: 16) {
            TransferCard()
            TransferCard(recipient: Contact(name: "Olivia", phone: "+91 1234567899"))
        }
        .padding()
    }
}
