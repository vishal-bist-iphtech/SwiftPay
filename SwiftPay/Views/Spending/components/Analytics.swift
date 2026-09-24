//
//  Analytics.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 24/09/26.
//

import SwiftUI

struct Analytics: View {

    @ObservedObject var viewModel: SpendingViewModel

    var body: some View {
        VStack(spacing: 0) {

            // MARK: Grabber + header
            VStack(spacing: 12) {

                Capsule()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)

                HStack {
                    Text("Analytics")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("primaryText"))

                    Spacer()

                    Button {

                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 14, weight: .medium))
                            Text("Filter")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundStyle(Color("primaryText"))
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 4)
            .contentShape(Rectangle())

            // MARK: Category rows
            ScrollView(showsIndicators: false) {
                VStack(spacing: 14) {
                    ForEach(viewModel.categories) { category in
                        CategoryRow(category: category)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 30)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color("surface"))
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: 28,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 28
            )
        )
    }
}


#Preview {
    ZStack {
        Color("background").ignoresSafeArea()
        VStack {
            Spacer()
            Analytics(viewModel: SpendingViewModel())
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
