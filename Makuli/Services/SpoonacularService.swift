//
//  SpoonacularService.swift
//  Makuli
//
//  Created by ian on 2025-08-05.
//
//  Clean, well-architected service for Spoonacular API integration.
//  This service handles all Spoonacular API calls with proper error handling,
//  rate limiting, and dependency injection for testability.
//

import Foundation

// MARK: - Service Protocol

/// Protocol defining the interface for Spoonacular API operations.
/// This allows for easy testing and dependency injection.
protocol SpoonacularServiceProtocol {
    func generateWeeklyMealPlan(preferences: UserProfile) async throws -> SpoonacularMealPlan
    func fetchRecipeDetails(recipeId: Int) async throws -> SpoonacularRecipe
    func generateShoppingList(mealPlan: SpoonacularMealPlan, username: String, hash: String) async throws -> SpoonacularShoppingList
    func connectUser() async throws -> SpoonacularUserConnection
}

// MARK: - Error Types

/// Custom error types for Spoonacular API operations.
enum SpoonacularError: LocalizedError {
    case invalidURL
    case networkError(Error)
    case invalidResponse
    case apiError(String, Int)
    case rateLimitExceeded
    case decodingError(Error)
    case missingApiKey
    case invalidUserCredentials
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL for Spoonacular API request"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from Spoonacular API"
        case .apiError(let message, let code):
            return "Spoonacular API error (\(code)): \(message)"
        case .rateLimitExceeded:
            return "Rate limit exceeded. Please try again later."
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .missingApiKey:
            return "Spoonacular API key is missing"
        case .invalidUserCredentials:
            return "Invalid user credentials for Spoonacular"
        }
    }
}

// MARK: - Main Service Implementation

/// Main service implementation for Spoonacular API operations.
/// This service handles all API calls with proper error handling and rate limiting.
class SpoonacularService: SpoonacularServiceProtocol {
    
    // MARK: - Dependencies
    
    private let session: URLSession
    private let apiKey: String
    private let baseURL: String
    private let endpoints: Configuration.SpoonacularEndpoints
    
    // MARK: - Rate Limiting
    
    private var lastRequestTime: Date = .distantPast
    private let minimumRequestInterval: TimeInterval = 0.1 // 100ms between requests
    
    // MARK: - Initialization
    
    /// Creates a new SpoonacularService instance.
    /// - Parameters:
    ///   - session: URLSession for network requests (defaults to .shared)
    ///   - apiKey: Spoonacular API key (defaults to Configuration value)
    ///   - baseURL: Base URL for API (defaults to Configuration value)
    ///   - endpoints: API endpoints (defaults to Configuration value)
    init(
        session: URLSession = .shared,
        apiKey: String = Configuration.spoonacularApiKey,
        baseURL: String = Configuration.spoonacularBaseURL,
        endpoints: Configuration.SpoonacularEndpoints = Configuration.spoonacularEndpoints
    ) {
        self.session = session
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.endpoints = endpoints
    }
    
    // MARK: - Public Methods
    
    /// Generates a weekly meal plan based on user preferences.
    /// - Parameter preferences: User profile containing dietary preferences and goals
    /// - Returns: SpoonacularMealPlan containing the generated meal plan
    /// - Throws: SpoonacularError for various failure scenarios
    func generateWeeklyMealPlan(preferences: UserProfile) async throws -> SpoonacularMealPlan {
        Logger.info("Generating weekly meal plan for user: \(preferences.id)")
        
        // Validate API key
        guard !apiKey.isEmpty else {
            throw SpoonacularError.missingApiKey
        }
        
        // Create request parameters
        let request = SpoonacularMealPlanRequest(
            targetCalories: preferences.spoonacularTargetCalories,
            diet: preferences.spoonacularDiet,
            exclude: preferences.spoonacularExclusions,
            apiKey: apiKey
        )
        
        // Build URL
        guard let url = buildURL(
            endpoint: endpoints.mealPlannerGenerate,
            parameters: request.queryParameters
        ) else {
            throw SpoonacularError.invalidURL
        }
        
        // Make request
        let data = try await makeRequest(url: url)
        
        // Decode response
        do {
            let mealPlan = try JSONDecoder().decode(SpoonacularMealPlan.self, from: data)
            Logger.info("Successfully generated meal plan with \(mealPlan.week.allDays.count) days")
            return mealPlan
        } catch {
            Logger.error("Failed to decode meal plan response: \(error)")
            throw SpoonacularError.decodingError(error)
        }
    }
    
