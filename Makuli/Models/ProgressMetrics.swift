//
//  ProgressMetrics.swift
//  Makuli
//
//  Created by Ian   on 19/06/2025.
//

import Foundation

/**
 * ProgressMetrics Model
 * 
 * Represents user progress and metrics over time for tracking health and fitness goals.
 * This model captures various metrics that help users monitor their progress towards
 * their meal planning and fitness objectives.
 * 
 * Key Features:
 * - Weight tracking and BMI calculations
 * - Calorie intake and macronutrient tracking
 * - Meal plan adherence and completion rates
 * - Exercise and activity tracking
 * - Goal progress and achievement tracking
 * 
 * Database Relationships:
 * - Belongs to a User (via user_id)
 * - Can be linked to specific Plans (via plan_id)
 * - Tracks progress over time with date-based entries
 */
struct ProgressMetrics: Identifiable, Codable {
    /// Unique identifier for the progress metrics entry
    let id: String
    
    /// Reference to the user these metrics belong to
    let userId: String
    
    /// Reference to the plan these metrics are associated with (optional)
    let planId: String?
    
    /// Date when these metrics were recorded
    let date: Date
    
    /// User's weight in kilograms on this date
    let weight: Double?
    
    /// User's body fat percentage (optional)
    let bodyFatPercentage: Double?
    
    /// User's muscle mass in kilograms (optional)
    let muscleMass: Double?
    
    /// Total calories consumed on this date
    let caloriesConsumed: Int?
    
    /// Target calories for this date
    let targetCalories: Int?
    
    /// Protein consumed in grams
    let proteinConsumed: Double?
    
    /// Carbohydrates consumed in grams
    let carbohydratesConsumed: Double?
    
    /// Fat consumed in grams
    let fatConsumed: Double?
    
    /// Fiber consumed in grams
    let fiberConsumed: Double?
    
    /// Sugar consumed in grams
    let sugarConsumed: Double?
    
    /// Sodium consumed in milligrams
    let sodiumConsumed: Int?
    
    /// Number of meals completed on this date
    let mealsCompleted: Int
    
    /// Total number of meals planned for this date
    let mealsPlanned: Int
    
    /// Whether the user followed their meal plan today
    let followedMealPlan: Bool
    
    /// Number of glasses of water consumed
    let waterIntake: Int?
    
    /// Minutes of exercise completed
    let exerciseMinutes: Int?
    
    /// Type of exercise performed
    let exerciseType: String?
    
    /// Steps taken on this date
    let stepsTaken: Int?
    
    /// Target steps for this date
    let targetSteps: Int?
    
    /// Sleep hours the previous night
    let sleepHours: Double?
    
    /// Quality of sleep (1-10 scale)
    let sleepQuality: Int?
    
    /// Stress level (1-10 scale)
    let stressLevel: Int?
    
    /// Energy level (1-10 scale)
    let energyLevel: Int?
    
    /// Mood rating (1-10 scale)
    let moodRating: Int?
    
    /// Notes or comments about this day
    let notes: String?
    
    /// Timestamp when the metrics were created
    let createdAt: Date
    
