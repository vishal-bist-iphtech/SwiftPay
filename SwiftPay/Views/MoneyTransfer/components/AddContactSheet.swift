//
//  AddContactSheet.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 28/09/26.
//

import SwiftUI
import PhotosUI

/// Add-only sheet for saving a new recipient (name + phone + photo)
/// into `ContactEntity`.
struct AddContactSheet: View {

    /// Creates the contact; returns an error message, or nil on success.
    let onAddContact: (String, String, Data?) -> String?

    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var phone = ""
    @State private var photoItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var addError: String?
    @State private var isSaving = false

    private var isNameValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // MARK: Photo
                PhotosPicker(selection: $photoItem, matching: .images) {
                    ZStack(alignment: .bottomTrailing) {
                        contactPhoto
                            .frame(width: 92, height: 92)
                            .background(Color("surface"))
                            .clipShape(Circle())
                            .overlay {
                                Circle()
                                    .stroke(Color("border").opacity(0.4), lineWidth: 1)
                            }

                        Image(systemName: "camera.fill")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .background(Color("accentColor"))
                            .clipShape(Circle())
                            .overlay {
                                Circle()
                                    .stroke(.white.opacity(0.6), lineWidth: 1)
                            }
                    }
                }
                .buttonStyle(.plain)
                .padding(.top, 8)

                // MARK: Fields
                VStack(spacing: 10) {
                    TextField(
                        "",
                        text: $name,
                        prompt: Text("Name")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(Color("mutedText").opacity(0.7))
                    )
                    .font(.system(size: 14))
                    .foregroundStyle(Color("primaryText"))
                    .textContentType(.name)
                    .padding(.horizontal, 12)
                    .frame(height: 48)
                    .background(Color("surface"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    TextField(
                        "",
                        text: $phone,
                        prompt: Text("Phone")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(Color("mutedText").opacity(0.7))
                    )
                    .font(.system(size: 14))
                    .foregroundStyle(Color("primaryText"))
                    .keyboardType(.phonePad)
                    .textContentType(.telephoneNumber)
                    .padding(.horizontal, 12)
                    .frame(height: 48)
                    .background(Color("surface"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    if let addError {
                        Text(addError)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color("accentColor"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                // MARK: Save
                Button {
                    save()
                } label: {
                    ZStack {
                        Text("Save contact")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .opacity(isSaving ? 0 : 1)

                        if isSaving {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(red: 0.95, green: 0.45, blue: 0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(!isNameValid || isSaving)
                .opacity(!isNameValid || isSaving ? 0.6 : 1)

                Spacer()
            }
            .padding(.horizontal, 20)
            .background(Color("background"))
            .navigationTitle("New contact")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onChange(of: photoItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        await MainActor.run { imageData = data }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var contactPhoto: some View {
        if let imageData,
           let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            Image(systemName: "person.fill")
                .font(.largeTitle)
                .foregroundStyle(Color("mutedText"))
        }
    }

    private func save() {
        guard !isSaving else { return }
        isSaving = true
        defer { isSaving = false }
        let error = onAddContact(name, phone, imageData)
        if let error {
            addError = error
        } else {
            dismiss()
        }
    }
}

#Preview {
    AddContactSheet(onAddContact: { _, _, _ in nil })
}
