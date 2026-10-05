//
//  HelpCenterView.swift
//  SwiftPay
//
//  Dummy support screen linked from Profile > Help center.
//

import SwiftUI

struct HelpCenterView: View {

    private let faqs: [(question: String, answer: String)] = [
        ("How do I send money?",
         "Go to Dashboard > Transfer, pick a contact, enter an amount and confirm with your 4-digit transaction PIN."),
        ("Where is my spending summary?",
         "Open Dashboard > Spending. Totals, graphs and categories are scoped to your primary bank account."),
        ("How do I change my primary account?",
         "Open Profile > Bank accounts & cards and tap Set as primary on the account you want to use."),
        ("My transfer failed. What should I do?",
         "Check your balance, verify the recipient, and try again. If balance was debited, contact support with the transaction time."),
        ("How do I update my details?",
         "Open Profile > Personal details, tap Edit, update your name or email, then Save changes.")
    ]

    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("How can we help?")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Color("primaryText"))
                        .padding(.top, 8)

                    Text("Find answers or reach SwiftPay support")
                        .font(.subheadline)
                        .foregroundStyle(Color("secondaryText"))
                        .padding(.top, 4)

                    // Contact card
                    HStack(spacing: 12) {
                        Image(systemName: "headphones")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 1.0, green: 0.56, blue: 0.25),
                                        Color(red: 0.94, green: 0.27, blue: 0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Contact support")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color("primaryText"))
                            Text("support@swiftpay.app · Mon–Sat, 9am–7pm")
                                .font(.caption)
                                .foregroundStyle(Color("secondaryText"))
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color("mutedText"))
                    }
                    .padding(14)
                    .glassEffect(.regular, in: .rect)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .padding(.top, 16)

                    Text("FAQs")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(Color("primaryText"))
                        .padding(.top, 24)

                    VStack(spacing: 12) {
                        ForEach(faqs.indices, id: \.self) { index in
                            DisclosureGroup {
                                Text(faqs[index].answer)
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color("secondaryText"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 6)
                            } label: {
                                Text(faqs[index].question)
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color("primaryText"))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(14)
                            .background(Color("surface").opacity(0.6))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationTitle("Help center")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        HelpCenterView()
    }
    .preferredColorScheme(.dark)
}
