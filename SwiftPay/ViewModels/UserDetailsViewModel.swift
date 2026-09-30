//
//  UserDetailsViewModel.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 29/09/26.
//

import Foundation
import Combine
import CoreData
import SwiftUI

final class UserDetailsViewModel: ObservableObject {

    // MARK: - Editable fields
    @Published var name = ""
    @Published var email = ""
    @Published private(set) var phone = ""
    @Published var profileImageData: Data?

    // MARK: - UI state
    @Published var isEditing = false
    @Published var isSaving = false
    @Published var errorMessage: String?
    @Published var showSavedToast = false

    /// Read-only meta, fetched from Core Data.
    @Published private(set) var memberSince: Date?
    @Published private(set) var hasUser = false

    var memberSinceText: String {
        guard let memberSince else { return "—" }
        let fmt = DateFormatter()
        fmt.dateStyle = .medium
        return fmt.string(from: memberSince)
    }

    var profileImage: Image {
        if let data = profileImageData,
        let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        return Image("demo_image1")
    }

    private let service: CoreDataService
    private let session: AppSession
    private var cancellables = Set<AnyCancellable>()

    init(context: NSManagedObjectContext, session: AppSession) {
        self.service = CoreDataService(context: context)
        self.session = session

        load(for: session.currentUser)

        // Reload whenever login/logout/switch happens.
        session.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.load(for: $0) }
            .store(in: &cancellables)
    }

    // MARK: - Fetch

    /// Loads the current user's persisted details into the form.
    func load(for user: UserEntity?) {
        guard let user else {
            hasUser = false
            name = ""
            email = ""
            phone = ""
            profileImageData = nil
            memberSince = nil
            isEditing = false
            return
        }
        hasUser = true
        name = user.name ?? ""
        email = user.email ?? ""
        phone = user.phone ?? ""
        profileImageData = user.profileImage
        memberSince = user.createdAt
        errorMessage = nil
        isEditing = false
        showSavedToast = false
    }

    func refresh() {
        load(for: session.currentUser)
    }

    // MARK: - Edit

    func beginEditing() {
        errorMessage = nil
        showSavedToast = false
        isEditing = true
    }

    func cancelEditing() {
        load(for: session.currentUser)
    }

    // MARK: - Validation
    private func validationError() -> String? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedName.isEmpty { return AppStrings.noName }
        if !isValidName(trimmedName) { return AppStrings.inValidName }
        if !isValidEmail(email.trimmingCharacters(in: .whitespacesAndNewlines)) {
            return AppStrings.inValidEmail
        }
        // Phone is identity and read-only — never validated/edited here.
        return nil
    }

    // MARK: - Save

    /// Validates + persists edits to Core Data, then notifies the session
    /// so Profile/Dashboard headers refresh
    func save() -> Bool {
        errorMessage = nil
        showSavedToast = false

        if let validation = validationError() {
            errorMessage = validation
            return false
        }

        guard let user = session.currentUser else {
            errorMessage = AppStrings.notLoggedIn
            return false
        }

        // Phone is read-only: discard any stale value and keep persisted identity.
        phone = user.phone ?? ""

        isSaving = true
        defer { isSaving = false }

        do {
            try service.updateUser(
                user,
                name: name,
                email: email,
                profileImage: profileImageData
            )
            // Refresh local copy + push UI update to all session observers.
            load(for: user)
            session.objectWillChange.send()
            isEditing = false
            showSavedToast = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showSavedToast = false
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Private validators

    private func isValidEmail(_ email: String) -> Bool {
        let regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return email.range(of: regex, options: .regularExpression) != nil
    }

    private func isValidName(_ name: String) -> Bool {
        guard (2...50).contains(name.count) else { return false }
        let allowed = CharacterSet.letters.union(.whitespaces)
        return name.unicodeScalars.allSatisfy { allowed.contains($0) }
    }
}