    /// Timestamp when the metrics were last updated
    let updatedAt: Date
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case planId = "plan_id"
        case date
        case weight
        case bodyFatPercentage = "body_fat_percentage"
        case muscleMass = "muscle_mass"
        case caloriesConsumed = "calories_consumed"
        case targetCalories = "target_calories"
        case proteinConsumed = "protein_consumed"
        case carbohydratesConsumed = "carbohydrates_consumed"
        case fatConsumed = "fat_consumed"
        case fiberConsumed = "fiber_consumed"
        case sugarConsumed = "sugar_consumed"
        case sodiumConsumed = "sodium_consumed"
        case mealsCompleted = "meals_completed"
        case mealsPlanned = "meals_planned"
        case followedMealPlan = "followed_meal_plan"
        case waterIntake = "water_intake"
        case exerciseMinutes = "exercise_minutes"
        case exerciseType = "exercise_type"
        case stepsTaken = "steps_taken"
        case targetSteps = "target_steps"
        case sleepHours = "sleep_hours"
        case sleepQuality = "sleep_quality"
        case stressLevel = "stress_level"
        case energyLevel = "energy_level"
        case moodRating = "mood_rating"
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // MARK: - Custom Decoder
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        planId = try container.decodeIfPresent(String.self, forKey: .planId)
        weight = try container.decodeIfPresent(Double.self, forKey: .weight)
        bodyFatPercentage = try container.decodeIfPresent(Double.self, forKey: .bodyFatPercentage)
        muscleMass = try container.decodeIfPresent(Double.self, forKey: .muscleMass)
        caloriesConsumed = try container.decodeIfPresent(Int.self, forKey: .caloriesConsumed)
        targetCalories = try container.decodeIfPresent(Int.self, forKey: .targetCalories)
        proteinConsumed = try container.decodeIfPresent(Double.self, forKey: .proteinConsumed)
        carbohydratesConsumed = try container.decodeIfPresent(Double.self, forKey: .carbohydratesConsumed)
        fatConsumed = try container.decodeIfPresent(Double.self, forKey: .fatConsumed)
        fiberConsumed = try container.decodeIfPresent(Double.self, forKey: .fiberConsumed)
        sugarConsumed = try container.decodeIfPresent(Double.self, forKey: .sugarConsumed)
        sodiumConsumed = try container.decodeIfPresent(Int.self, forKey: .sodiumConsumed)
        mealsCompleted = try container.decode(Int.self, forKey: .mealsCompleted)
        mealsPlanned = try container.decode(Int.self, forKey: .mealsPlanned)
        followedMealPlan = try container.decode(Bool.self, forKey: .followedMealPlan)
        waterIntake = try container.decodeIfPresent(Int.self, forKey: .waterIntake)
        exerciseMinutes = try container.decodeIfPresent(Int.self, forKey: .exerciseMinutes)
        exerciseType = try container.decodeIfPresent(String.self, forKey: .exerciseType)
        stepsTaken = try container.decodeIfPresent(Int.self, forKey: .stepsTaken)
        targetSteps = try container.decodeIfPresent(Int.self, forKey: .targetSteps)
        sleepHours = try container.decodeIfPresent(Double.self, forKey: .sleepHours)
        sleepQuality = try container.decodeIfPresent(Int.self, forKey: .sleepQuality)
        stressLevel = try container.decodeIfPresent(Int.self, forKey: .stressLevel)
        energyLevel = try container.decodeIfPresent(Int.self, forKey: .energyLevel)
        moodRating = try container.decodeIfPresent(Int.self, forKey: .moodRating)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        
        // Handle date decoding with ISO8601 format
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let dateString = try? container.decode(String.self, forKey: .date) {
            date = dateFormatter.date(from: dateString) ?? Date()
        } else {
            date = try container.decode(Date.self, forKey: .date)
        }
        
        if let createdAtString = try? container.decode(String.self, forKey: .createdAt) {
            createdAt = dateFormatter.date(from: createdAtString) ?? Date()
        } else {
            createdAt = Date()
        }
        
