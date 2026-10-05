//
//  Analytics.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 24/09/26.
//

import SwiftUI
import CoreData // Preview environment only; all Core Data work lives in the ViewModels.


struct Analytics: View {

    @ObservedObject var viewModel: SpendingViewModel

    var body: some View {
        VStack(spacing: 0) {

            // MARK: Header
            
            VStack(spacing: 12) {

                Capsule()
                    .fill(Color("mutedText").opacity(0.4))
                    .frame(width: 40, height: 5)
                    .padding(.top, 8)

                HStack {
                    Text("Analytics")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("primaryText"))

                    Spacer()

                    Menu {
                        Button {
                            viewModel.priceFilter = nil
                        } label: {
                            if viewModel.priceFilter == nil {
                                Label("Default", systemImage: "checkmark")
                            } else {
                                Text("Default")
                            }
                        }

                        Button {
                            viewModel.priceFilter = .highest
                        } label: {
                            if viewModel.priceFilter == .highest {
                                Label(CategoryPriceFilter.highest.title, systemImage: "checkmark")
                            } else {
                                Text(CategoryPriceFilter.highest.title)
                            }
                        }

                        Button {
                            viewModel.priceFilter = .lowest
                        } label: {
                            if viewModel.priceFilter == .lowest {
                                Label(CategoryPriceFilter.lowest.title, systemImage: "checkmark")
                            } else {
                                Text(CategoryPriceFilter.lowest.title)
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "slider.horizontal.3")

                            Text(viewModel.priceFilter?.title ?? "Filter")
                        }
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color("primaryText"))
                        .padding(.horizontal, viewModel.priceFilter == nil ? 0 : 10)
                        .padding(.vertical, viewModel.priceFilter == nil ? 0 : 6)
                        .background(
                            viewModel.priceFilter == nil
                                ? Color.clear
                                : Color("primaryText").opacity(0.08),
                            in: RoundedRectangle(cornerRadius: 14)
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.bottom, 4)
            .contentShape(Rectangle())

            // MARK: Category rows
            
            VStack(spacing: 14) {
                if viewModel.filteredCategories.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "tray")
                            .font(.system(size: 22))
                            .foregroundStyle(Color("mutedText"))
                        Text(AppStrings.emptyStateNoTransactions)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color("primaryText"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                } else {
                    ForEach(viewModel.filteredCategories) { category in
                        NavigationLink {
                            TransactionView()
                        } label: {
                            CategoryRow(category: category)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            .padding(.bottom, 30)
            .animation(.easeInOut(duration: 0.2), value: viewModel.priceFilter)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("surface"))
        .clipShape(
            RoundedRectangle(cornerRadius: 22)
        )
    }
}


#Preview {
    let context = PersistenceController.preview.container.viewContext
    let session = AppSession()
    let store = AccountStore(context: context, session: session)
    return ZStack {
        Color("background").ignoresSafeArea()
        VStack {
            Spacer()
            Analytics(viewModel: SpendingViewModel(store: store))
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
