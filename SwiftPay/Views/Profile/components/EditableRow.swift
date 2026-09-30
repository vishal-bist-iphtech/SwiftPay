//
//  EditableRow.swift
//  SwiftPay
//
//  Label + view/edit field used in UserDetailsView.
//  Parent owns `isEditing` and focus state; this view is purely presentational.
//

import SwiftUI

/// Focusable fields in the personal-details form.
/// Top-level (not nested in the view) so both the component and its parent share it.
/// Note: phone is intentionally absent — it is identity and is display-only.
enum UserDetailsField: Hashable {
    case name, email
}

struct EditableRow: View {

    let label: String
    let placeholder: String
    @Binding var text: String
    let field: UserDetailsField
    let keyboard: UIKeyboardType
    let textContent: UITextContentType
    let isEditing: Bool
    let focused: FocusState<UserDetailsField?>.Binding

    init(
        label: String,
        placeholder: String,
        text: Binding<String>,
        field: UserDetailsField,
        keyboard: UIKeyboardType,
        textContent: UITextContentType,
        isEditing: Bool,
        focused: FocusState<UserDetailsField?>.Binding
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
        self.field = field
        self.keyboard = keyboard
        self.textContent = textContent
        self.isEditing = isEditing
        self.focused = focused
    }

    var body: some View {

        VStack(alignment: .leading, spacing: 6) {
            FieldLabel(label)
            if isEditing {
                HStack(spacing: 6) {
                    TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(Color("mutedText")))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color("primaryText"))
                        .keyboardType(keyboard)
                        .textContentType(textContent)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(field == .email ? .never : .words)
                        .focused(focused, equals: field)
                }
                .padding(.horizontal, 14)
                .frame(height: 50)
                .background(Color("surface"))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay {
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            focused.wrappedValue == field ? Color("accentColor").opacity(0.6) : Color("border").opacity(0.3),
                            lineWidth: 1
                        )
                }
            } else {
                Text(displayText)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color("primaryText"))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .frame(minHeight: 50)
                    .background(Color("surface").opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
    }

    private var displayText: String {
        return text.isEmpty ? "—" : text
    }
}
