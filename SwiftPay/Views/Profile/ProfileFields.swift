//
//  ProfileFields.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 22/09/26.
//

import SwiftUI


struct ProfileSection<Content: View>: View {

    // <Content: View> -> Generic type parameter
    let title: String
    
    // using viewbuilder to add multiple views in the trailing closure without wrapping them in a vstack/group.
    @ViewBuilder let content: Content

    var body: some View {

        Text(title)
            .font(.title3)
            .fontWeight(.medium)
            .foregroundStyle(Color("primaryText"))
            .padding(.top, 24)

        VStack(spacing: 2) {
            content
        }
        .padding(6)
        .glassEffect(.regular, in: .rect)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .padding(.top, 10)
    }
}

struct ProfileRow: View {

    let icon: String
    let title: String
    var subtitle: String? = nil
    var value: String? = nil

    var body: some View {

        HStack(spacing: 14) {

            Image(systemName: icon)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color("primaryText"))
                .frame(width: 40, height: 40)
                .background(Color("surface"))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color("primaryText"))

                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color("secondaryText"))
                }
            }

            Spacer()

            if let value {
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(Color("mutedText"))
            }

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color("mutedText"))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
    }
}

struct ProfileToggleRow: View {

    let icon: String
    let title: String
    @Binding var isOn: Bool

    var body: some View {

        HStack(spacing: 14) {

            Image(systemName: icon)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color("primaryText"))
                .frame(width: 40, height: 40)
                .background(Color("surface"))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color("primaryText"))
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color("darkRed"))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
    }
}

