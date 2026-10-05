//
//  TermsPrivacyView.swift
//  SwiftPay
//
//  Dummy legal screen linked from Profile > Terms & privacy.
//

import SwiftUI

struct TermsPrivacyView: View {

    private let sections: [(title: String, body: String)] = [
        ("1. About SwiftPay",
         "SwiftPay is a demo finance app for tracking spending, managing linked bank accounts and sending money between contacts. All data is stored locally on your device using Core Data."),
        ("2. Your data",
         "Your name, email, phone, linked accounts, contacts and transactions stay on-device. Deleting your account permanently removes all owned data. We do not upload, sell or share personal data in this demo build."),
        ("3. Transactions",
         "Transfers deduct from your selected bank balance and create a local transaction record. There is no real money movement. Always verify recipient details before confirming with your transaction PIN."),
        ("4. Security",
         "Your transaction PIN is for demo confirmation only and is not stored. Keep your device passcode enabled. SwiftPay never asks for OTPs, CVVs or full card numbers outside the Add Account screen."),
        ("5. Acceptable use",
         "Use SwiftPay only for lawful, personal finance tracking. Do not attempt to reverse-engineer balances or fabricate transaction history."),
        ("6. Changes",
         "These dummy terms may change as the app evolves. Continued use after updates constitutes acceptance of the revised terms.")
    ]

    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Terms & privacy")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color("primaryText"))
                        .padding(.top, 8)

                    Text("Last updated October 2026 · v1.0")
                        .font(.caption)
                        .foregroundStyle(Color("mutedText"))
                        .padding(.top, 4)

                    VStack(spacing: 12) {
                        ForEach(sections.indices, id: \.self) { index in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(sections[index].title)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(Color("primaryText"))
                                Text(sections[index].body)
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color("secondaryText"))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(Color("surface").opacity(0.6))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(.top, 16)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("Terms & privacy")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        TermsPrivacyView()
    }
    .preferredColorScheme(.dark)
}
