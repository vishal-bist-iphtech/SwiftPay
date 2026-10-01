//
//  ContactPickerSheet.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 28/09/26.
//

import SwiftUI

/// Sheet listing saved recipients (Core Data contacts).
struct ContactPickerSheet: View {
    
    let contacts: [Contact]
    let selected: Contact?
    let onSelect: (Contact) -> Void
    /// Adds a recipient; returns an error message, or nil on success.
    let onAddContact: (String, String) -> String?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var newName = ""
    @State private var newPhone = ""
    @State private var addError: String?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: Add recipient
                VStack(spacing: 10) {
                    TextField(
                        "",
                        text: $newName,
                        prompt: Text("Name")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundStyle(Color("mutedText").opacity(0.7))
                    )
                    .font(.system(size: 14))
                    .foregroundStyle(Color("primaryText"))
                    .padding(.horizontal, 12)
                    .frame(height: 44)
                    .background(Color("surface"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    
                    HStack(spacing: 10) {
                        TextField(
                            "",
                            text: $newPhone,
                            prompt: Text("Phone")
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(Color("mutedText").opacity(0.7))
                        )
                        .font(.system(size: 14))
                        .foregroundStyle(Color("primaryText"))
                        .keyboardType(.phonePad)
                        .padding(.horizontal, 12)
                        .frame(height: 44)
                        .background(Color("surface"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        Button {
                            addError = onAddContact(newName, newPhone)
                            if addError == nil {
                                newName = ""
                                newPhone = ""
                            }
                        } label: {
                            Text("Add")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 18)
                                .frame(height: 44)
                                .background(Color(red: 0.95, green: 0.45, blue: 0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.5 : 1)
                    }
                    
                    if let addError {
                        Text(addError)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(Color("accentColor"))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(16)
            }
            .background(Color("background"))
            .navigationTitle("Contacts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContactPickerSheet(
        contacts: [
            Contact(name: "Olivia", phone: "+91 1234567899", imageName: "demo_image8")
        ],
        selected: nil,
        onSelect: { _ in },
        onAddContact: { _, _ in nil }
    )
}
