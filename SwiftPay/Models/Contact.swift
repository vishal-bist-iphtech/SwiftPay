//
//  TransferRecipient.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 28/09/26.
//

import Foundation


struct Contact: Identifiable, Hashable {
    let id: UUID
    let name: String
    let phone: String
    let imageData: Data?

    init(
        id: UUID = UUID(),
        name: String,
        phone: String = "",
        imageData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.phone = phone
        self.imageData = imageData
    }

    init(entity: ContactEntity) {
        self.id = entity.id ?? UUID()
        self.name = (entity.name ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        self.phone = (entity.phone ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        self.imageData = entity.profileImage
    }

    var initials: String {
        let parts = name.split(separator: " ").filter { !$0.isEmpty }
        let first = parts.first?.first.map(String.init) ?? ""
        let last = parts.count > 1 ? parts.last?.first.map(String.init) ?? "" : ""
        let result = (first + last).uppercased()
        return result.isEmpty ? "?" : result
    }
}
