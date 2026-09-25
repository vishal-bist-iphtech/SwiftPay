//
//  NumpadKeyButton.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 23/09/26.
//

import SwiftUI

// Key model shared by Numpad and NumpadKeyButton.
enum NumpadKey: Hashable {
    case digit(String)
    case dot
    case delete
}


struct NumpadKeyButton: View {

    let key: NumpadKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                
                // only numeric value (0 -> 9) have tile background
                if hasTileBackground {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.08))
                }

                switch key {
                    
                case .digit(let value):
                    Text(value)
                        .font(.system(size: 30, weight: .medium, design: .rounded))
                        .foregroundStyle(.white)
                    
                case .dot:
                    Text(".")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                case .delete:
                    Image(systemName: "delete.left")
                        .font(.system(size: 26, weight: .medium))
                        .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
        }
        .buttonStyle(.plain)
    }

    private var hasTileBackground: Bool {
        switch key {
        case .digit: return true
        case .dot, .delete: return false
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        HStack(spacing: 10) {
            NumpadKeyButton(key: .digit("1")) {}
            NumpadKeyButton(key: .dot) {}
            NumpadKeyButton(key: .delete) {}
        }
        .padding()
    }
}
