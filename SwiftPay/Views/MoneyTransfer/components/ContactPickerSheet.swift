//
//  ContactPickerSheet.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 28/09/26.
//

import SwiftUI

/// Sheet listing all Quick Transfer contacts.
struct ContactPickerSheet: View {

    let contacts: [Contact]
    let selected: Contact?
    let onSelect: (Contact) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(contacts) { contact in
                Button {
                    onSelect(contact)
                } label: {
                    HStack(spacing: 14) {
                        Image(contact.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 48, height: 48)
                            .background(Color("surface"))
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 2) {
                            Text(contact.name)
                                .font(.headline)
                                .foregroundStyle(Color("primaryText"))

                            Text(contact.phone)
                                .font(.subheadline)
                                .foregroundStyle(Color("secondaryText"))
                        }

                        Spacer()

                        if selected == contact {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color("accentColor"))
                                .font(.title3)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .buttonStyle(.plain)
                .listRowBackground(Color("surface"))
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Color("background"))
            .navigationTitle("Choose recipient")
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
        contacts: Contact.all,
        selected: .olivia,
        onSelect: { _ in }
    )
}
