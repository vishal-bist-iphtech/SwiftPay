//
//  AppBrand.swift
//  SwiftPay
//
//  Shared brand colors / gradients to avoid hardcoded duplication.
//

import SwiftUI

enum AppBrand {
    static let start = Color(red: 1.0, green: 0.56, blue: 0.25)
    static let end = Color(red: 0.94, green: 0.27, blue: 0.2)
    static let accent = Color(red: 0.95, green: 0.45, blue: 0.2)
}

extension LinearGradient {
    /// Primary orange-red action gradient used across save / CTA buttons.
    static var primaryAction: LinearGradient {
        LinearGradient(
            colors: [AppBrand.start, AppBrand.end],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}