    /// Fetches detailed recipe information by recipe ID.
    /// - Parameter recipeId: Spoonacular recipe ID
    /// - Returns: SpoonacularRecipe containing detailed recipe information
    /// - Throws: SpoonacularError for various failure scenarios
    func fetchRecipeDetails(recipeId: Int) async throws -> SpoonacularRecipe {
        Logger.info("Fetching recipe details for recipe ID: \(recipeId)")
        
        // Validate API key
        guard !apiKey.isEmpty else {
            throw SpoonacularError.missingApiKey
        }
        
        // Create request parameters
        let request = SpoonacularRecipeRequest(
            recipeId: recipeId,
            includeNutrition: true,
            apiKey: apiKey
        )
        
        // Build URL
        let endpoint = endpoints.recipeInformation.replacingOccurrences(of: "{id}", with: String(recipeId))
        guard let url = buildURL(
            endpoint: endpoint,
            parameters: request.queryParameters
        ) else {
            throw SpoonacularError.invalidURL
        }
        
        // Make request
        let data = try await makeRequest(url: url)
        
        // Decode response
        do {
            let recipe = try JSONDecoder().decode(SpoonacularRecipe.self, from: data)
            Logger.info("Successfully fetched recipe: \(recipe.title)")
            return recipe
        } catch {
            Logger.error("Failed to decode recipe response: \(error)")
            throw SpoonacularError.decodingError(error)
        }
    }
    
    /// Generates a shopping list for a meal plan.
    /// - Parameters:
    ///   - mealPlan: The meal plan to generate shopping list for
    ///   - username: Spoonacular username
    ///   - hash: Spoonacular user hash
    /// - Returns: SpoonacularShoppingList containing the shopping list
    /// - Throws: SpoonacularError for various failure scenarios
    func generateShoppingList(
        mealPlan: SpoonacularMealPlan,
        username: String,
        hash: String
    ) async throws -> SpoonacularShoppingList {
        Logger.info("Generating shopping list for user: \(username)")
        
        // Validate API key and credentials
        guard !apiKey.isEmpty else {
            throw SpoonacularError.missingApiKey
        }
        
        guard !username.isEmpty && !hash.isEmpty else {
            throw SpoonacularError.invalidUserCredentials
        }
        
        // Create request parameters
        let request = SpoonacularShoppingListRequest(
            username: username,
            hash: hash,
            startDate: formatDateForAPI(Date()),
            endDate: formatDateForAPI(Calendar.current.date(byAdding: .day, value: 6, to: Date()) ?? Date()),
            apiKey: apiKey
        )
        
        // Build URL
        let endpoint = endpoints.shoppingList
            .replacingOccurrences(of: "{username}", with: username)
        guard let url = buildURL(
            endpoint: endpoint,
            parameters: request.queryParameters
        ) else {
            throw SpoonacularError.invalidURL
        }
        
        // Make request
        let data = try await makeRequest(url: url)
        
        // Decode response
        do {
            let shoppingList = try JSONDecoder().decode(SpoonacularShoppingList.self, from: data)
            Logger.info("Successfully generated shopping list with \(shoppingList.aisles.count) aisles")
            return shoppingList
        } catch {
            Logger.error("Failed to decode shopping list response: \(error)")
            throw SpoonacularError.decodingError(error)
        }
    }
    
    /// Connects a user to Spoonacular and returns credentials.
    /// - Returns: SpoonacularUserConnection containing username and hash
    /// - Throws: SpoonacularError for various failure scenarios
    func connectUser() async throws -> SpoonacularUserConnection {
        Logger.info("Connecting user to Spoonacular")
        
        // Validate API key
        guard !apiKey.isEmpty else {
            throw SpoonacularError.missingApiKey
        }
        
        // Build URL
        guard let url = buildURL(
            endpoint: endpoints.connectUser,
            parameters: ["apiKey": apiKey]
        ) else {
            throw SpoonacularError.invalidURL
        }
        
        // Make request
        let data = try await makeRequest(url: url)
        
        // Decode response
        do {
            let connection = try JSONDecoder().decode(SpoonacularUserConnection.self, from: data)
            Logger.info("Successfully connected user: \(connection.username)")
            return connection
        } catch {
            Logger.error("Failed to decode user connection response: \(error)")
            throw SpoonacularError.decodingError(error)
        }
    }
    
    // MARK: - Private Helper Methods
    
