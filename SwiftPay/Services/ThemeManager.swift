//
//  ThemeManager.swift
//  SwiftPay
//


import SwiftUI
import Combine

final class ThemeManager: ObservableObject {

    @AppStorage("SwiftPay.isDarkMode") var isDarkMode: Bool = true {
        willSet {
            objectWillChange.send()
        }
    }

    var colorScheme: ColorScheme {
        isDarkMode ? .dark : .light
    }
}
