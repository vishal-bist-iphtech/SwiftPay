//
//  CardDetails.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 28/09/26.
//

import SwiftUI

/// Card-details section (last four + CVV + network) of the Add Account screen.
struct CardDetails: View {

    @Binding var lastFour: String
    @Binding var cvvNumber: String
    @Binding var cardNetwork: String

    let cardNetworks: [String]
    var focusedField: FocusState<AddAccountField?>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Card details")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color("primaryText"))
                Spacer()
                Text("Encrypted")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Color.green.opacity(0.9))
            }

           FieldLabel("Last four digits", size: 12)
                .padding(.top, 14)

            HStack(spacing: 6) {
                Text("••••")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color("mutedText"))
                TextField("", text: $lastFour, prompt: Text("Last 4 digits").foregroundStyle(Color("mutedText")))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color("primaryText"))
                    .keyboardType(.numberPad)
                    .submitLabel(.next)
                    .focused(focusedField, equals: .lastFour)
                    .onSubmit { focusedField.wrappedValue = .cvvNumber }
                    .onChange(of: lastFour) { _, newValue in
                        let digits = newValue.filter(\.isNumber)
                        lastFour = String(digits.prefix(4))
                    }
            }
            .padding(.horizontal, 16)
            .frame(height: 48)
            .background(Color.white.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color("border").opacity(0.3), lineWidth: 1)
            }
            .padding(.top, 8)

            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 0) {
                   FieldLabel("CVV Number", size: 12)
                    TextField("", text: $cvvNumber, prompt: Text("eg, 365").foregroundStyle(Color("mutedText")))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color("primaryText"))
                        .keyboardType(.numberPad)
                        .submitLabel(.done)
                        .focused(focusedField, equals: .cvvNumber)
                        .onSubmit { focusedField.wrappedValue = nil }
                        .onChange(of: cvvNumber) { _, newValue in
                            let digits = newValue.filter(\.isNumber)
                            cvvNumber = String(digits.prefix(4))
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 48)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("border").opacity(0.3), lineWidth: 1)
                        }
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 0) {
                    FieldLabel("Card network", size: 12)
                    DropdownField(value: cardNetwork, placeholder: "Select card", height: 48, fontSize: 14) {
                        ForEach(cardNetworks, id: \.self) { item in
                            Button(item) { cardNetwork = item }
                        }
                    }
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.top, 12)
        }
        .padding(14)
        .background(Color("surface"))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color("border").opacity(0.3), lineWidth: 1)
        }
    }
}
