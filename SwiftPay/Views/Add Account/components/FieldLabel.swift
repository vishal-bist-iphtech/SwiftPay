//
//  FieldLabel.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 28/09/26.
//

import SwiftUI

struct FieldLabel: View {
    let title: String
    var size: CGFloat = 13

    init(_ title: String, size: CGFloat = 13) {
        self.title = title
        self.size = size
    }

    var body: some View {
        Text(title)
            .font(.system(size: size, weight: .medium))
            .foregroundStyle(Color("secondaryText"))
    }
}
