//
//  SpendingView.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 24/09/26.
//

import SwiftUI

struct SpendingView: View {

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SpendingViewModel()

    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {

                VStack(spacing: 10) {

                    // MARK: Cards
                    TabView {
                        CompactCard()
                        CompactCard()
                        CompactCard()
                    }
                    .tabViewStyle(.page(indexDisplayMode: .always))
                    .indexViewStyle(.page(backgroundDisplayMode: .interactive))
                    .frame(height: 195)
                    .padding(.horizontal, 20)

                    // MARK: Month total
                    HStack(alignment: .bottom, spacing: 4) {
                        Text("$")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color("mutedText"))
                            .padding(.bottom, 5)

                        Text(viewModel.totalSpent.formatted(.number.precision(.fractionLength(2))))
                            .font(.system(size: 34, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color("primaryText"))

                        Spacer()

                        Button {

                        } label: {
                            HStack(spacing: 4) {
                                Text(viewModel.monthLabel)
                                    .font(.system(size: 14, weight: .medium))
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundStyle(Color("primaryText"))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(
                                Color.white.opacity(0.08),
                                in: RoundedRectangle(cornerRadius: 20)
                            )
                        }
                    }
                    .padding(.horizontal, 20)

                    // MARK: Graph
                    AnalyticsGraph(viewModel: viewModel)
                        .padding(.horizontal, 20)

                    // MARK: Analytics (edge-to-edge)
                    Analytics(viewModel: viewModel)
                }
                .padding(.top, 8)
                .padding(.bottom, 0)
            }
        }
        .navigationTitle("Spending")
        .navigationBarTitleDisplayMode(.inline)
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
}


#Preview {
    NavigationStack {
        SpendingView()
    }
}