    /// Makes a network request with rate limiting and error handling.
    /// - Parameter url: URL to request
    /// - Returns: Response data
    /// - Throws: SpoonacularError for various failure scenarios
    private func makeRequest(url: URL) async throws -> Data {
        // Rate limiting
        await enforceRateLimit()
        
        // Create request
        var request = URLRequest(url: url)
        request.timeoutInterval = Configuration.requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        Logger.debug("Making request to: \(url.absoluteString)")
        
        do {
            let (data, response) = try await session.data(for: request)
            
            // Update last request time
            lastRequestTime = Date()
            
            // Handle response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw SpoonacularError.invalidResponse
            }
            
            // Check for errors
            switch httpResponse.statusCode {
            case 200...299:
                return data
            case 429:
                throw SpoonacularError.rateLimitExceeded
            case 401:
                throw SpoonacularError.apiError("Unauthorized - check API key", 401)
            case 403:
                throw SpoonacularError.apiError("Forbidden - check API key permissions", 403)
            case 404:
                throw SpoonacularError.apiError("Resource not found", 404)
            case 500...599:
                throw SpoonacularError.apiError("Server error", httpResponse.statusCode)
            default:
                // Try to decode error response
                if let errorResponse = try? JSONDecoder().decode(SpoonacularErrorResponse.self, from: data) {
                    throw SpoonacularError.apiError(errorResponse.message, httpResponse.statusCode)
                } else {
                    throw SpoonacularError.apiError("Unknown error", httpResponse.statusCode)
                }
            }
        } catch let error as SpoonacularError {
            throw error
        } catch {
            Logger.error("Network request failed: \(error)")
            throw SpoonacularError.networkError(error)
        }
    }
    
    /// Builds a URL with query parameters.
    /// - Parameters:
    ///   - endpoint: API endpoint path
    ///   - parameters: Query parameters
    /// - Returns: Constructed URL or nil if invalid
    private func buildURL(endpoint: String, parameters: [String: String]) -> URL? {
        var components = URLComponents(string: baseURL + endpoint)
        components?.queryItems = parameters.map { key, value in
            URLQueryItem(name: key, value: value)
        }
        return components?.url
    }
    
    /// Enforces rate limiting by waiting if necessary.
    private func enforceRateLimit() async {
        let timeSinceLastRequest = Date().timeIntervalSince(lastRequestTime)
        if timeSinceLastRequest < minimumRequestInterval {
            let waitTime = minimumRequestInterval - timeSinceLastRequest
            try? await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
        }
    }
    

    
    /// Formats a date for Spoonacular API (YYYY-MM-DD format).
    /// - Parameter date: Date to format
    /// - Returns: Formatted date string
    private func formatDateForAPI(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

// MARK: - Mock Service for Testing

/// Mock implementation of SpoonacularService for testing purposes.
@MainActor
class MockSpoonacularService: SpoonacularServiceProtocol {
    
    var shouldThrowError = false
    var mockError: SpoonacularError = .networkError(NSError(domain: "Mock", code: 0))
    
    var mockMealPlan: SpoonacularMealPlan?
    var mockRecipe: SpoonacularRecipe?
    var mockShoppingList: SpoonacularShoppingList?
    var mockUserConnection: SpoonacularUserConnection?
    
    func generateWeeklyMealPlan(preferences: UserProfile) async throws -> SpoonacularMealPlan {
        if shouldThrowError {
            throw mockError
        }
        
        guard let mealPlan = mockMealPlan else {
            throw SpoonacularError.invalidResponse
        }
        
        return mealPlan
    }
    
    func fetchRecipeDetails(recipeId: Int) async throws -> SpoonacularRecipe {
        if shouldThrowError {
            throw mockError
        }
        
        guard let recipe = mockRecipe else {
            throw SpoonacularError.invalidResponse
        }
        
        return recipe
    }
    
    func generateShoppingList(
        mealPlan: SpoonacularMealPlan,
        username: String,
        hash: String
    ) async throws -> SpoonacularShoppingList {
        if shouldThrowError {
            throw mockError
        }
        
        guard let shoppingList = mockShoppingList else {
            throw SpoonacularError.invalidResponse
        }
        
        return shoppingList
    }
    
    func connectUser() async throws -> SpoonacularUserConnection {
        if shouldThrowError {
            throw mockError
        }
        
        guard let connection = mockUserConnection else {
            throw SpoonacularError.invalidResponse
        }
        
        return connection
    }
} 