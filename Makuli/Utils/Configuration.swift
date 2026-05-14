//
//  Configuration.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//
//  Production-ready configuration with environment-based settings.
//

import Foundation

struct Configuration {
    
    // MARK: - Environment Detection
    static var isProduction: Bool {
        #if DEBUG
        return false
        #else
        return true
        #endif
    }
    
    static var environment: AppEnvironment {
        return isProduction ? .production : .development
    }
    
    // MARK: - Supabase Configuration
    static var supabaseURL: String {
        switch environment {
        case .production:
            return "https://mbotzyrpzblbmesnfqix.supabase.co"
        case .development:
            return "https://mbotzyrpzblbmesnfqix.supabase.co"
        }
    }
    
    static var supabaseAnonKey: String {
        switch environment {
        case .production:
            return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1ib3R6eXJwemJsYm1lc25mcWl4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg1OTA4ODksImV4cCI6MjA5NDE2Njg4OX0.-87OvopCtecr9VXO4RIVO3h2-aRBo9JusxdaFvLwi2w"
        case .development:
            return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1ib3R6eXJwemJsYm1lc25mcWl4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg1OTA4ODksImV4cCI6MjA5NDE2Njg4OX0.-87OvopCtecr9VXO4RIVO3h2-aRBo9JusxdaFvLwi2w"
        }
    }
    

    
    // MARK: - Feature Flags
    static var enableAnalytics: Bool { isProduction }
    static var enableCrashReporting: Bool { isProduction }
    static var enablePerformanceMonitoring: Bool { true }
    static var enableDeepLinking: Bool { isProduction }
    
    // MARK: - App Configuration
    static var maxRecipesPerPage: Int { 20 }
    static var maxPlansPerUser: Int { isProduction ? 50 : 10 }
    static var cacheExpiration: TimeInterval { 
        isProduction ? 3600 : 300
    }
    
    // MARK: - Database Configuration
    static var enableOfflineMode: Bool { isProduction }
    static var maxRetryAttempts: Int { 3 }
    static var requestTimeout: TimeInterval { 30.0 }
    
    // MARK: - Subscription Configuration
    static var premiumMonthlyPrice: String { "$4.99" }
    static var premiumYearlyPrice: String { "$49.99" }
    static var freePlanLimits = FreePlanLimits()
    
    struct FreePlanLimits {
        let maxPlansPerMonth = 5
        let maxRecipesPerPlan = 21
    }
    
    // MARK: - App Store Configuration
    static var appStoreID: String { "YOUR_APP_STORE_ID" }
    static var supportEmail: String { "support@makuli.app" }
    static var privacyPolicyURL: String { "https://makuli.app/privacy" }
    static var termsOfServiceURL: String { "https://makuli.app/terms" }
}

// MARK: - App Environment Enum
enum AppEnvironment {
    case development
    case production
    
    var description: String {
        switch self {
        case .development: return "Development"
        case .production: return "Production"
        }
    }
}

// MARK: - Keychain Manager for Secure Storage
class KeychainManager {
    static let shared = KeychainManager()
    private init() {}
    
    func storeAPIKey(_ key: String, service: String) -> Bool {
        let data = key.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "makuli_app",
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
    }
    
    func getAPIKey(_ service: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "makuli_app",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return key
    }
    
    func deleteAPIKey(_ service: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: "makuli_app"
        ]
        
        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }
}

// MARK: - Production Logger
class ProductionLogger {
    static func logError(_ error: Error, context: String) {
        let errorData: [String: Any] = [
            "error": error.localizedDescription,
            "context": context,
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "app_version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            "environment": Configuration.environment.description
        ]
        
        if Configuration.enableCrashReporting {
        }
        
        print("🚨 [\(Configuration.environment.description)] ERROR: \(errorData)")
    }
    
    static func logEvent(_ event: String, parameters: [String: Any] = [:]) {
        if Configuration.enableAnalytics {
        }
        
        print("📊 [\(Configuration.environment.description)] EVENT: \(event) - \(parameters)")
    }
    
    static func logInfo(_ message: String, context: String = "") {
        let logData = [
            "message": message,
            "context": context,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        print("ℹ️ [\(Configuration.environment.description)] INFO: \(logData)")
    }
} 