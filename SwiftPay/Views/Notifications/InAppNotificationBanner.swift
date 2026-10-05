//
//  InAppNotificationBanner.swift
//  SwiftPay
//
//  Top banner mimicking a push, shown 2s after a transfer.
//  Tapping opens the notification sheet.
//

import SwiftUI

struct InAppNotificationBanner: View {

    @EnvironmentObject var service: NotificationService

    var body: some View {
        if let item = service.banner {
            Button {
                service.dismissBanner()
                service.openSheet()
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.down.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                        Text(item.body)
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.85))
                            .lineLimit(2)
                    }

                    Spacer(minLength: 8)

                    Button {
                        service.dismissBanner()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                }
                .padding(14)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.2, green: 0.22, blue: 0.26),
                            Color(red: 0.12, green: 0.13, blue: 0.16)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.25), radius: 16, x: 0, y: 8)
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .buttonStyle(.plain)
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

#Preview {
    let service = NotificationService()
    return ZStack {
        Color.gray.ignoresSafeArea()
        VStack {
            InAppNotificationBanner()
                .environmentObject(service)
            Spacer()
        }
    }
    .onAppear {
        service.banner = AppNotification(
            amount: 250,
            remainingBalance: 5750,
            recipientName: "Olivia"
        )
    }
}