        if let updatedAtString = try? container.decode(String.self, forKey: .updatedAt) {
            updatedAt = dateFormatter.date(from: updatedAtString) ?? Date()
        } else {
            updatedAt = Date()
        }
    }
    
    // MARK: - Convenience Initializer
    
    /**
     * Creates a new ProgressMetrics instance
     * 
     * - Parameters:
     *   - id: Unique identifier
     *   - userId: Reference to the user
     *   - planId: Optional reference to the plan
     *   - date: Date when metrics were recorded
     *   - weight: User's weight in kilograms
     *   - bodyFatPercentage: Body fat percentage
     *   - muscleMass: Muscle mass in kilograms
     *   - caloriesConsumed: Total calories consumed
     *   - targetCalories: Target calories for the day
     *   - proteinConsumed: Protein consumed in grams
     *   - carbohydratesConsumed: Carbohydrates consumed in grams
     *   - fatConsumed: Fat consumed in grams
     *   - fiberConsumed: Fiber consumed in grams
     *   - sugarConsumed: Sugar consumed in grams
     *   - sodiumConsumed: Sodium consumed in milligrams
     *   - mealsCompleted: Number of meals completed
     *   - mealsPlanned: Number of meals planned
     *   - followedMealPlan: Whether meal plan was followed
     *   - waterIntake: Glasses of water consumed
     *   - exerciseMinutes: Minutes of exercise
     *   - exerciseType: Type of exercise
     *   - stepsTaken: Steps taken
     *   - targetSteps: Target steps for the day
     *   - sleepHours: Hours of sleep
     *   - sleepQuality: Sleep quality rating
     *   - stressLevel: Stress level rating
     *   - energyLevel: Energy level rating
     *   - moodRating: Mood rating
     *   - notes: Optional notes
     *   - createdAt: Creation timestamp
     *   - updatedAt: Last update timestamp
     */
    init(id: String, userId: String, planId: String?, date: Date, weight: Double?, bodyFatPercentage: Double?, muscleMass: Double?, caloriesConsumed: Int?, targetCalories: Int?, proteinConsumed: Double?, carbohydratesConsumed: Double?, fatConsumed: Double?, fiberConsumed: Double?, sugarConsumed: Double?, sodiumConsumed: Int?, mealsCompleted: Int, mealsPlanned: Int, followedMealPlan: Bool, waterIntake: Int?, exerciseMinutes: Int?, exerciseType: String?, stepsTaken: Int?, targetSteps: Int?, sleepHours: Double?, sleepQuality: Int?, stressLevel: Int?, energyLevel: Int?, moodRating: Int?, notes: String?, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.userId = userId
        self.planId = planId
        self.date = date
        self.weight = weight
        self.bodyFatPercentage = bodyFatPercentage
        self.muscleMass = muscleMass
        self.caloriesConsumed = caloriesConsumed
        self.targetCalories = targetCalories
        self.proteinConsumed = proteinConsumed
        self.carbohydratesConsumed = carbohydratesConsumed
        self.fatConsumed = fatConsumed
        self.fiberConsumed = fiberConsumed
        self.sugarConsumed = sugarConsumed
        self.sodiumConsumed = sodiumConsumed
        self.mealsCompleted = mealsCompleted
        self.mealsPlanned = mealsPlanned
        self.followedMealPlan = followedMealPlan
        self.waterIntake = waterIntake
        self.exerciseMinutes = exerciseMinutes
        self.exerciseType = exerciseType
        self.stepsTaken = stepsTaken
        self.targetSteps = targetSteps
        self.sleepHours = sleepHours
        self.sleepQuality = sleepQuality
        self.stressLevel = stressLevel
        self.energyLevel = energyLevel
        self.moodRating = moodRating
        self.notes = notes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Computed Properties
    
    /**
     * Meal plan adherence percentage
     * 
     * - Returns: Percentage of meals completed vs planned
     */
    var mealPlanAdherence: Double {
        guard mealsPlanned > 0 else { return 0.0 }
        return Double(mealsCompleted) / Double(mealsPlanned) * 100.0
    }
    
    /**
     * Calorie deficit or surplus
     * 
     * - Returns: Difference between consumed and target calories
     */
    var calorieDifference: Int? {
        guard let consumed = caloriesConsumed, let target = targetCalories else { return nil }
        return consumed - target
    }
    
    /**
     * Whether user is in a calorie deficit
     * 
     * - Returns: True if consumed fewer calories than target
     */
    var isInCalorieDeficit: Bool {
        guard let difference = calorieDifference else { return false }
        return difference < 0
    }
    
    /**
     * Whether user is in a calorie surplus
     * 
     * - Returns: True if consumed more calories than target
     */
    var isInCalorieSurplus: Bool {
        guard let difference = calorieDifference else { return false }
        return difference > 0
    }
    
    /**
     * Steps goal achievement percentage
     * 
     * - Returns: Percentage of steps taken vs target
     */
    var stepsGoalAchievement: Double? {
        guard let taken = stepsTaken, let target = targetSteps, target > 0 else { return nil }
        return Double(taken) / Double(target) * 100.0
    }
    
    /**
     * Whether steps goal was achieved
     * 
     * - Returns: True if steps taken >= target steps
     */
    var stepsGoalAchieved: Bool {
        guard let taken = stepsTaken, let target = targetSteps else { return false }
        return taken >= target
    }
    
    /**
     * Total macronutrient calories
     * 
     * - Returns: Sum of calories from protein, carbs, and fat
     */
    var totalMacroCalories: Double {
        let proteinCalories = (proteinConsumed ?? 0) * 4
        let carbCalories = (carbohydratesConsumed ?? 0) * 4
        let fatCalories = (fatConsumed ?? 0) * 9
        return proteinCalories + carbCalories + fatCalories
    }
    
    /**
     * Protein percentage of total calories
     * 
     * - Returns: Percentage of calories from protein
     */
    var proteinPercentage: Double? {
        guard let consumed = caloriesConsumed, consumed > 0 else { return nil }
        let proteinCalories = (proteinConsumed ?? 0) * 4
        return (proteinCalories / Double(consumed)) * 100.0
    }
    
    /**
     * Carbohydrate percentage of total calories
     * 
     * - Returns: Percentage of calories from carbohydrates
     */
    var carbohydratePercentage: Double? {
        guard let consumed = caloriesConsumed, consumed > 0 else { return nil }
        let carbCalories = (carbohydratesConsumed ?? 0) * 4
        return (carbCalories / Double(consumed)) * 100.0
    }
    
    /**
     * Fat percentage of total calories
     * 
     * - Returns: Percentage of calories from fat
     */
    var fatPercentage: Double? {
        guard let consumed = caloriesConsumed, consumed > 0 else { return nil }
        let fatCalories = (fatConsumed ?? 0) * 9
        return (fatCalories / Double(consumed)) * 100.0
    }
    
    /**
     * Whether sleep goal was met (7-9 hours)
     * 
     * - Returns: True if sleep hours are within recommended range
     */
    var sleepGoalMet: Bool {
        guard let hours = sleepHours else { return false }
        return hours >= 7.0 && hours <= 9.0
    }
    
    /**
     * Overall wellness score (1-10)
     * 
     * - Returns: Calculated wellness score based on various metrics
     */
    var wellnessScore: Int {
        var score = 5 // Base score
        
        // Meal plan adherence (0-2 points)
        if mealPlanAdherence >= 80 {
            score += 2
        } else if mealPlanAdherence >= 60 {
            score += 1
        }
        
        // Exercise (0-2 points)
        if let exercise = exerciseMinutes, exercise >= 30 {
            score += 2
        } else if let exercise = exerciseMinutes, exercise >= 15 {
            score += 1
        }
        
        // Steps (0-1 point)
        if stepsGoalAchieved {
            score += 1
        }
        
        // Sleep (0-1 point)
        if sleepGoalMet {
            score += 1
        }
        
        // Water intake (0-1 point)
        if let water = waterIntake, water >= 8 {
            score += 1
        }
        
        // Energy and mood (0-2 points)
        if let energy = energyLevel, energy >= 7 {
            score += 1
        }
        if let mood = moodRating, mood >= 7 {
            score += 1
        }
        
        return min(score, 10)
    }
    
    /**
     * Formatted date string
     * 
     * - Returns: Date formatted as "MMM dd, yyyy"
     */
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    /**
     * Day of week
     * 
     * - Returns: Day of week as string
     */
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    // MARK: - Helper Methods
    
    /**
     * Creates a copy of this metrics with updated weight
     * 
     * - Parameter newWeight: New weight value
     * - Returns: New ProgressMetrics instance with updated weight
     */
    func withWeight(_ newWeight: Double?) -> ProgressMetrics {
        return ProgressMetrics(
            id: id,
            userId: userId,
            planId: planId,
            date: date,
            weight: newWeight,
            bodyFatPercentage: bodyFatPercentage,
            muscleMass: muscleMass,
            caloriesConsumed: caloriesConsumed,
            targetCalories: targetCalories,
            proteinConsumed: proteinConsumed,
            carbohydratesConsumed: carbohydratesConsumed,
            fatConsumed: fatConsumed,
            fiberConsumed: fiberConsumed,
            sugarConsumed: sugarConsumed,
            sodiumConsumed: sodiumConsumed,
            mealsCompleted: mealsCompleted,
            mealsPlanned: mealsPlanned,
            followedMealPlan: followedMealPlan,
            waterIntake: waterIntake,
            exerciseMinutes: exerciseMinutes,
            exerciseType: exerciseType,
            stepsTaken: stepsTaken,
            targetSteps: targetSteps,
            sleepHours: sleepHours,
            sleepQuality: sleepQuality,
            stressLevel: stressLevel,
            energyLevel: energyLevel,
            moodRating: moodRating,
            notes: notes,
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
    
    /**
     * Creates a copy of this metrics with updated meal completion
     * 
     * - Parameter newMealsCompleted: New number of meals completed
     * - Returns: New ProgressMetrics instance with updated meal completion
     */
    func withMealsCompleted(_ newMealsCompleted: Int) -> ProgressMetrics {
        return ProgressMetrics(
            id: id,
            userId: userId,
            planId: planId,
            date: date,
            weight: weight,
            bodyFatPercentage: bodyFatPercentage,
            muscleMass: muscleMass,
            caloriesConsumed: caloriesConsumed,
            targetCalories: targetCalories,
            proteinConsumed: proteinConsumed,
            carbohydratesConsumed: carbohydratesConsumed,
            fatConsumed: fatConsumed,
            fiberConsumed: fiberConsumed,
            sugarConsumed: sugarConsumed,
            sodiumConsumed: sodiumConsumed,
            mealsCompleted: newMealsCompleted,
            mealsPlanned: mealsPlanned,
            followedMealPlan: followedMealPlan,
            waterIntake: waterIntake,
            exerciseMinutes: exerciseMinutes,
            exerciseType: exerciseType,
            stepsTaken: stepsTaken,
            targetSteps: targetSteps,
            sleepHours: sleepHours,
            sleepQuality: sleepQuality,
            stressLevel: stressLevel,
            energyLevel: energyLevel,
            moodRating: moodRating,
            notes: notes,
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
    
    /**
     * Creates a copy of this metrics with updated calories consumed
     * 
     * - Parameter newCaloriesConsumed: New calories consumed value
     * - Returns: New ProgressMetrics instance with updated calories
     */
    func withCaloriesConsumed(_ newCaloriesConsumed: Int?) -> ProgressMetrics {
        return ProgressMetrics(
            id: id,
            userId: userId,
            planId: planId,
            date: date,
            weight: weight,
            bodyFatPercentage: bodyFatPercentage,
            muscleMass: muscleMass,
            caloriesConsumed: newCaloriesConsumed,
            targetCalories: targetCalories,
            proteinConsumed: proteinConsumed,
            carbohydratesConsumed: carbohydratesConsumed,
            fatConsumed: fatConsumed,
            fiberConsumed: fiberConsumed,
            sugarConsumed: sugarConsumed,
            sodiumConsumed: sodiumConsumed,
            mealsCompleted: mealsCompleted,
            mealsPlanned: mealsPlanned,
            followedMealPlan: followedMealPlan,
            waterIntake: waterIntake,
            exerciseMinutes: exerciseMinutes,
            exerciseType: exerciseType,
            stepsTaken: stepsTaken,
            targetSteps: targetSteps,
            sleepHours: sleepHours,
            sleepQuality: sleepQuality,
            stressLevel: stressLevel,
            energyLevel: energyLevel,
            moodRating: moodRating,
            notes: notes,
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
}

// MARK: - ProgressMetrics Extensions

extension ProgressMetrics {
    /**
     * Standard exercise types
     */
    static let exerciseTypes = [
        "Cardio",
        "Strength Training",
        "Yoga",
        "Pilates",
        "Walking",
        "Running",
        "Cycling",
        "Swimming",
        "HIIT",
        "Stretching",
        "Other"
    ]
    
    /**
     * Rating scale options
     */
    static let ratingScale = Array(1...10)
    
    /**
     * Sleep quality descriptions
     */
    static func sleepQualityDescription(for rating: Int) -> String {
        switch rating {
        case 1...3:
            return "Poor"
        case 4...6:
            return "Fair"
        case 7...8:
            return "Good"
        case 9...10:
            return "Excellent"
        default:
            return "Not rated"
        }
    }
    
    /**
     * Stress level descriptions
     */
    static func stressLevelDescription(for rating: Int) -> String {
        switch rating {
        case 1...3:
            return "Low"
        case 4...6:
            return "Moderate"
        case 7...8:
            return "High"
        case 9...10:
            return "Very High"
        default:
            return "Not rated"
        }
    }
    
    /**
     * Energy level descriptions
     */
    static func energyLevelDescription(for rating: Int) -> String {
        switch rating {
        case 1...3:
            return "Low"
        case 4...6:
            return "Moderate"
        case 7...8:
            return "High"
        case 9...10:
            return "Very High"
        default:
            return "Not rated"
        }
    }
    
    /**
     * Mood descriptions
     */
    static func moodDescription(for rating: Int) -> String {
        switch rating {
        case 1...3:
            return "Poor"
        case 4...6:
            return "Okay"
        case 7...8:
            return "Good"
        case 9...10:
            return "Excellent"
        default:
            return "Not rated"
        }
    }
}
