//
//  String.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 21/09/26.
//

import SwiftUI


enum AppStrings {
    
    static let appName = "SwiftPay"
    
    // MARK: LandingScreenView
    
    /// LandingScreenHeading
    static let lsSubheading = "Track spending, manage your budget, and understand your finances in one place."
    
    static let lsLoginText = "Already have an account?"
    
    
    // MARK: AuthView
    
    /// LoginScreenHeading
    static let asHeading = "Welcome to SwiftPay"
    static let asSubheading = "Enter your phone number to continue."
    
    
    /// SignupScreenHeading
    static let ssHeading = "Complete your profile"
    static let ssSubheading = "Add few more details to complete account set-up."
    static let noName = "Please Enter Your Name"
    static let validName = "Please Enter Valid Name"
    static let validEmail = "Please Enter Valid Email Address"
    static let validPhone = "Enter a valid phone number"
    static let notLoggedIn = "No user found. Please log-in again"
    
    
    /// confimation message
    static let logoutMessage = "Are you sure you want to logout?"
    
    // MARK: Add Account Screen
    static let aaHeading = "Connect your money"
    static let aaSubheading = "Add an account to see your full financial picture in one place"
    static let validAcc = "Enter a valid account number (min 12 digits)"
    static let noBank = "Please select your bank"
    static let noAccName = "Enter the account holder name"
    static let last4digits = "Enter the last 4 digits of your card"
    static let validCVV = "Enter a valid CVV"
    static let cardNtw = "Please select your card network"
    
    // MARK: Transfer Screen
    static let noAccount = "No account found. Please add an account first."
    static let insufficientBal = "Insufficient Balance"
    static let noRecipient = "Please select a recipient"

    // MARK: Auth errors

    static let authInvalidPhoneNumber = "Enter a valid phone number"
    static let authNameRequired = "Please Enter Your Name"
    static let authNameInvalid = "Please Enter Valid Name"
    static let authEmailInvalid = "Please Enter Valid Email Address"
    static let authCreateAccountFailed = "Error while creating account."
    
    
    // MARK: Empty state
    
    static let emptyStateNoTransactions = "No transactions yet"
    static let emptyStateNoTransactionsHint = "Your recent activity will appear here."
    static let emptyStateNoContacts = "No contact added"
    static let emptyStateNoContactsHint = "Add a contact to send money fast."
    static let emptyStateNoAccount = "Link your account"
}
