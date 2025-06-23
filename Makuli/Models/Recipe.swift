//
//  Recipe.swift
//  Makuli
//
//  Created by Ian   on 22/06/2025.
//
import Foundation

struct Recipe: Identifiable, Hashable {
    let id: UUID
    let title: String
    let cookTime: String
    let servings: Int
    let imageName: String?
    let ingredients: [Ingredient]
    let steps: [String]
    let substitutions: [String]?
    let tags: [String]
    
    // initializer that accepts an ID
    init(id: UUID = UUID(), title: String, cookTime: String, servings: Int, imageName: String?, ingredients: [Ingredient], steps: [String], substitutions: [String]?, tags: [String] = []) {
        self.id = id
        self.title = title
        self.cookTime = cookTime
        self.servings = servings
        self.imageName = imageName
        self.ingredients = ingredients
        self.steps = steps
        self.substitutions = substitutions
        self.tags = tags
    }
    
    // Custom Hashable implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Custom Equatable implementation
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.id == rhs.id
    }
}



// **MARK: - Mock Data Extensions**
extension Recipe {
    
    static func enhancedMockRecipes() -> [Recipe] {
        return [
            Recipe(
                id: UUID(),
                title: "Matoke with Beans",
                cookTime: "25 mins",
                servings: 2,
                imageName: "🍌",
                ingredients: [
                    Ingredient(name: "Ripe bananas", quantity: "2"),
                    Ingredient(name: "Red beans", quantity: "1/2 cup"),
                    Ingredient(name: "Onion", quantity: "1"),
                    Ingredient(name: "Cooking oil", quantity: "2 tbsp"),
                    Ingredient(name: "Salt", quantity: "To taste")
                ],
                steps: [
                    "Peel and chop the bananas into small pieces.",
                    "Boil the beans until they are soft.",
                    "In a separate pot, sauté the onions until golden brown.",
                    "Add the bananas and beans to the pot with the onions. Stir well.",
                    "Cook for about 15 minutes, or until the bananas are tender."
                ],
                substitutions: [
                    "Use ndengu instead of red beans",
                    "Sweet potatoes can replace bananas for variety"
                ],
                tags: ["Traditional", "High-Protein", "Quick"]
            ),
            
            Recipe(
                id: UUID(),
                title: "Nyama Choma",
                cookTime: "60 mins",
                servings: 4,
                imageName: "🥩",
                ingredients: [
                    Ingredient(name: "Beef chunks", quantity: "1 kg"),
                    Ingredient(name: "Salt", quantity: "To taste"),
                    Ingredient(name: "Black pepper", quantity: "1 tsp"),
                    Ingredient(name: "Garlic", quantity: "3 cloves"),
                    Ingredient(name: "Ginger", quantity: "1 inch piece"),
                    Ingredient(name: "Cooking oil", quantity: "2 tbsp")
                ],
                steps: [
                    "Cut the beef into medium-sized chunks.",
                    "Season with salt, pepper, minced garlic, and ginger.",
                    "Let it marinate for at least 30 minutes.",
                    "Thread the meat onto skewers if desired.",
                    "Grill over medium-high heat, turning occasionally.",
                    "Cook until well done and slightly charred on the outside.",
                    "Serve hot with ugali and kachumbari."
                ],
                substitutions: [
                    "Can use goat meat instead of beef",
                    "Add rosemary for extra flavor"
                ],
                tags: ["Traditional", "High-Protein"]
            ),
            
            Recipe(
                id: UUID(),
                title: "Pilau",
                cookTime: "75 mins",
                servings: 6,
                imageName: "🍚",
                ingredients: [
                    Ingredient(name: "Basmati rice", quantity: "2 cups"),
                    Ingredient(name: "Beef or chicken", quantity: "500g"),
                    Ingredient(name: "Onions", quantity: "2 large"),
                    Ingredient(name: "Tomatoes", quantity: "2"),
                    Ingredient(name: "Pilau masala", quantity: "2 tbsp"),
                    Ingredient(name: "Garlic", quantity: "4 cloves"),
                    Ingredient(name: "Ginger", quantity: "1 inch piece"),
                    Ingredient(name: "Beef stock", quantity: "4 cups"),
                    Ingredient(name: "Cooking oil", quantity: "3 tbsp")
                ],
                steps: [
                    "Wash and soak the rice for 30 minutes.",
                    "In a heavy-bottomed pot, heat oil and brown the meat.",
                    "Add sliced onions and cook until golden brown.",
                    "Add garlic, ginger, and pilau masala. Cook for 2 minutes.",
                    "Add tomatoes and cook until soft.",
                    "Add the soaked rice and stir gently.",
                    "Pour in hot stock, bring to boil, then simmer covered for 20 minutes.",
                    "Let it rest for 10 minutes before serving."
                ],
                substitutions: [
                    "Use coconut milk instead of some stock for richer flavor",
                    "Add raisins and cashews for festive occasions"
                ],
                tags: ["Traditional", "High-Protein"]
            ),
            
            Recipe(
                id: UUID(),
                title: "Mukimo",
                cookTime: "55 mins",
                servings: 4,
                imageName: "🥔",
                ingredients: [
                    Ingredient(name: "Potatoes", quantity: "4 large"),
                    Ingredient(name: "Green maize", quantity: "2 cups"),
                    Ingredient(name: "Pumpkin leaves or spinach", quantity: "2 cups"),
                    Ingredient(name: "Green peas", quantity: "1 cup"),
                    Ingredient(name: "Onion", quantity: "1 large"),
                    Ingredient(name: "Cooking oil", quantity: "3 tbsp"),
                    Ingredient(name: "Salt", quantity: "To taste")
                ],
                steps: [
                    "Peel and chop potatoes into chunks.",
                    "Boil potatoes, green maize, and green peas together until tender.",
                    "In the last 5 minutes, add the green vegetables.",
                    "Drain the vegetables, reserving some cooking liquid.",
                    "Mash everything together, adding cooking liquid as needed.",
                    "In a separate pan, fry sliced onions until golden.",
                    "Mix the fried onions into the mukimo.",
                    "Season with salt and serve hot."
                ],
                substitutions: [
                    "Use sweet potatoes instead of regular potatoes",
                    "Kale can replace pumpkin leaves"
                ],
                tags: ["Traditional", "Healthy", "Budget"]
            ),
            
            Recipe(
                id: UUID(),
                title: "Chapati na Beans",
                cookTime: "35 mins",
                servings: 4,
                imageName: "🫓",
                ingredients: [
                    Ingredient(name: "All-purpose flour", quantity: "2 cups"),
                    Ingredient(name: "Water", quantity: "3/4 cup"),
                    Ingredient(name: "Salt", quantity: "1/2 tsp"),
                    Ingredient(name: "Cooking oil", quantity: "2 tbsp + extra for cooking"),
                    Ingredient(name: "Cooked beans", quantity: "2 cups"),
                    Ingredient(name: "Onion", quantity: "1"),
                    Ingredient(name: "Tomatoes", quantity: "2"),
                    Ingredient(name: "Garlic", quantity: "2 cloves")
                ],
                steps: [
                    "Mix flour and salt, add water and oil to form soft dough.",
                    "Knead well and let rest for 20 minutes.",
                    "Meanwhile, prepare beans by sautéing onions, garlic, and tomatoes.",
                    "Add cooked beans and simmer for 10 minutes.",
                    "Roll out chapati dough into thin circles.",
                    "Cook chapati on hot pan, brushing with oil until golden.",
                    "Serve hot chapati with the bean stew."
                ],
                substitutions: [
                    "Use whole wheat flour for healthier option",
                    "Add coconut milk to beans for richer flavor"
                ],
                tags: ["Budget", "High-Protein"]
            ),
            
            
            Recipe(
                id: UUID(),
                title: "Sukuma Wiki",
                cookTime: "15 mins",
                servings: 3,
                imageName: "🥬",
                ingredients: [
                    Ingredient(name: "Sukuma wiki (collard greens)", quantity: "1 bunch"),
                    Ingredient(name: "Onion", quantity: "1 medium"),
                    Ingredient(name: "Tomatoes", quantity: "2"),
                    Ingredient(name: "Garlic", quantity: "3 cloves"),
                    Ingredient(name: "Cooking oil", quantity: "2 tbsp"),
                    Ingredient(name: "Salt", quantity: "To taste")
                ],
                steps: [
                    "Wash and chop the sukuma wiki into strips.",
                    "Sauté sliced onions until translucent.",
                    "Add minced garlic and cook for 1 minute.",
                    "Add chopped tomatoes and cook until soft.",
                    "Add sukuma wiki and stir well.",
                    "Cook for 5-7 minutes until tender.",
                    "Season with salt and serve."
                ],
                substitutions: [
                    "Can use spinach instead of sukuma wiki",
                    "Add carrots for extra color and nutrition"
                ],
                tags: ["Quick", "Healthy", "Budget"]
            ),
            
            Recipe(
                id: UUID(),
                title: "Ugali",
                cookTime: "20 mins",
                servings: 4,
                imageName: "🌽",
                ingredients: [
                    Ingredient(name: "Maize flour (unga)", quantity: "2 cups"),
                    Ingredient(name: "Water", quantity: "3 cups"),
                    Ingredient(name: "Salt", quantity: "1/2 tsp")
                ],
                steps: [
                    "Bring water to boil in a heavy-bottomed pot.",
                    "Add salt to the boiling water.",
                    "Gradually add maize flour while stirring continuously.",
                    "Reduce heat and continue stirring to avoid lumps.",
                    "Cook for 10-15 minutes, stirring frequently.",
                    "The ugali is ready when it pulls away from the sides.",
                    "Serve hot with your favorite stew or vegetables."
                ],
                substitutions: [
                    "Can mix with millet flour for variety",
                    "Add a bit of butter for richer taste"
                ],
                tags: ["Quick", "Traditional", "Budget"]
            ),
            
            Recipe(
                id: UUID(),
                title: "Githeri",
                cookTime: "90 mins",
                servings: 6,
                imageName: "🌽",
                ingredients: [
                    Ingredient(name: "Maize (dry corn)", quantity: "1 cup"),
                    Ingredient(name: "Beans", quantity: "1 cup"),
                    Ingredient(name: "Onions", quantity: "2"),
                    Ingredient(name: "Tomatoes", quantity: "3"),
                    Ingredient(name: "Carrots", quantity: "2"),
                    Ingredient(name: "Cooking oil", quantity: "3 tbsp"),
                    Ingredient(name: "Salt", quantity: "To taste")
                ],
                steps: [
                    "Soak maize and beans overnight.",
                    "Boil maize and beans together until tender (about 1 hour).",
                    "In a separate pan, sauté onions until golden.",
                    "Add tomatoes and cook until soft.",
                    "Add diced carrots and cook for 5 minutes.",
                    "Add the cooked maize and beans.",
                    "Simmer together for 15-20 minutes.",
                    "Season with salt and serve hot."
                ],
                substitutions: [
                    "Add green peas for extra color",
                    "Can add meat for a heartier meal"
                ],
                tags: ["Traditional", "High-Protein", "Budget"]
            )
        ]
    }
    
    static var nyamaChomaRecipe: Recipe? {
        enhancedMockRecipes().first { $0.title == "Nyama Choma" }
    }
    static var pilauRecipe: Recipe? {
        enhancedMockRecipes().first { $0.title == "Pilau" }
    }
    static var sampleRecipe: Recipe? {
        enhancedMockRecipes().first { $0.title == "Matoke with Beans" }
    }
    static var mukimoRecipe: Recipe? {
        enhancedMockRecipes().first { $0.title == "Mukimo" }
    }
    static var chapatiRecipe: Recipe? {
        enhancedMockRecipes().first { $0.title == "Chapati na Beans" }
    }
}

// Helper extension for cook time conversion
extension Recipe {
    var cookTimeInMinutes: Int {
        let timeString = cookTime.lowercased()
        if let range = timeString.range(of: #"\d+"#, options: .regularExpression) {
            return Int(String(timeString[range])) ?? 0
        }
        return 0
    }
}
