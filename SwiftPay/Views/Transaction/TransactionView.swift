//
//  TransactionView.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 30/09/26.
//

import SwiftUI
import CoreData

/// Transactions screen — replicates the shared screenshot.
/// No bottom TabBar here; this view is pushed from Dashboard ("See all").
/// - Tap a row -> TransactionDetailsView
/// - Slide trailing -> Delete, slide leading -> Edit
struct TransactionView: View {

    @EnvironmentObject var viewModel: TransactionViewModel
    @EnvironmentObject var session: AppSession

    @State private var showingAdd = false
    @State private var editingTransaction: Transaction?
    @State private var selectedTransaction: Transaction?
    @State private var showingFilter = false
    @State private var showingDeleteConfirm: Transaction?

    var body: some View {

        ZStack {
            Color("background")
                .ignoresSafeArea()

            List {
                // MARK: Header (monthly + search) — not swipeable
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(viewModel.monthTitle)
                                .font(.system(size: 11, weight: .medium))
                                .tracking(0.5)
                                .foregroundStyle(Color("mutedText"))
                            Text(viewModel.monthlySpendingText)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(Color("primaryText"))
                        }

                        HStack(spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color("mutedText").opacity(0.8))

                                TextField(
                                    "",
                                    text: $viewModel.searchText,
                                    prompt: Text("Search transactions")
                                        .font(.system(size: 14, weight: .regular))
                                        .foregroundStyle(Color("mutedText").opacity(0.7))
                                )
                                .font(.system(size: 14))
                                .foregroundStyle(Color("primaryText"))
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)

                                if !viewModel.searchText.isEmpty {
                                    Button {
                                        viewModel.searchText = ""
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 14))
                                            .foregroundStyle(Color("mutedText"))
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            .frame(height: 46)
                            .background(Color("surface"))
                            .clipShape(RoundedRectangle(cornerRadius: 14))

                            Button {
                                showingFilter = true
                            } label: {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .frame(width: 46, height: 46)
                                    .background(
                                        viewModel.selectedCategory == nil
                                        ? Color(red: 0.95, green: 0.45, blue: 0.2)
                                        : Color(red: 0.95, green: 0.45, blue: 0.2).opacity(0.7)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }

                        if let cat = viewModel.selectedCategory {
                            HStack(spacing: 6) {
                                Text(cat)
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundStyle(Color("primaryText"))
                                Button {
                                    viewModel.selectedCategory = nil
                                } label: {
                                    Image(systemName: "xmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(Color("mutedText"))
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 7)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 0, trailing: 16))
                }

                // MARK: Transaction groups
                if !viewModel.hasTransactions {
                    Section {
                        emptyState(
                            icon: "tray",
                            title: AppStrings.emptyStateNoTransactions,
                            subtitle: AppStrings.emptyStateNoTransactionsHint,
                            showAddButton: true
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                } else if !viewModel.hasFilteredResults {
                    Section {
                        emptyState(
                            icon: "magnifyingglass",
                            title: "No results",
                            subtitle: "Try a different search or category",
                            showAddButton: false
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                } else {
                    ForEach(viewModel.groupedSections) { section in
                        Section {
                            ForEach(section.transactions) { tx in
                                Button {
                                    selectedTransaction = tx
                                } label: {
                                    TransactionRowContent(transaction: tx)
                                }
                                .buttonStyle(.plain)
                                .listRowBackground(Color("surface").opacity(0.55))
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                                // Slide trailing -> Delete
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        showingDeleteConfirm = tx
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                // Slide leading -> Edit
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    Button {
                                        editingTransaction = tx
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(Color(red: 0.95, green: 0.45, blue: 0.2))
                                }
                                .contextMenu {
                                    Button {
                                        selectedTransaction = tx
                                    } label: {
                                        Label("View details", systemImage: "eye")
                                    }
                                    Button {
                                        editingTransaction = tx
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    Button(role: .destructive) {
                                        showingDeleteConfirm = tx
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        } header: {
                            HStack {
                                Text(section.title)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color("mutedText"))
                                    .textCase(nil)
                                Spacer()
                                Text(TransactionFormat.sectionTotalText(section.total))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundStyle(Color("mutedText"))
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Transactions")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAdd = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .semibold))
                }
            }
            .sharedBackgroundVisibility(.hidden)
        }
        .onAppear {
            viewModel.refresh()
        }
        // Tap -> details
        .navigationDestination(item: $selectedTransaction) { tx in
            TransactionDetailsView(transaction: tx)
        }
        .sheet(isPresented: $showingAdd) {
            TransactionSheet(viewModel: viewModel, transaction: nil)
        }
        .sheet(item: $editingTransaction) { tx in
            TransactionSheet(viewModel: viewModel, transaction: tx)
        }
        .sheet(isPresented: $showingFilter) {
            CategoryFilterSheet(viewModel: viewModel)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .alert(
            "Delete transaction?",
            isPresented: Binding(
                get: { showingDeleteConfirm != nil },
                set: { if !$0 { showingDeleteConfirm = nil } }
            )
        ) {
            Button("Delete", role: .destructive) {
                if let tx = showingDeleteConfirm {
                    viewModel.deleteTransaction(tx)
                    if selectedTransaction?.id == tx.id {
                        selectedTransaction = nil
                    }
                }
                showingDeleteConfirm = nil
            }
            Button("Cancel", role: .cancel) {
                showingDeleteConfirm = nil
            }
        } message: {
            if let tx = showingDeleteConfirm {
                Text("“\(tx.title)” will be permanently removed.")
            }
        }
    }

    // MARK: - Empty state

    private func emptyState(icon: String, title: String, subtitle: String, showAddButton: Bool) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundStyle(Color("mutedText"))
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(Color("primaryText"))
            Text(subtitle)
                .font(.system(size: 13))
                .foregroundStyle(Color("mutedText"))
            if showAddButton {
                Button {
                    showingAdd = true
                } label: {
                    Text("Add transaction")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Color(red: 0.95, green: 0.45, blue: 0.2))
                        .clipShape(Capsule())
                }
                .padding(.top, 4)
            }
            if viewModel.selectedCategory != nil || !viewModel.searchText.isEmpty {
                Button("Clear filters") {
                    viewModel.clearFilters()
                }
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color(red: 0.95, green: 0.45, blue: 0.2))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color("surface").opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}


#Preview {
    let context = PersistenceController.preview.container.viewContext
    let session = AppSession()
    let store = AccountStore(context: context, session: session)
    let vm = TransactionViewModel(session: session, store: store)
    return NavigationStack {
        TransactionView()
            .environmentObject(vm)
            .environmentObject(session)
    }
    .preferredColorScheme(.dark)
}
