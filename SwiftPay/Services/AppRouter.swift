//
//  AppRouter.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 18/09/26.
//

import SwiftUI
import Combine

final class AppRouter: ObservableObject {
    
    enum Screen {
        case splash
        case landing
        case login
        case signup
        case main
    }
    
    @Published var screen: Screen = .splash
}
