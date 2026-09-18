//
//  ContentView.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 18/09/26.
//

import SwiftUI
import CoreData

struct ContentView: View {

    var body: some View {
        
            Text("SwiftPay")
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
