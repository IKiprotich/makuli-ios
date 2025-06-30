//
//  MakuliApp.swift
//  Makuli
//
//  Created by Ian   on 18/06/2025.
//

import SwiftUI
import GoogleSignIn

@main
struct MakuliApp: App {
    
    init() {
        _ = SupabaseManager.shared
        Logger.info("Supabase initialized")
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
