# SwiftPay

**Spend Smarter**

SwiftPay is a native iOS personal finance app built with SwiftUI + Core Data. Track spending, manage bank accounts, send money to contacts, and understand your finances in one place — with offline-first persistence.

> Built with SwiftUI, MVVM, Core Data, and Combine.

---

## Features

### Auth & Session
- Splash screen with session restore (cold-start login persistence via `UserDefaults` + Core Data)
- Landing → Login → Signup flow driven by `AppRouter`
- Signup with name, email, phone + profile image
- Logout + permanent Delete Account (wipes user, accounts, contacts, transactions)

### Dashboard
- Welcome header with user avatar (tappable → Profile)
- Primary account credit-card view (balance, currency, bank, masked number)
- Quick Actions: Add Account, Transfer, Spending
- Quick Transfer contacts grid (expandable, add contact inline)
- Recent transactions list with empty state

### Bank Accounts
- Connect your money: bank name, account holder, account number (12+ digits validation), card network, account type
- Last-4-digit + masked number formatting
- Primary account selection, balance tracking
- Empty state → Link your account

### Money Transfer
- Custom numpad amount entry
- Recipient picker from contacts + Add Contact sheet (name, phone, photo)
- Source account picker, balance + insufficient-balance validation
- Transfer success animation → auto-push to Transaction Details

### Transactions
- Full history with search, category filter, income/expense filter, and sort
- Transaction details: title, category, amount, date, status, paidTo / paidWith, note
- Edit + Delete transaction (balance-aware)

### Spending Analytics
- Monthly picker sheet
- Total spent / income summary + category breakdown
- Analytics graph (Swift Charts) + per-category rows
- Compact cards for top insights

### Profile
- User details editing (name, email, phone, avatar) with validation
- Bank accounts list with set-primary / delete
- Account card with masked numbers
- Logout confirmation

---

## Tech Stack

- **Language:** Swift 5.0
- **UI:** SwiftUI + Swift Charts
- **Architecture:** MVVM + Router (`AppRouter`) + Session (`AppSession`) + Store (`AccountStore`)
- **Persistence:** Core Data (`NSPersistentContainer` named `SwiftPay`)
- **Reactive:** Combine (`@Published`, `@StateObject`, `@EnvironmentObject`)
- **State:** Centralized ViewModels injected via `ContentView`:
  `AuthViewModel`, `DashboardViewModel`, `TransferViewModel`, `SpendingViewModel`, `TransactionViewModel`, `BankDetailsViewModel`, `UserDetailsViewModel`

---

## Project Structure
```
SwiftPay/
  ├── App/
  │   ├── SwiftPayApp.swift      # @main, PersistenceController init
  │   └── ContentView.swift      # Creates all ViewModels/Stores
  ├── Models/
  │   ├── Transaction.swift      
  │   ├── BankAccount.swift
  │   └── Contact.swift
  ├── Persistence/
  │   ├── Persistence.swift      # PersistenceController (shared + preview/inMemory)
  │   └── SwiftPay.xcdatamodeld  # Core Data model
  ├── Services/
  │   ├── AppRouter.swift        # splash | landing | login | signup | main
  │   ├── AppSession.swift       # currentUser, login/logout/restore
  │   ├── AccountStore.swift     # accounts + balances source of truth
  │   └── CoreDataService.swift  # core data functions
  ├── ViewModels/
  │   ├── AuthViewModel.swift
  │   ├── DashboardViewModel.swift
  │   ├── TransferViewModel.swift
  │   ├── TransactionViewModel.swift
  │   ├── SpendingViewModel.swift
  │   ├── BankDetailsViewModel.swift
  │   └── UserDetailsViewModel.swift
  ├── Views/
  │   ├── SplashScreenView.swift
  │   ├── LandingScreenView.swift
  │   ├── RootView.swift         # router switch
  │   ├── Auth/         
  │   ├── Dashboard/       
  │   ├── Add Account/      
  │   ├── MoneyTransfer/     
  │   ├── Transaction/       
  │   ├── Spending/           
  │   └── Profile/           
  └── Utils/
      ├── Strings.swift          # AppStrings (centralized strings + validation messages)
      └── AccountFormatting.swift
```
---

## Requirements

- Xcode 16+ (project: Swift 5.0, `IPHONEOS_DEPLOYMENT_TARGET = 26.5`)
- iOS Simulator / Device running the deployment target
- No third-party dependencies – Swift Package Manager not required

---

## Getting Started

1. Clone the repo:
   ```bash
   git clone https://github.com/vishal-bist-iphtech/SwiftPay.git
   cd SwiftPay
2. Open in Xcode:
open SwiftPay.xcodeproj
3. Pick a simulator (e.g. iPhone 16 Pro) and press Cmd + R to build & run.
No .env, no API keys, no SPM packages – data is 100% local via Core Data.
Usage
1. Launch → Splash → Landing → Sign up (name + email + phone).
2. Dashboard → Add account – add a bank account to get a starting balance.
3. Quick Transfer → Add contact – add a recipient.
4. Transfer – enter amount on numpad, pick contact + account, confirm.
5. Transactions → See all – search / filter / tap for details / edit / delete.
6. Spending – pick a month, view charts + category breakdown.
7. Avatar → Profile – edit user details, manage bank accounts, logout.
   

