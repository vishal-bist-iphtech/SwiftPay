//
//  TransferView.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 23/09/26.
//

import SwiftUI

struct TransferView: View {
    
    @State private var transferAmount: String = ""
    @State private var showSuccess = false
    @State private var isProcessing = false
    @State private var sentAmount = ""
    
    // integer cap
    let intCap: Int = 7
    // fraction cap
    let fraCap: Int = 2
    
    var body: some View {
        
        ZStack {
            
            LinearGradient(
                colors: [Color.orange, Color("background").opacity(0.7), Color("background"),Color("surface")],
                startPoint: .topTrailing, endPoint: .bottomLeading
            )
             .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 8) {
                    
                    // MARK: From & To cards
                    TransferCard()
                    
                    // MARK: Transfer amount
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("$")
                            .font(.system(size: 30, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color("secondaryText").opacity(0.7))

                        if transferAmount.isEmpty {
                            Text("0.00")
                                .font(.system(size: 50, design: .rounded))
                                .fontWeight(.semibold)
                                .foregroundStyle(
                                    Color("primaryText")
                                        .opacity(0.7)
                                )
                        }
                        
                        Text(transferAmount)
                            
                            .font(.system(size: 50, design: .rounded))
                            .fontWeight(.semibold)
                            .foregroundStyle(Color("primaryText"))
                            .tint(.white)
                            .focusable(false)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .onChange(of: transferAmount) { _, newValue in
                                transferAmount = sanitizedAmount(newValue)
                            }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .frame(height: 110)

                    // MARK: Custom NumPad
                    Numpad(amount: $transferAmount)
                    
                    
                    // MARK: Send Button
                    Button {
                        sendButtonTapped()
                    } label: {
                        ZStack {
                            
                            Text("Send Money")
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundStyle(
                                    Color("background")
                                )
                                .opacity(isProcessing ? 0 : 1)
                                
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(
                                        Color("background")
                                    )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .padding()
                        .background(.white)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 22)
                        )
                    }
                    .disabled(!isAmountValid || isProcessing)
                    .padding(.top, 15)
                }
                .padding(.top, 15)
                .padding(.horizontal, 15)
            }
                
        }
        .navigationTitle("Transfer money")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showSuccess) {
            TransferSuccessView(amount: sentAmount) {
                showSuccess = false
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                }
                .padding(4)
            }
        }
    }


    // send button tapped
    private func sendButtonTapped() {
        
        guard !isProcessing else {return}
        
        isProcessing = true
        
        // simulating the API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
            sentAmount = transferAmount
            isProcessing = false
            showSuccess = true
        }
    }

    // Input amount sanitization to a valid amount format.
    private func sanitizedAmount(_ value: String) -> String {
        
        // filter out anything other than digits or dot(.)
        var filtered = value.filter { "0123456789".contains($0) || $0 == "." }

        // Split the string in parts removing empty space btw/around separator.
        let parts = filtered.split(separator: ".", omittingEmptySubsequences: false)
        
        // if there are more than one dot, then join the rest without any dot after the first dot.
        if parts.count > 2 {
            filtered = String(parts[0]) + "." + parts[1...].joined()
        }

        if filtered.contains(".") {
            
            let amnt = filtered.split(separator: ".", omittingEmptySubsequences: false)
            
            // integer part of input amount
            var intPart = String(amnt[0])
            // fraction part of input amount
            var fracPart = amnt.count > 1 ? String(amnt[1]) : ""
            
            // integer part capped at 7 digits
            if intPart.count > intCap { intPart = String(intPart.prefix(intCap)) }
            // fraction part capped at 2 digits
            if fracPart.count > fraCap { fracPart = String(fracPart.prefix(fraCap)) }
            
            // Preserve trailing dot while typing ("12." stays "12.").
            if amnt.count > 1 && fracPart.isEmpty && filtered.hasSuffix(".") {
                return intPart + "."
            }
            
            return intPart + "." + fracPart
            
        } else {
            // if there's no dot(.) then cap the integer at 7 digits
            if filtered.count > intCap {
                filtered = String(filtered.prefix(intCap))
            }
            
            return filtered
        }
    }
    
    private var isAmountValid: Bool {
        
        guard let value = Double(transferAmount) else {return false}
        
    /*
         "0" → 0.0 > 0 is false
         "0.00" → 0.0 > 0 is false
         "0." → Double("0.") is nil
         And true for any non-zero amount like "0.01", "5", "12.50"
     */
        return value > 0
    }
}


#Preview {
    TransferView()
}
