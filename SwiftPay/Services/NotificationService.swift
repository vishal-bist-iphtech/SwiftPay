//
//  NotificationService.swift
//  SwiftPay
//

import SwiftUI
import Combine
import UserNotifications


final class NotificationService: ObservableObject {

    /// In-app history, newest first.
    @Published private(set) var notifications: [AppNotification] = []
    /// Top banner currently on screen (dismisses after a few seconds).
    @Published var banner: AppNotification?
    /// Presents the notification sheet (bell icon).
    @Published var showingSheet = false

    @AppStorage("SwiftPay.pushEnabled") var isPushEnabled: Bool = true

    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }

    // MARK: - Permission

    func requestPermissionIfNeeded() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .notDetermined else { return }
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
        }
    }

    // MARK: - Debit notification
    
    func scheduleDebitNotification(
        amount: Double,
        remainingBalance: Double,
        currencyCode: String = "USD",
        bankName: String = "",
        recipientName: String = "",
        delay: TimeInterval = 2.0
    ) {
        let item = AppNotification(
            amount: amount,
            remainingBalance: remainingBalance,
            currencyCode: currencyCode,
            bankName: bankName,
            recipientName: recipientName,
            date: Date().addingTimeInterval(delay)
        )

        // Real local push (respects the Profile toggle).
        if isPushEnabled {
            let content = UNMutableNotificationContent()
            content.title = item.title
            content.body = item.body
            content.sound = .default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(delay, 0.5), repeats: false)
            let request = UNNotificationRequest(
                identifier: item.id.uuidString,
                content: content,
                trigger: trigger
            )
            UNUserNotificationCenter.current().add(request)
        }

        // In-app record + banner after the same delay.
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            guard let self else { return }
            self.notifications.insert(item, at: 0)
            self.banner = item
            // Auto-dismiss banner.
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) { [weak self] in
                if self?.banner?.id == item.id {
                    self?.banner = nil
                }
            }
        }
    }

    // MARK: - Sheet helpers

    func openSheet() {
        showingSheet = true
    }

    func markAllRead() {
        for index in notifications.indices {
            notifications[index].isRead = true
        }
    }

    func markRead(_ notification: AppNotification) {
        guard let index = notifications.firstIndex(where: { $0.id == notification.id }) else { return }
        notifications[index].isRead = true
    }

    func dismissBanner() {
        banner = nil
    }

    func clearAll() {
        notifications = []
        banner = nil
    }
}
