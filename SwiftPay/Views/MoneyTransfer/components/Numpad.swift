//
//  Numpad.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 23/09/26.
//

import SwiftUI
import UIKit

struct Numpad: View {

    @Binding var amount: String

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]


    private let keys: [NumpadKey] = [
        .digit("1"), .digit("2"), .digit("3"),
        .digit("4"), .digit("5"), .digit("6"),
        .digit("7"), .digit("8"), .digit("9"),
        .dot, .digit("0"), .delete
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            
            ForEach(keys, id: \.self) { key in
                
                NumpadKeyButton(key: key) {
                    
                    // adding tapFeedback (light vibration)
                    tapFeedback()
                    
                    // handler for adding dot and delete
                    handle(key)
                    
                }
            }
        }
    }

    // MARK: - Input handling

    private func handle(_ key: NumpadKey) {
        
        switch key {
            
        case .digit(let value):
            insertDigit(value)
            
        case .dot:
            insertDot()
            
        case .delete:
            deleteLast()
            
        }
    }

    private func insertDigit(_ digit: String) {
        
        // Split integer / fraction so we can enforce 2 decimal places.
        if amount.contains(".") {
            // spliting amount in parts
            let parts = amount.split(separator: ".", omittingEmptySubsequences: false)
            let fraction = parts.count > 1 ? String(parts[1]) : ""
            // Max 2 digits after the decimal point.
            guard fraction.count < 2 else { return }
            // Cap total length (e.g. 9999999.99).
            guard amount.count < 10 else { return }
            amount.append(digit)
        } else {
            // Cap integer part length.
            guard amount.count < 7 else { return }
            if amount == "0" {
                // Avoid "00", "01" — replace a lone leading zero.
                if digit == "0" { return }
                amount = digit
            } else {
                amount.append(digit)
            }
        }
    }

    private func insertDot() {
        if amount.isEmpty {
            amount = "0."
        } else if !amount.contains(".") {
            amount.append(".")
        }
    }

    // delete the last input
    private func deleteLast() {
        guard !amount.isEmpty else { return }
        amount.removeLast()
    }

    
    // tapFeedback -> light vibration when numpad key tapped
    private func tapFeedback() {
        
        let tapFeedback = UIImpactFeedbackGenerator(style: .light)
        tapFeedback.prepare()
        tapFeedback.impactOccurred()
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        Numpad(amount: .constant("1234.84"))
            .padding()
    }
}
