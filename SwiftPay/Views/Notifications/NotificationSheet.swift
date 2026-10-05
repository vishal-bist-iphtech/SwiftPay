//
//  NotificationSheet.swift
//  SwiftPay
//
//  History of debit notifications, opened from the Dashboard bell icon.
//

import SwiftUI

struct NotificationSheet: View {

    @EnvironmentObject var service: NotificationService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Capsule()
                    .fill(Color("mutedText").opacity(0.4))
                    .frame(width: 40, height: 5)
                    .padding(.top, 10)

                HStack {
                    Text("Notifications")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(Color("primaryText"))

                    Spacer()

                    if !service.notifications.isEmpty {
                        Button("Clear all") {
                            service.clearAll()
                        }
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Color("accentColor"))
                    }

                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color("primaryText"))
                            .frame(width: 30, height: 30)
                            .background(Color("surface"))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                if service.notifications.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "bell.slash")
                            .font(.system(size: 28))
                            .foregroundStyle(Color("mutedText"))
                        Text("No notifications yet")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color("primaryText"))
                        Text("Debit alerts will appear here after a transfer")
                            .font(.system(size: 13))
                            .foregroundStyle(Color("mutedText"))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.bottom, 40)
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            ForEach(service.notifications) { item in
                                Button {
                                    service.markRead(item)
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "arrow.down.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundStyle(Color(red: 0.95, green: 0.45, blue: 0.2))

                                        VStack(alignment: .leading, spacing: 3) {
                                            HStack {
                                                Text(item.title)
                                                    .font(.system(size: 14, weight: .semibold))
                                                    .foregroundStyle(Color("primaryText"))
                                                if !item.isRead {
                                                    Circle()
                                                        .fill(Color(red: 0.95, green: 0.45, blue: 0.2))
                                                        .frame(width: 7, height: 7)
                                                }
                                            }
                                            Text(item.body)
                                                .font(.system(size: 13))
                                                .foregroundStyle(Color("secondaryText"))
                                                .multilineTextAlignment(.leading)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            Text(item.timeText)
                                                .font(.caption2)
                                                .foregroundStyle(Color("mutedText"))
                                        }

                                        Spacer(minLength: 4)
                                    }
                                    .padding(14)
                                    .background(Color("surface").opacity(item.isRead ? 0.45 : 0.75))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color("border").opacity(0.3), lineWidth: 1)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 14)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .onAppear {
            // Mark visible items read shortly after opening.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                service.markAllRead()
            }
        }
    }
}

#Preview {
    NotificationSheet()
        .environmentObject(NotificationService())
}
