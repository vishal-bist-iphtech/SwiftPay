//
//  UserDetailsView.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 29/09/26.
//

import SwiftUI
import PhotosUI
import CoreData

struct UserDetailsView: View {

    @EnvironmentObject var viewModel: UserDetailsViewModel

    @State private var photoItem: PhotosPickerItem?
    @FocusState private var focusedField: UserDetailsField?

    var body: some View {

        ZStack {
            Color("background")
                .ignoresSafeArea()
                .onTapGesture { focusedField = nil }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    // MARK: Avatar header
                    UserAvatarHeader(
                        profileImage: viewModel.profileImage,
                        name: viewModel.name,
                        email: viewModel.email,
                        memberSinceText: viewModel.memberSinceText,
                        isEditing: viewModel.isEditing,
                        photoItem: $photoItem
                    )
                    .padding(.top, 12)

                    if viewModel.showSavedToast {
                        Label("Changes saved", systemImage: "checkmark.circle.fill")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.green)
                            .padding(.top, 12)
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color("accentColor"))
                            .padding(.top, 12)
                    }

                    // MARK: Personal info
                    Text("Personal info")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(Color("primaryText"))
                        .padding(.top, 24)

                    VStack(spacing: 0) {
                        EditableRow(
                            label: "Full name",
                            placeholder: "Your name",
                            text: $viewModel.name,
                            field: .name,
                            keyboard: .default,
                            textContent: .name,
                            isEditing: viewModel.isEditing,
                            focused: $focusedField
                        )

                        Divider()
                            .background(Color("border").opacity(0.4))
                            .padding(.horizontal, 14)

                        EditableRow(
                            label: "Email",
                            placeholder: "example@email.com",
                            text: $viewModel.email,
                            field: .email,
                            keyboard: .emailAddress,
                            textContent: .emailAddress,
                            isEditing: viewModel.isEditing,
                            focused: $focusedField
                        )

                        Divider()
                            .background(Color("border").opacity(0.4))
                            .padding(.horizontal, 14)

                        // Phone is identity / login key — display only, never editable.
                        VStack(alignment: .leading, spacing: 6) {
                            FieldLabel("Phone")
                            Text(viewModel.phone.isEmpty ? "—" : "+\(viewModel.phone)")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color("primaryText"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 14)
                                .frame(minHeight: 50)
                                .background(Color("surface").opacity(0.6))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                    }
                    .padding(.vertical, 6)
                    .glassEffect(.regular, in: .rect)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .padding(.top, 10)

                    // MARK: Read-only meta
                    Text("Account")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(Color("primaryText"))
                        .padding(.top, 24)

                    VStack(spacing: 0) {
                        MetaRow(label: "Member since", value: viewModel.memberSinceText)
                    }
                    .padding(.vertical, 6)
                    .glassEffect(.regular, in: .rect)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                    .padding(.top, 10)

                    // MARK: Save / Cancel
                    if viewModel.isEditing {
                        Button {
                            focusedField = nil
                            _ = viewModel.save()
                        } label: {
                            ZStack {
                                Text("Save changes")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .opacity(viewModel.isSaving ? 0 : 1)
                                if viewModel.isSaving {
                                    ProgressView().tint(.white)
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
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                        }
                        .disabled(viewModel.isSaving)
                        .padding(.top, 22)

                        Button {
                            focusedField = nil
                            viewModel.cancelEditing()
                        } label: {
                            Text("Cancel")
                                .font(.headline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color("secondaryText"))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                        }
                        .padding(.top, 4)
                    }

                    Color.clear.frame(height: 30)
                }
                .padding(.horizontal, 20)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .navigationTitle("Personal Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if viewModel.isEditing {
                        focusedField = nil
                        _ = viewModel.save()
                    } else {
                        viewModel.beginEditing()
                    }
                } label: {
                    Text(viewModel.isEditing ? "Save" : "Edit")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(Color("accentColor"))
                }
            }
            .sharedBackgroundVisibility(.hidden)
        }
        .onAppear {
            viewModel.refresh()
        }
        .onChange(of: photoItem) { _, newItem in
            Task {
                guard let data = try? await newItem?.loadTransferable(type: Data.self) else { return }
                await MainActor.run {
                    viewModel.profileImageData = data
                    viewModel.showSavedToast = false
                }
            }
        }
    }
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let session = AppSession()
    return NavigationStack {
        UserDetailsView()
            .environmentObject(UserDetailsViewModel(session: session))
            .environment(\.managedObjectContext, context)
    }
    .preferredColorScheme(.dark)
}
