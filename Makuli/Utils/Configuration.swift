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
            return "https://tcuhvrhorccrhmjiyrub.supabase.co" // Your production URL
        case .development:
            return "https://tcuhvrhorccrhmjiyrub.supabase.co" // Same for now, can be different
        }
    }
    
    static var supabaseAnonKey: String {
        switch environment {
        case .production:
            // In production, this should ideally come from secure storage
            return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRjdWh2cmhvcmNjcmhtaml5cnViIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA5NjIxMTgsImV4cCI6MjA2NjUzODExOH0.YDPvgfRWVzNFh-iDuU49bhhz5Y-ALS1u3-TqK3A74gk"
        case .development:
            return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRjdWh2cmhvcmNjcmhtaml5cnViIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA5NjIxMTgsImV4cCI6MjA2NjUzODExOH0.YDPvgfRWVzNFh-iDuU49bhhz5Y-ALS1u3-TqK3A74gk"
        }
    }
    
    // MARK: - API Configuration
    static var openAIAPIKey: String {
        if isProduction {
            // In production, retrieve from Keychain or environment
            return KeychainManager.shared.getAPIKey("openai_production") ?? ""
        } else {
            // For development - set your development key here
            return ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
        }
    }
    
    // MARK: - Feature Flags
    static var enableAI: Bool {
        return !openAIAPIKey.isEmpty
    }
    
    static var useMockAIResponses: Bool {
        return !enableAI && !isProduction
    }
    
    static var enableAnalytics: Bool { isProduction }
    static var enableCrashReporting: Bool { isProduction }
    static var enablePerformanceMonitoring: Bool { true }
    static var enableDeepLinking: Bool { isProduction }
    
    // MARK: - App Configuration
    static var maxRecipesPerPage: Int { 20 }
    static var maxPlansPerUser: Int { isProduction ? 50 : 10 }
    static var cacheExpiration: TimeInterval { 
        isProduction ? 3600 : 300 // 1 hour prod, 5 min dev
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
        let maxAIGenerationsPerMonth = 3
        let maxRecipesPerPlan = 21
    }
    
    // MARK: - Mock Data for Development
    static var mockAIResponse: MealPlanGenerationResponse {
        return MealPlanGenerationResponse(
            weekTitle: "Development Week",
            totalEstimatedCost: 75.0,
            meals: [
                DayMealPlan(
                    day: "Monday",
                    dayOfWeek: 0,
                    breakfast: GeneratedMeal(
                        name: "Avocado Toast",
                        cookingTime: 10,
                        difficulty: "easy",
                        ingredients: ["bread", "avocado", "salt"],
                        instructions: ["Toast bread", "Mash avocado", "Spread on toast"],
                        estimatedCost: 8.0
                    ),
                    lunch: GeneratedMeal(
                        name: "Caesar Salad",
                        cookingTime: 15,
                        difficulty: "easy",
                        ingredients: ["lettuce", "croutons", "dressing"],
                        instructions: ["Mix ingredients", "Add dressing"],
                        estimatedCost: 12.0
                    ),
                    dinner: GeneratedMeal(
                        name: "Grilled Chicken",
                        cookingTime: 25,
                        difficulty: "medium",
                        ingredients: ["chicken", "herbs", "oil"],
                        instructions: ["Season chicken", "Grill until done"],
                        estimatedCost: 15.0
                    )
                )
            ]
        )
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
        
        // Delete existing item
        SecItemDelete(query as CFDictionary)
        
        // Add new item
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
        
        // In production, send to crash reporting service
        if Configuration.enableCrashReporting {
            // Example: Crashlytics.crashlytics().record(error: error)
            // Example: Sentry.capture(error: error)
        }
        
        // Always log locally for debugging
        print("🚨 [\(Configuration.environment.description)] ERROR: \(errorData)")
    }
    
    static func logEvent(_ event: String, parameters: [String: Any] = [:]) {
        if Configuration.enableAnalytics {
            // Example: Analytics.logEvent(event, parameters: parameters)
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