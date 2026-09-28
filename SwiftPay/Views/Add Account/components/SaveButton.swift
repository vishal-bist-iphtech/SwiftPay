//
//  SaveButton.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 28/09/26.
//

import SwiftUI

struct SaveButton: View {
    let isSaving: Bool
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Text("Save account")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .opacity(isSaving ? 0 : 1)

                if isSaving {
                    ProgressView()
                        .tint(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.56, blue: 0.25),
                        Color(red: 0.94, green: 0.27, blue: 0.2)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .opacity(isEnabled && !isSaving ? 1 : 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color(red: 0.95, green: 0.35, blue: 0.15).opacity(0.35), radius: 18, x: 0, y: 8)
        }
        .disabled(!isEnabled || isSaving)
    }
}
