//
//  DatabaseSeeder.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//

import Foundation

@MainActor
class DatabaseSeeder: ObservableObject {
    static let shared = DatabaseSeeder()
    
    @Published var isSeeding = false
    @Published var seedingProgress = ""
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private init() {}
    
    func seedDatabase() async -> Bool {
        isSeeding = true
        errorMessage = nil
        successMessage = nil
        
        do {
            seedingProgress = "Starting production database seeding..."
            ProductionLogger.logInfo("Starting production database seeding", context: "DatabaseSeeder")
            
            try await ProductionSeeder.seedProductionDatabase()
            
            successMessage = "Successfully seeded production database with 14 meal plan templates and 294+ meals!"
            seedingProgress = "Production database seeding completed ✅"
            ProductionLogger.logInfo("Production database seeding completed successfully", context: "DatabaseSeeder")
            
            isSeeding = false
            return true
            
        } catch {
            errorMessage = "Failed to seed database: \(error.localizedDescription)"
            seedingProgress = "Database seeding failed ❌"
            ProductionLogger.logError(error, context: "DatabaseSeeder.seedDatabase")
            
            isSeeding = false
            return false
        }
    }
    
    func resetAndSeedDatabase() async -> Bool {
        isSeeding = true
        errorMessage = nil
        successMessage = nil
        
        do {
            seedingProgress = "Resetting and seeding database..."
            ProductionLogger.logInfo("Starting database reset and reseed", context: "DatabaseSeeder")
            
            if Configuration.isProduction {
                seedingProgress = "⚠️ Resetting production database - this may take a few minutes..."
            }
            
            try await ProductionSeeder.seedProductionDatabase()
            
            successMessage = "Database reset and seeded successfully!"
            seedingProgress = "Database reset completed ✅"
            ProductionLogger.logInfo("Database reset and reseed completed", context: "DatabaseSeeder")
            
            isSeeding = false
            return true
            
        } catch {
            errorMessage = "Failed to reset database: \(error.localizedDescription)"
            seedingProgress = "Database reset failed ❌"
            ProductionLogger.logError(error, context: "DatabaseSeeder.resetAndSeedDatabase")
            
            isSeeding = false
            return false
        }
    }
    
    func checkTemplateCount() async -> Int {
        do {
            let templates = try await SupabaseManager.shared.fetchMealPlanTemplates()
            ProductionLogger.logInfo("Found \(templates.count) templates in database", context: "DatabaseSeeder")
            return templates.count
        } catch {
            ProductionLogger.logError(error, context: "DatabaseSeeder.checkTemplateCount")
            return 0
        }
    }
    
    func testDatabaseConnection() async -> Bool {
        await SupabaseManager.shared.checkConnection()
        return SupabaseManager.shared.isConnected
    }
    
    func getSeedingStatus() async -> SeedingStatus {
        let templateCount = await checkTemplateCount()
        let isConnected = await testDatabaseConnection()
        
        do {
            let recipes = try await SupabaseManager.shared.fetchRecipes(limit: 1)
            let hasRecipes = !recipes.isEmpty
            
            return SeedingStatus(
                templateCount: templateCount,
                isConnected: isConnected,
                hasRecipes: hasRecipes,
                environment: Configuration.environment.description
            )
        } catch {
            return SeedingStatus(
                templateCount: templateCount,
                isConnected: isConnected,
                hasRecipes: false,
                environment: Configuration.environment.description
            )
        }
    }
}

// MARK: - Development Helper Functions

extension DatabaseSeeder {
    static func quickSeed() async {
        ProductionLogger.logInfo("🌱 Starting quick database seed...", context: "DatabaseSeeder")
        let seeder = DatabaseSeeder.shared
        let success = await seeder.seedDatabase()
        
        if success {
            ProductionLogger.logInfo("🎉 Quick seed completed successfully!", context: "DatabaseSeeder")
        } else {
            ProductionLogger.logError(
                NSError(domain: "QuickSeed", code: -1, userInfo: [NSLocalizedDescriptionKey: seeder.errorMessage ?? "Unknown error"]),
                context: "DatabaseSeeder.quickSeed"
            )
        }
    }
    
    static func verifyProductionReadiness() async -> ProductionReadiness {
        let seeder = DatabaseSeeder.shared
        let status = await seeder.getSeedingStatus()
        
        let checks = ProductionReadiness(
            databaseConnected: status.isConnected,
            templatesSeeded: status.templateCount >= 10,
            recipesSeeded: status.hasRecipes,
            configurationValid: !Configuration.supabaseURL.isEmpty && !Configuration.supabaseAnonKey.isEmpty,
            environment: status.environment
        )
        
        ProductionLogger.logInfo("Production readiness check: \(checks.isReady ? "READY" : "NOT READY")", context: "DatabaseSeeder")
        
        return checks
    }
}

// MARK: - Supporting Types

struct SeedingStatus {
    let templateCount: Int
    let isConnected: Bool
    let hasRecipes: Bool
    let environment: String
    
    var isSeeded: Bool {
        return templateCount > 0 && hasRecipes
    }
}

struct ProductionReadiness {
    let databaseConnected: Bool
    let templatesSeeded: Bool
    let recipesSeeded: Bool
    let configurationValid: Bool
    let environment: String
    
    var isReady: Bool {
        return databaseConnected && templatesSeeded && recipesSeeded && configurationValid
    }
    
    var issues: [String] {
        var issues: [String] = []
        
        if !databaseConnected { issues.append("Database connection failed") }
        if !templatesSeeded { issues.append("Meal plan templates not seeded") }
        if !recipesSeeded { issues.append("Recipes not seeded") }
        if !configurationValid { issues.append("Invalid Supabase configuration") }
        
        return issues
    }
} 