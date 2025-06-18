//
//  MakuliApp.swift
//  Makuli
//
//  Created by Ian   on 18/06/2025.
//

import SwiftUI
import Firebase


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct MakuliApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
