//
//  AIService.swift
//  Buildplate
//
//  Created by ian on 2025-01-03.
//
//  Service for AI-powered meal plan generation using OpenAI API.
//

import Foundation

@MainActor
class AIService: ObservableObject {
    static let shared = AIService()
    
    // MARK: - GPTGod API Configuration (switched from OpenAI)
    // Hardcoded for now; move to secure storage for production!
    private let gptGodAPIKey = "sk-OsMMq65tXdfOIlTUYtocSL7NCsmA7CerN77OkEv29dODg1EA"
    private let baseURL = "https://api.gptgod.online"
    
    private init() {}
    
    /// Generates a meal plan using AI based on user preferences
    func generateMealPlan(request: MealPlanGenerationRequest) async throws -> MealPlanGenerationResponse {
        // Use mock response for testing when API key is not configured
        if Configuration.useMockAIResponses {
            Logger.info("Using mock AI response for testing")
            // Simulate API delay
            try await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
            return Configuration.mockAIResponse
        }
        let prompt = buildPrompt(from: request)
        
        let openAIRequest = OpenAIRequest(
            model: "gpt-4",
            messages: [
                OpenAIMessage(
                    role: "system",
                    content: """
                    You are a professional nutritionist and meal planner specializing in Western cuisine. 
                    Generate healthy, culturally appropriate meal plans based on user preferences, focusing on popular dishes from the US, UK, and European cuisines.
                    Return only valid JSON in the exact format specified.
                    """
                ),
                OpenAIMessage(role: "user", content: prompt)
            ],
            temperature: 0.7,
            maxTokens: 2000
        )
        
        guard let url = URL(string: baseURL) else {
            throw AIServiceError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // Switched to GPTGod API key (was OpenAI)
        request.addValue("Bearer \(gptGodAPIKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestData = try JSONEncoder().encode(openAIRequest)
        request.httpBody = requestData
        
        Logger.info("Sending meal plan generation request to GPTGod API")
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            Logger.error("Invalid response received from GPTGod API")
            throw AIServiceError.invalidResponse
        }
        
        Logger.info("Received response from GPTGod API with status code: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
            Logger.error("GPTGod API returned error status code: \(httpResponse.statusCode)")
            throw AIServiceError.apiError(httpResponse.statusCode)
        }
        
        do {
            let openAIResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            guard let choice = openAIResponse.choices.first else {
                Logger.error("No content in GPTGod API response")
                throw AIServiceError.noContent
            }
            let content = choice.message.content
            guard let contentData = content.data(using: .utf8) else {
                Logger.error("Invalid JSON string in GPTGod API response")
                throw AIServiceError.invalidJSONResponse
            }
            let mealPlan = try JSONDecoder().decode(MealPlanGenerationResponse.self, from: contentData)
            Logger.info("Successfully parsed meal plan from GPTGod API response")
            return mealPlan
        } catch {
            Logger.error("Failed to decode GPTGod API response: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func buildPrompt(from request: MealPlanGenerationRequest) -> String {
        return """
        Generate a 7-day meal plan for a Western user with the following preferences:
        
        - Age: \(request.age)
        - Gender: \(request.gender)
        - Diet: \(request.dietaryPreferences)
        - Budget: \(request.budget)
        - Goal: \(request.goal)
        - Week starting: \(request.weekStart)
        
        Requirements:
        1. Focus on popular Western dishes from US, UK, and European cuisines
        2. Include breakfast, lunch, and dinner for each day
        3. Respect dietary restrictions: \(request.dietaryPreferences)
        4. Stay within budget range: \(request.budget)
        5. Align with health goal: \(request.goal)
        6. Use common ingredients available in Western supermarkets
        7. Include varied cuisines: Italian, Mediterranean, American, British, etc.
        
        Return the response as JSON in this exact format:
        {
          "weekTitle": "Week of [date]",
          "totalEstimatedCost": 75,
          "meals": [
            {
              "day": "Monday",
              "dayOfWeek": 0,
              "breakfast": {
                "name": "Avocado Toast with Eggs",
                "cookingTime": 10,
                "difficulty": "easy",
                "ingredients": ["sourdough bread", "avocado", "eggs", "cherry tomatoes"],
                "instructions": ["Step 1", "Step 2", "Step 3"],
                "estimatedCost": 8
              },
              "lunch": {
                "name": "Grilled Chicken Caesar Salad",
                "cookingTime": 20,
                "difficulty": "medium",
                "ingredients": ["chicken breast", "romaine lettuce", "parmesan", "caesar dressing"],
                "instructions": ["Step 1", "Step 2", "Step 3"],
                "estimatedCost": 12
              },
              "dinner": {
                "name": "Salmon with Roasted Vegetables",
                "cookingTime": 25,
                "difficulty": "medium",
                "ingredients": ["salmon fillet", "asparagus", "bell peppers", "olive oil"],
                "instructions": ["Step 1", "Step 2", "Step 3"],
                "estimatedCost": 18
              }
            }
          ]
        }
        
        Include all 7 days (Monday through Sunday) with dayOfWeek values 0-6.
        Use appropriate Western currency amounts in USD.
        """
    }
}

// MARK: - Error Types
enum AIServiceError: LocalizedError {
    case invalidURL
    case invalidResponse
    case apiError(Int)
    case noContent
    case invalidJSONResponse
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let code):
            return "API error with code: \(code)"
        case .noContent:
            return "No content received from AI service"
        case .invalidJSONResponse:
            return "Invalid JSON response format"
        }
    }
}

// MARK: - OpenAI API Models
private struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let temperature: Double
    let maxTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
}

private struct OpenAIMessage: Codable {
    let role: String
    let content: String
}

private struct OpenAIResponse: Codable {
    let choices: [OpenAIChoice]
}

private struct OpenAIChoice: Codable {
    let message: OpenAIMessage
}

 
