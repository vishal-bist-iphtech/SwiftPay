//
//  UserAvatarHeader.swift
//  SwiftPay
//

import SwiftUI
import PhotosUI

struct UserAvatarHeader: View {

    let profileImage: Image
    let name: String
    let email: String
    let memberSinceText: String
    let isEditing: Bool
    @Binding var photoItem: PhotosPickerItem?

    var body: some View {
        HStack(spacing: 16) {
            ZStack(alignment: .bottomTrailing) {
                profileImage
                    .resizable()
                    .scaledToFill()
                    .frame(width: 84, height: 84)
                    .background(Color("surface"))
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .stroke(Color("border").opacity(0.4), lineWidth: 1)
                    }

                if isEditing {
                    PhotosPicker(selection: $photoItem, matching: .images) {
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
                    .buttonStyle(.plain)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(name.isEmpty ? "SwiftPay User" : name)
                    .font(.title3.bold())
                    .foregroundStyle(Color("primaryText"))
                    .lineLimit(1)

                Text(email.isEmpty ? "example@email.com" : email)
                    .font(.subheadline)
                    .foregroundStyle(Color("secondaryText"))
                    .lineLimit(1)

                Text("Member since \(memberSinceText)")
                    .font(.caption)
                    .foregroundStyle(Color("mutedText"))
            }

            Spacer()
        }
        .padding(16)
        .glassEffect(.regular, in: .rect)
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }
}
