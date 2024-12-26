//
//  AuraFlowApp.swift
//  AuraFlow
//
//  Created by Ilya on 26.12.2024.
//

import SwiftUI

@main
struct AuraFlowApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
