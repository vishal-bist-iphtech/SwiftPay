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
    static let lsSubheading = "Track spending, manage your budget, and understand your finances in one place"
    
    static let lsLoginText = "Already have an account?"
    
    
    // MARK: AuthView
    
    /// LoginScreenHeading
    static let asHeading = "Welcome to SwiftPay"
    static let asSubheading = "Enter your phone number to continue"
    
    
    /// SignupScreenHeading
    static let ssHeading = "Complete your profile"
    static let ssSubheading = "Add few more details to complete account set-up"
    static let noName = "Please Enter Your Name"
    static let notLoggedIn = "No user found. Please log-in again"
    
    
    /// confimation message
    static let logoutMessage = "Are you sure you want to logout?"
    static let deleteAccountMessage = "This will permanently delete your account, linked bank accounts, contacts and transaction history. This cannot be undone."
    static let deleteAccountFailed = "Could not delete your account. Please try again."
    
    // MARK: Add Account Screen
    static let aaHeading = "Connect your money"
    static let aaSubheading = "Add an account to see your full financial picture in one place"
    static let selectBank = "Please select your bank"
    static let invalidBank = "Please choose a supported bank"
    static let last4digits = "Enter the last 4 digits of your card"
    static let last4Mismatch = "Last 4 digits must match your account number"
    static let selectCardNtw = "Please select your card network"
    static let invalidCardNtw = "Please choose a supported card network"
    static let duplicateAccount = "This account is already linked"
    static let invalidCVVLength = "CVV must be 3–4 digits"
    
    // MARK: Transfer Screen
    static let noAccount = "No account found. Please add an account first"
    static let insufficientBal = "Insufficient Balance"
    static let noRecipient = "Please select a recipient"

    // MARK: Auth errors
    
    static let authCreateAccountFailed = "Error while creating account"
    
    // MARK: Validation errors
    
    static let inValidName = "Please Enter Valid Name"
    static let inValidEmail = "Please Enter Valid Email Address"
    static let inValidPhone = "Enter a valid phone number"
    static let inValidAmt = "Please enter a valid amount"
    static let inValidCVV = "Enter a valid CVV"
    static let inValidAcc = "Enter a valid account number (min 12 digits)"
    static let noBankAdded = "No bank account added"
    static let noAccName = "Enter the account holder name"


    // MARK: Empty state
    
    static let emptyStateNoTransactions = "No transactions yet"
    static let emptyStateNoTransactionsHint = "Your recent activity will appear here"
    static let emptyStateNoContacts = "No contact added"
    static let emptyStateNoContactsHint = "Add a contact to send money fast"
    static let emptyStateNoAccount = "Link your account"
}
