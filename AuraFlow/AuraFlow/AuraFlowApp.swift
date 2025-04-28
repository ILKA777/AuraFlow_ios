//
//  AuraFlowApp.swift
//  AuraFlow
//
//  Created by Ilya on 26.12.2024.
//

import SwiftUI
import OneSignalFramework

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
          
           // Enable verbose logging for debugging (remove in production)
           OneSignal.Debug.setLogLevel(.LL_VERBOSE)
           // Initialize with your OneSignal App ID
           OneSignal.initialize("e347783d-9e08-4896-92e7-7d475aa4e794", withLaunchOptions: launchOptions)
           // Use this method to prompt for push notifications.
           // We recommend removing this method after testing and instead use In-App Messages to prompt for notification permission.
           OneSignal.Notifications.requestPermission({ accepted in
             print("User accepted notifications: \(accepted)")
           }, fallbackToSettings: false)
          
           return true
        }

}


@main
struct AuraFlowApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}
