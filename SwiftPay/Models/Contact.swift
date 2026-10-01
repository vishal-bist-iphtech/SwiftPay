//
//  TransferRecipient.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 28/09/26.
//

import Foundation

/// Contacts shown in Quick Transfer and in the Transfer sheet.
struct Contact: Identifiable, Hashable {
    let id: String
    let name: String
    let phone: String
    let imageName: String

    static let emma = Contact(
        id: "emma",
        name: "Emma",
        phone: "+91 9876543210",
        imageName: "demo_image6"
    )

    static let james = Contact(
        id: "james",
        name: "James",
        phone: "+91 9876543211",
        imageName: "demo_image7"
    )

    static let olivia = Contact(
        id: "olivia",
        name: "Olivia",
        phone: "+91 1234567899",
        imageName: "demo_image8"
    )

    static let jenny = Contact(
        id: "jenny",
        name: "Jenny",
        phone: "+91 9876543212",
        imageName: "demo_image5"
    )
    
    static let jane = Contact(
        id: "jane",
        name: "Jane",
        phone: "+91 9876543210",
        imageName: "demo_image9"
    )

    static let mark = Contact(
        id: "mark",
        name: "Mark",
        phone: "+91 9876543211",
        imageName: "demo_image2"
    )

    static let henry = Contact(
        id: "henry",
        name: "Henry",
        phone: "+91 1234567899",
        imageName: "demo_image3"
    )

    static let nitin = Contact(
        id: "nitin",
        name: "Nitin",
        phone: "+91 9876543212",
        imageName: "demo_image4"
    )

    
    static let nayan = Contact(
        id: "nayan",
        name: "Nayan",
        phone: "+91 9876543212",
        imageName: "demo_image1"
    )
    
    
    static let all: [Contact] = [.emma, .james, .olivia, .jenny, .jane, .mark, .henry, .nitin, .nayan]

    static func matching(name: String) -> Contact? {
        all.first { $0.name == name }
    }
}
