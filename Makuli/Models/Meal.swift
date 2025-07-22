import Foundation

enum MealCategory: String, Codable {
    case breakfast, lunch, dinner, snack, other
}

enum DifficultyLevel: String, Codable {
    case easy, medium, hard
}

struct Meal: Identifiable, Codable {
    let id: UUID
    let name: String
    let category: MealCategory
    let cookingTime: Int // in minutes
    let prepTime: Int? // optional, for flexibility
    let cookTime: Int? // optional, for flexibility
    let difficulty: DifficultyLevel
    let imageURL: String?
    let description: String?
    var isCompleted: Bool
    let scheduledDate: Date?
    let recipe: Recipe?
    let recipeId: String? // optional, for flexibility
}
