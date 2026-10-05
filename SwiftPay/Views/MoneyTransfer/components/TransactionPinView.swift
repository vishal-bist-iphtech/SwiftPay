//
//  TransactionPinView.swift
//  SwiftPay
//
//  UPI-style transaction PIN entry shown on Send Money tap.
//  Demo mode: any 4-digit PIN is accepted.
//

import SwiftUI
import UIKit
import CoreData

struct TransactionPinView: View {

    @EnvironmentObject var viewModel: TransferViewModel

    @State private var pin = ""
    @State private var shakeOffset: CGFloat = 0

    private let pinLength = 4

    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // MARK: Grabber + header
                Capsule()
                    .fill(Color("mutedText").opacity(0.4))
                    .frame(width: 40, height: 5)
                    .padding(.top, 10)

                HStack {
                    Button {
                        viewModel.cancelPin()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color("primaryText"))
                            .frame(width: 36, height: 36)
                            .background(Color("surface"))
                            .clipShape(Circle())
                    }

                    Spacer()

                    Text("Enter PIN")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color("primaryText"))

                    Spacer()

                    // Balance visual slot to keep title centered
                    Color.clear.frame(width: 36, height: 36)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                // MARK: Bank + payment summary (UPI-style)
                VStack(spacing: 8) {
                    HStack(spacing: 10) {
                        Image(systemName: "building.columns.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.95, green: 0.45, blue: 0.2),
                                        Color(red: 0.9, green: 0.25, blue: 0.25)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(viewModel.bankName)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color("primaryText"))
                                .lineLimit(1)
                            Text(viewModel.maskedNumber)
                                .font(.system(size: 13))
                                .foregroundStyle(Color("mutedText"))
                                .lineLimit(1)
                        }

                        Spacer()
                    }
                    .padding(14)
                    .background(Color("surface").opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    VStack(spacing: 4) {
                        Text(viewModel.selectedRecipient.map { "Paying to \($0.name)" } ?? "Paying")
                            .font(.system(size: 13))
                            .foregroundStyle(Color("mutedText"))
                            .lineLimit(1)

                        Text(formattedAmount)
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(Color("primaryText"))
                            .monospacedDigit()
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // MARK: PIN dots
                HStack(spacing: 16) {
                    ForEach(0..<pinLength, id: \.self) { index in
                        Circle()
                            .fill(index < pin.count ? Color("primaryText") : Color.clear)
                            .frame(width: 16, height: 16)
                            .overlay {
                                Circle()
                                    .stroke(Color("mutedText").opacity(0.5), lineWidth: 1.5)
                            }
                    }
                }
                .offset(x: shakeOffset)
                .padding(.top, 28)
                .padding(.bottom, 6)

                if let pinError = viewModel.pinErrorMessage {
                    Text(pinError)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color("accentColor"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                } else {
                    Text("Enter your 4-digit transaction PIN")
                        .font(.system(size: 13))
                        .foregroundStyle(Color("mutedText"))
                }

                Spacer(minLength: 12)

                // MARK: Keypad
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ],
                    spacing: 12
                ) {
                    ForEach(pinKeys, id: \.self) { key in
                        PinKeyButton(key: key) {
                            handleKey(key)
                        }
                        .disabled(viewModel.isProcessing)
                        .opacity(viewModel.isProcessing ? 0.5 : 1)
                    }
                }
                .padding(.horizontal, 32)

                // MARK: Processing / Cancel
                if viewModel.isProcessing {
                    HStack(spacing: 10) {
                        ProgressView()
                            .tint(Color("mutedText"))
                        Text("Processing payment…")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color("mutedText"))
                    }
                    .padding(.top, 18)
                    .padding(.bottom, 24)
                } else {
                    Button {
                        viewModel.cancelPin()
                    } label: {
                        Text("Cancel")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Color("secondaryText"))
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                    .padding(.bottom, 24)
                }
            }
        }
        .onChange(of: pin) { _, newValue in
            // Keep digits only, max 4.
            let filtered = newValue.filter(\.isNumber).prefix(pinLength)
            if String(filtered) != newValue {
                pin = String(filtered)
                return
            }
            if pin.count == pinLength {
                // Small pause so the 4th dot fills before processing.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    submitIfComplete()
                }
            }
        }
    }

    // MARK: - Private

    private var formattedAmount: String {
        if let value = Double(viewModel.transferAmount), !viewModel.transferAmount.isEmpty {
            return AccountFormatting.formattedBalance(value, currencyCode: viewModel.currencyCode)
        }
        return AccountFormatting.formattedBalance(0, currencyCode: viewModel.currencyCode)
    }

    private var pinKeys: [String] {
        ["1", "2", "3", "4", "5", "6", "7", "8", "9", "", "0", "⌫"]
    }

    private func handleKey(_ key: String) {
        let feedback = UIImpactFeedbackGenerator(style: .light)
        feedback.prepare()
        feedback.impactOccurred()

        if key == "⌫" {
            if !pin.isEmpty { pin.removeLast() }
            if viewModel.pinErrorMessage != nil { viewModel.clearPinError() }
            return
        }
        guard !key.isEmpty else { return }
        guard pin.count < pinLength else { return }
        pin.append(key)
        if viewModel.pinErrorMessage != nil { viewModel.clearPinError() }
    }

    private func submitIfComplete() {
        guard pin.count == pinLength, !viewModel.isProcessing else { return }
        let entered = pin
        // Let the VM decide; on PIN error it sets pinErrorMessage and we shake + clear.
        viewModel.submitPin(entered)
        if viewModel.pinErrorMessage != nil {
            withAnimation(.default) {
                shakeOffset = -8
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                withAnimation(.default) { shakeOffset = 8 }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.16) {
                withAnimation(.default) { shakeOffset = 0 }
            }
            pin = ""
        }
    }
}

private struct PinKeyButton: View {
    let key: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if !key.isEmpty, key != "⌫" {
                    Circle()
                        .fill(Color("surface"))
                }
                if key == "⌫" {
                    Image(systemName: "delete.left")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(Color("primaryText"))
                } else {
                    Text(key)
                        .font(.system(size: 24, weight: .medium, design: .rounded))
                        .foregroundStyle(Color("primaryText"))
                }
            }
            .frame(height: 68)
        }
        .buttonStyle(.plain)
        .opacity(key.isEmpty ? 0 : 1)
        .disabled(key.isEmpty)
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let session = AppSession()
    let store = AccountStore(context: context, session: session)
    let vm = TransferViewModel(store: store, session: session)
    vm.transferAmount = "250.00"
    return TransactionPinView()
        .environmentObject(vm)
}
