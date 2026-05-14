//
//  ProgressMetrics.swift
//  Makuli
//
//  Created by Ian on 2025-06-19.
//

import Foundation

struct ProgressMetrics: Identifiable, Codable {
    let id: String
    
    let userId: String
    
    let planId: String?
    
    let date: Date
    
    let weight: Double?
    
    let bodyFatPercentage: Double?
    
    let muscleMass: Double?
    
    let caloriesConsumed: Int?
    
    let targetCalories: Int?
    
    let proteinConsumed: Double?
    
    let carbohydratesConsumed: Double?
    
    let fatConsumed: Double?
    
    let fiberConsumed: Double?
    
    let sugarConsumed: Double?
    
    let sodiumConsumed: Int?
    
    let mealsCompleted: Int
    
    let mealsPlanned: Int
    
    let followedMealPlan: Bool
    
    let waterIntake: Int?
    
    let exerciseMinutes: Int?
    
    let exerciseType: String?
    
    let stepsTaken: Int?
    
    let targetSteps: Int?
    
    let sleepHours: Double?
    
    let sleepQuality: Int?
    
    let stressLevel: Int?
    
    let energyLevel: Int?
    
    let moodRating: Int?
    
    let notes: String?
    
    let createdAt: Date
    
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
    
    var mealPlanAdherence: Double {
        guard mealsPlanned > 0 else { return 0.0 }
        return Double(mealsCompleted) / Double(mealsPlanned) * 100.0
    }
    
    var calorieDifference: Int? {
        guard let consumed = caloriesConsumed, let target = targetCalories else { return nil }
        return consumed - target
    }
    
    var isInCalorieDeficit: Bool {
        guard let difference = calorieDifference else { return false }
        return difference < 0
    }
    
    var isInCalorieSurplus: Bool {
        guard let difference = calorieDifference else { return false }
        return difference > 0
    }
    
    var stepsGoalAchievement: Double? {
        guard let taken = stepsTaken, let target = targetSteps, target > 0 else { return nil }
        return Double(taken) / Double(target) * 100.0
    }
    
    var stepsGoalAchieved: Bool {
        guard let taken = stepsTaken, let target = targetSteps else { return false }
        return taken >= target
    }
    
    var totalMacroCalories: Double {
        let proteinCalories = (proteinConsumed ?? 0) * 4
        let carbCalories = (carbohydratesConsumed ?? 0) * 4
        let fatCalories = (fatConsumed ?? 0) * 9
        return proteinCalories + carbCalories + fatCalories
    }
    
    var proteinPercentage: Double? {
        guard let consumed = caloriesConsumed, consumed > 0 else { return nil }
        let proteinCalories = (proteinConsumed ?? 0) * 4
        return (proteinCalories / Double(consumed)) * 100.0
    }
    
    var carbohydratePercentage: Double? {
        guard let consumed = caloriesConsumed, consumed > 0 else { return nil }
        let carbCalories = (carbohydratesConsumed ?? 0) * 4
        return (carbCalories / Double(consumed)) * 100.0
    }
    
    var fatPercentage: Double? {
        guard let consumed = caloriesConsumed, consumed > 0 else { return nil }
        let fatCalories = (fatConsumed ?? 0) * 9
        return (fatCalories / Double(consumed)) * 100.0
    }
    
    var sleepGoalMet: Bool {
        guard let hours = sleepHours else { return false }
        return hours >= 7.0 && hours <= 9.0
    }
    
    var wellnessScore: Int {
        var score = 5
        
        if mealPlanAdherence >= 80 {
            score += 2
        } else if mealPlanAdherence >= 60 {
            score += 1
        }
        
        if let exercise = exerciseMinutes, exercise >= 30 {
            score += 2
        } else if let exercise = exerciseMinutes, exercise >= 15 {
            score += 1
        }
        
        if stepsGoalAchieved {
            score += 1
        }
        
        if sleepGoalMet {
            score += 1
        }
        
        if let water = waterIntake, water >= 8 {
            score += 1
        }
        
        if let energy = energyLevel, energy >= 7 {
            score += 1
        }
        if let mood = moodRating, mood >= 7 {
            score += 1
        }
        
        return min(score, 10)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    // MARK: - Helper Methods
    
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
    
    static let ratingScale = Array(1...10)
    
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
