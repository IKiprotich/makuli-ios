////
////  SupabaseManager.swift
////  Makuli
////
////  Created by Ian   on 26/06/2025.
////
//

import Supabase
import Foundation

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: "https://tcuhvrhorccrhmjiyrub.supabase.co")!,
            supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRjdWh2cmhvcmNjcmhtaml5cnViIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA5NjIxMTgsImV4cCI6MjA2NjUzODExOH0.YDPvgfRWVzNFh-iDuU49bhhz5Y-ALS1u3-TqK3A74gk"
        )
    }
    
    // MARK: - Test Connection
    // func testConnection() async -> Bool {
    //     do {
    //         // Test basic connectivity by making a simple request
    //         // This doesn't require authentication
    //         let _ = try await client
    //             .from("profiles")
    //             .select("id")
    //             .limit(1)
    //             .execute()
            
    //         print("✅ Supabase connection successful - database is accessible")
    //         return true
    //     } catch {
    //         print("❌ Supabase connection failed: \(error)")
    //         return false
    //     }
    // }
}
