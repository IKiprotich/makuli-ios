//
//  MockRecipes.swift
//  Makuli
//
//  Created by Ian on 2025-06-13.
//

#if DEBUG
import Foundation

enum MockRecipes {

    // MARK: - Breakfasts

    static let avocadoToast = Recipe(
        id: "mock-recipe-001",
        title: "Avocado Toast with Poached Eggs",
        cookTime: "10 min",
        prepTime: 5,
        servings: 2,
        calories: 380,
        imageUrl: "https://images.unsplash.com/photo-1541519227354-08fa5d50c820?auto=format&fit=crop&w=800&q=80",
        ingredients: [
            "2 thick slices sourdough bread",
            "1 ripe avocado",
            "2 large eggs",
            "1 tbsp white vinegar",
            "Pinch of chilli flakes",
            "Sea salt and black pepper",
            "Squeeze of lemon juice",
            "Fresh microgreens to serve"
        ],
        steps: [
            "Toast the sourdough bread until golden and crisp.",
            "Halve the avocado, remove the stone, and scoop flesh into a bowl. Mash with lemon juice, salt, and pepper.",
            "Fill a wide saucepan with water and bring to a gentle simmer. Add vinegar.",
            "Crack each egg into a small cup, then slide gently into the simmering water. Cook 3 minutes for a runny yolk.",
            "Spread mashed avocado onto each toast slice.",
            "Top with a poached egg, chilli flakes, and microgreens. Season and serve immediately."
        ],
        substitutions: [
            "Swap sourdough for gluten-free bread",
            "Use feta crumbles instead of eggs for a vegetarian option",
            "Add smoked salmon for extra protein"
        ],
        tags: ["breakfast", "vegetarian", "quick", "healthy"],
        difficulty: "easy",
        cuisineType: "modern",
        costEstimate: 4.50,
        createdAt: Date(timeIntervalSinceNow: -86400 * 30),
        updatedAt: Date(timeIntervalSinceNow: -86400 * 5),
        isPublic: true,
        rating: 4.7,
        ratingCount: 243
    )

    static let greekYogurtParfait = Recipe(
        id: "mock-recipe-002",
        title: "Greek Yogurt Parfait with Granola",
        cookTime: "0 min",
        prepTime: 5,
        servings: 1,
        calories: 320,
        imageUrl: "https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=800&q=80",
        ingredients: [
            "200g full-fat Greek yogurt",
            "60g homemade or shop-bought granola",
            "100g mixed berries (blueberries, raspberries, strawberries)",
            "1 tbsp honey or maple syrup",
            "1 tsp vanilla extract",
            "Pinch of cinnamon"
        ],
        steps: [
            "Stir vanilla extract into the Greek yogurt.",
            "In a glass or bowl, spoon half the yogurt as the first layer.",
            "Add half the granola and half the berries.",
            "Repeat with remaining yogurt, granola, and berries.",
            "Drizzle with honey and dust with cinnamon. Serve immediately."
        ],
        substitutions: [
            "Use dairy-free coconut yogurt",
            "Replace honey with agave for vegan version",
            "Swap berries for diced mango and kiwi"
        ],
        tags: ["breakfast", "no-cook", "vegetarian", "quick"],
        difficulty: "easy",
        cuisineType: "mediterranean",
        costEstimate: 3.20,
        createdAt: Date(timeIntervalSinceNow: -86400 * 25),
        updatedAt: Date(timeIntervalSinceNow: -86400 * 3),
        isPublic: true,
        rating: 4.5,
        ratingCount: 187
    )

    static let shakshuka = Recipe(
        id: "mock-recipe-003",
        title: "Shakshuka with Feta",
        cookTime: "25 min",
        prepTime: 10,
        servings: 4,
        calories: 290,
        imageUrl: "https://images.unsplash.com/photo-1590412200988-a436970781fa?auto=format&fit=crop&w=800&q=80",
        ingredients: [
            "2 tbsp olive oil",
            "1 large onion, diced",
            "1 red bell pepper, sliced",
            "4 garlic cloves, minced",
            "1 tsp cumin",
            "1 tsp smoked paprika",
            "½ tsp cayenne pepper",
            "2 × 400g cans crushed tomatoes",
            "6 large eggs",
            "100g feta cheese, crumbled",
            "Fresh parsley and warm bread to serve"
        ],
        steps: [
            "Heat olive oil in a large skillet over medium heat. Sauté onion and pepper until softened, about 8 minutes.",
            "Add garlic, cumin, paprika, and cayenne. Cook 1 minute until fragrant.",
            "Pour in crushed tomatoes. Season well and simmer 10 minutes until sauce thickens.",
            "Make 6 wells in the sauce with a spoon. Crack an egg into each well.",
            "Cover and cook 5–7 minutes until whites are set but yolks remain runny.",
            "Scatter feta and parsley over the top. Serve straight from the pan with crusty bread."
        ],
        substitutions: [
            "Replace feta with goat cheese",
            "Add spinach or kale for extra greens",
            "Use harissa paste for deeper heat"
        ],
        tags: ["breakfast", "vegetarian", "mediterranean", "one-pan"],
        difficulty: "medium",
        cuisineType: "middle-eastern",
        costEstimate: 6.80,
        createdAt: Date(timeIntervalSinceNow: -86400 * 20),
        updatedAt: Date(timeIntervalSinceNow: -86400 * 2),
        isPublic: true,
        rating: 4.9,
        ratingCount: 412
    )

    static let proteinPancakes = Recipe(
        id: "mock-recipe-004",
        title: "Banana Protein Pancakes",
        cookTime: "15 min",
        prepTime: 5,
        servings: 2,
        calories: 350,
        imageUrl: "https://images.unsplash.com/photo-1528207776546-365bb710ee93?auto=format&fit=crop&w=800&q=80",
        ingredients: [
            "2 ripe bananas",
            "2 large eggs",
            "1 scoop vanilla protein powder",
            "½ tsp baking powder",
            "½ tsp cinnamon",
            "1 tsp coconut oil for cooking",
            "Fresh berries and maple syrup to serve"
        ],
        steps: [
            "Mash bananas thoroughly in a bowl until smooth.",
            "Whisk in eggs until fully combined.",
            "Fold in protein powder, baking powder, and cinnamon to form a batter.",
            "Heat coconut oil in a non-stick pan over medium heat.",
            "Pour small ladles of batter to form pancakes. Cook 2 minutes per side until golden.",
            "Serve stacked with fresh berries and a drizzle of maple syrup."
        ],
        substitutions: [
            "Skip protein powder and add 2 tbsp almond flour",
            "Use flax eggs for a vegan version",
            "Replace banana with pumpkin purée"
        ],
        tags: ["breakfast", "high-protein", "gluten-free", "fitness"],
        difficulty: "easy",
        cuisineType: "american",
        costEstimate: 3.50,
        createdAt: Date(timeIntervalSinceNow: -86400 * 18),
        updatedAt: Date(timeIntervalSinceNow: -86400 * 1),
        isPublic: true,
        rating: 4.4,
        ratingCount: 156
    )

    static let overnightOats = Recipe(
        id: "mock-recipe-005",
        title: "Overnight Oats with Chia & Berries",
        cookTime: "0 min",
        prepTime: 5,
        servings: 1,
        calories: 410,
        imageUrl: "https://images.unsplash.com/photo-1516714435131-44d6b64dc6a2?auto=format&fit=crop&w=800&q=80",
        ingredients: [
            "80g rolled oats",
            "1 tbsp chia seeds",
            "240ml oat milk",
            "2 tbsp Greek yogurt",
            "1 tbsp maple syrup",
            "½ tsp vanilla extract",
            "Handful of mixed berries",
            "1 tbsp almond butter"
        ],
        steps: [
            "Combine oats, chia seeds, oat milk, yogurt, maple syrup, and vanilla in a jar.",
            "Stir well to combine. Seal and refrigerate overnight (at least 6 hours).",
            "In the morning, stir the oats. Add a splash more milk if too thick.",
            "Top with fresh berries and a spoonful of almond butter. Serve cold."
        ],
        substitutions: [
            "Use any plant-based milk",
            "Swap almond butter for peanut butter",
            "Add a scoop of protein powder for extra protein"
        ],
        tags: ["breakfast", "meal-prep", "no-cook", "vegetarian"],
        difficulty: "easy",
        cuisineType: "modern",
        costEstimate: 2.80,
        createdAt: Date(timeIntervalSinceNow: -86400 * 15),
        updatedAt: Date(timeIntervalSinceNow: -86400 * 1),
        isPublic: true,
        rating: 4.6,
        ratingCount: 298
    )

    static let spinachFetaOmelette = Recipe(
        id: "mock-recipe-006",
        title: "Spinach & Feta Omelette",
        cookTime: "8 min",
        prepTime: 5,
        servings: 1,
        calories: 310,
        imageUrl: "https://images.unsplash.com/photo-1612240498936-65f5101365d2?auto=format&fit=crop&w=800&q=80",
        ingredients: [
            "3 large eggs",
            "80g baby spinach",
            "60g feta cheese, crumbled",
            "1 tbsp butter",
            "1 garlic clove, minced",
            "Salt and black pepper",
            "Fresh dill to garnish"
        ],
        steps: [
            "Whisk eggs in a bowl with salt and pepper.",
            "Melt butter in a non-stick pan over medium heat. Add garlic and cook 30 seconds.",
            "Add spinach and wilt for 1–2 minutes.",
            "Pour eggs over the spinach. Cook undisturbed until edges set.",
            "Scatter feta over one half. Fold omelette and cook 1 more minute.",
            "Slide onto a plate, garnish with dill and serve immediately."
        ],
        substitutions: [
            "Use goat cheese instead of feta",
            "Add diced sun-dried tomatoes",
            "Replace butter with olive oil"
        ],
        tags: ["breakfast", "vegetarian", "low-carb", "high-protein", "quick"],
        difficulty: "easy",
        cuisineType: "mediterranean",
        costEstimate: 3.80,
        createdAt: Date(timeIntervalSinceNow: -86400 * 12),
        updatedAt: Date(timeIntervalSinceNow: -86400 * 1),
        isPublic: true,
        rating: 4.5,
        ratingCount: 134
    )

    // MARK: - Lunches

    static let caesarSalad = Recipe(
        id: "mock-recipe-007",
        title: "Classic Caesar Salad with Homemade Dressing",
        cookTime: "10 min",
        prepTime: 15,
        servings: 4,
        calories: 340,
        imageUrl: "https://images.unsplash.com/photo-1550304943-4f24f54ddde9?auto=format&fit=crop&w=800&q=80",
        ingredients: [
            "2 large romaine lettuce heads, chopped",
            "100g parmesan, freshly grated",
            "150g croutons",
            "2 garlic cloves",
            "3 anchovy fillets",
            "2 egg yolks",
            "1 tsp Dijon mustard",
            "2 tbsp lemon juice",
            "1 tsp Worcestershire sauce",
            "120ml extra-virgin olive oil",
            "Salt and black pepper"
        ],
        steps: [
            "Make dressing: pound garlic and anchovies into a paste using a mortar and pestle.",
            "Whisk in egg yolks, Dijon, lemon juice, and Worcestershire sauce.",
            "Slowly drizzle in olive oil while whisking constantly until emulsified. Season.",
            "In a large bowl, toss romaine with enough dressing to coat.",
            "Add parmesan and croutons. Toss gently and serve immediately."
        ],
        substitutions: [
            "Omit anchovies for a vegetarian version",
            "Use mayo-based dressing if concerned about raw egg",
            "Swap romaine for kale for a heartier salad"
        ],
        tags: ["lunch", "salad", "classic", "low-carb"],
        difficulty: "medium",
        cuisineType: "american",
        costEstimate: 8.50,
        createdAt: Date(timeIntervalSinceNow: -86400 * 22),
        updatedAt: Date(timeIntervalSinceNow: -86400 * 4),
        isPublic: true,
        rating: 4.6,
        ratingCount: 321
    )

    static let quinoaBowl = Recipe(
        id: "mock-recipe-008",
        title: "Roasted Vegetable Quinoa Bowl",
        cookTime: "30 min",
        prepTime: 10,
        servings: 2,
        calories: 480,
        imageUrl: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=80",
        ingredients: [
            "200g quinoa, rinsed",
            "1 courgette, cubed",
            "1 red bell pepper, sliced",
            "1 red onion, wedged",
            "200g cherry tomatoes",
            "400g can chickpeas, drained",
            "3 tbsp olive oil",
            "1 tsp smoked paprika",
            "1 tsp cumin",
            "60g feta cheese",
            "Fresh lemon and parsley to serve"
        ],
        steps: [
            "Preheat oven to 200°C. Toss vegetables and chickpeas with 2 tbsp olive oil, paprika, and cumin.",
            "Spread on a baking tray and roast 25 minutes until golden.",
            "Meanwhile, cook quinoa in 400ml salted water. Simmer 15 minutes, then fluff with a fork.",
            "Divide quinoa between bowls. Top with roasted vegetables.",
            "Crumble feta over, drizzle with remaining olive oil, and finish with lemon juice and parsley."
        ],
        substitutions: [
            "Use brown rice or farro instead of quinoa",
            "Add tahini dressing for a different flavour profile",
            "Swap chickpeas for lentils"
        ],
        tags: ["lunch", "vegetarian", "meal-prep", "healthy"],
        difficulty: "easy",
        cuisineType: "mediterranean",
        costEstimate: 7.20,
        createdAt: Date(timeIntervalSinceNow: -86400 * 19),
        updatedAt: Date(timeIntervalSinceNow: -86400 * 3),
        isPublic: true,
        rating: 4.7,
        ratingCount: 278
    )

    static let lentilSoup = Recipe(
        id: "mock-recipe-009",
        title: "Spiced Red Lentil Soup",
        cookTime: "35 min",
        prepTime: 10,
        servings: 6,
        calories: 260,
        imageUrl: "https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=800&q=80",
        ingredients: [
            "300g red lentils, rinsed",
            "1 large onion, diced",
            "3 garlic cloves, minced",
            "2 carrots, diced",
            "2 tbsp olive oil",
            "1 tsp turmeric",
            "1 tsp cumin",
            "1 tsp coriander",
            "½ tsp cayenne pepper",
            "1.5L vegetable stock",
            "400g can crushed tomatoes",
            "Juice of 1 lemon",
            "Fresh coriander and warm pitta to serve"
        ],
        steps: [
            "Heat olive oil in a large pot. Sauté onion and carrot until soft, about 8 minutes.",
            "Add garlic and all spices. Cook 1 minute until fragrant.",
            "Add lentils, crushed tomatoes, and stock. Bring to a boil.",
            "Reduce heat and simmer 25 minutes until lentils are completely tender.",
            "Use a stick blender to partially blend for a creamy yet textured consistency.",
            "Stir in lemon juice, adjust seasoning, and serve with fresh coriander and pitta."
        ],
        substitutions: [
            "Use green lentils for a heartier texture",
            "Add coconut milk for a creamier soup",
            "Stir in a handful of spinach at the end"
        ],
        tags: ["lunch", "vegan", "budget", "meal-prep", "soup"],
        difficulty: "easy",
        cuisineType: "middle-eastern",
        costEstimate: 4.50,
        createdAt: Date(timeIntervalSinceNow: -86400 * 16),
        updatedAt: Date(timeIntervalSinceNow: -86400 * 2),
        isPublic: true,
        rating: 4.8,
        ratingCount: 445
    )

    static let vietnameseSpringRolls = Recipe(
        id: "mock-recipe-010",
        title: "Fresh Vietnamese Spring Rolls",
        cookTime: "15 min",
        prepTime: 20,
        servings: 4,
        calories: 220,
        imageUrl: "https://images.unsplash.com/photo-1562802378-063ec186a863?auto=format&fit=crop&w=800&q=80",
        ingredients: [
            "12 rice paper wrappers",
            "200g cooked prawns, halved",
            "100g vermicelli noodles, cooked",
            "1 carrot, julienned",
            "1 cucumber, julienned",
            "1 avocado, sliced",
            "Fresh mint and coriander",
            "3 tbsp hoisin sauce",
            "2 tbsp peanut butter",
            "1 tbsp lime juice",
            "1 tsp chilli sauce"
        ],
        steps: [
            "Make dipping sauce: whisk together hoisin, peanut butter, lime juice, and chilli sauce.",
            "Prepare all filling ingredients and lay them out on a board.",
            "Dip a rice paper wrapper in warm water for 20 seconds until soft and pliable.",
            "Lay on a damp board. Place prawns in a line, then add noodles, vegetables, and herbs.",
            "Fold in sides and roll tightly from the bottom up.",
            "Serve immediately with peanut-hoisin dipping sauce."
        ],
        substitutions: [
            "Use tofu instead of prawns for a vegan version",
            "Replace vermicelli with shredded cabbage",
            "Add mango slices for a fruity twist"
        ],
        tags: ["lunch", "vietnamese", "light", "gluten-free"],
        difficulty: "medium",
        cuisineType: "asian",
        costEstimate: 9.00,
        createdAt: Date(timeIntervalSinceNow: -86400 * 14),
        updatedAt: Date(timeIntervalSinceNow: -86400 * 2),
        isPublic: true,
        rating: 4.6,
        ratingCount: 203
    )

    static let thaiPeanutNoodles = Recipe(
        id: "mock-recipe-011",
        title: "Thai Peanut Noodles",
        cookTime: "15 min",
        prepTime: 10,
        servings: 3,
        calories: 510,
        imageUrl: "https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?auto=format&fit=crop&w=800&q=80",
        ingredients: [
            "250g soba noodles",
            "3 tbsp smooth peanut butter",
            "2 tbsp soy sauce",
            "1 tbsp sesame oil",
            "1 tbsp rice vinegar",
            "1 tbsp honey",
            "1 tsp grated ginger",
            "1 garlic clove, minced",
            "1 red chilli, thinly sliced",
            "1 cucumber, julienned",
            "2 spring onions, sliced",
            "Handful of roasted peanuts and sesame seeds"
        ],
        steps: [
            "Cook soba noodles according to packet instructions. Drain and rinse with cold water.",
            "Whisk peanut butter, soy sauce, sesame oil, rice vinegar, honey, ginger, and garlic into a smooth sauce.",
            "Toss cold noodles with the peanut sauce until evenly coated.",
            "Top with cucumber, spring onions, chilli, peanuts, and sesame seeds.",
            "Serve at room temperature or refrigerate for up to 2 days."
        ],
        substitutions: [
            "Use rice noodles for gluten-free",
            "Replace peanut butter with almond butter",
            "Add shredded chicken or tofu for protein"
        ],
        tags: ["lunch", "asian", "meal-prep", "quick"],
        difficulty: "easy",
        cuisineType: "thai",
        costEstimate: 5.80,
        createdAt: Date(timeIntervalSinceNow: -86400 * 11),
        updatedAt: Date(timeIntervalSinceNow: -86400 * 1),
        isPublic: true,
        rating: 4.7,
        ratingCount: 334
    )

    static let turkeyWrap = Recipe(
        id: "mock-recipe-012",
        title: "Turkey & Avocado Club Wrap",
        cookTime: "5 min",
        prepTime: 10,
        servings: 2,
        calories: 430,
        imageUrl: "https://images.unsplash.com/photo-1626700051175-6818013e1d4f?auto=format&fit=crop&w=800&q=80",
        ingredients: [
            "2 large whole-wheat tortillas",
            "200g sliced turkey breast",
            "1 ripe avocado, mashed",
            "4 crispy bacon rashers",
            "2 romaine lettuce leaves",
            "2 ripe tomatoes, sliced",
            "2 tbsp Greek yogurt",
            "1 tsp Dijon mustard",
            "Salt and pepper"
        ],
        steps: [
            "Mix Greek yogurt with Dijon mustard to make a quick sauce.",
            "Spread sauce over each tortilla.",
            "Layer turkey, bacon, lettuce, tomato, and mashed avocado onto the tortilla.",
            "Season with salt and pepper.",
            "Roll tightly, tucking in the sides. Cut diagonally and serve immediately."
        ],
        substitutions: [
            "Use smoked salmon instead of turkey",
            "Replace bacon with cucumber for a lighter wrap",
            "Use a lettuce leaf as the wrap for a low-carb option"
        ],
        tags: ["lunch", "quick", "high-protein", "wrap"],
        difficulty: "easy",
        cuisineType: "american",
        costEstimate: 6.50,
        createdAt: Date(timeIntervalSinceNow: -86400 * 9),
        updatedAt: Date(timeIntervalSinceNow: -86400 * 1),
        isPublic: true,
        rating: 4.4,
        ratingCount: 178
    )

    static let bibimbap = Recipe(
        id: "mock-recipe-013",
        title: "Korean Bibimbap Bowl",
        cookTime: "30 min",
        prepTime: 20,
        servings: 2,
        calories: 560,
        imageUrl: "https://images.unsplash.com/photo-1590301157890-4810ed352733?auto=format&fit=crop&w=800&q=80",
        ingredients: [
            "300g short-grain rice, cooked",
            "200g beef mince",
            "1 tbsp soy sauce",
            "1 tsp sesame oil",
            "200g spinach, blanched",
            "2 carrots, julienned and sautéed",
            "100g bean sprouts",
            "2 eggs, fried",
            "4 tbsp gochujang (Korean chilli paste)",
            "1 tbsp rice vinegar",
            "1 tsp sugar",
            "Sesame seeds and spring onions"
        ],
        steps: [
            "Season beef with soy sauce and sesame oil. Stir-fry until cooked through.",
            "Mix gochujang with rice vinegar and sugar to make the sauce.",
            "Prepare all vegetables: blanch spinach, sauté carrots, rinse bean sprouts.",
            "Divide rice between two stone bowls or deep bowls.",
            "Arrange beef and all vegetables in sections on top of the rice.",
            "Top each bowl with a fried egg. Serve with gochujang sauce and sesame seeds."
        ],
        substitutions: [
            "Use mushrooms instead of beef for a vegetarian version",
            "Add kimchi for authentic Korean flavour",
            "Use cauliflower rice for lower carbs"
        ],
        tags: ["lunch", "korean", "high-protein", "gluten-free"],
        difficulty: "medium",
        cuisineType: "korean",
        costEstimate: 10.50,
        createdAt: Date(timeIntervalSinceNow: -86400 * 7),
        updatedAt: Date(timeIntervalSinceNow: -86400 * 1),
        isPublic: true,
        rating: 4.8,
        ratingCount: 389
    )

    static let tunaNicoise = Recipe(
        id: "mock-recipe-014",
        title: "Tuna Niçoise Salad",
        cookTime: "15 min",
        prepTime: 10,
        servings: 2,
        calories: 390,
        imageUrl: "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=800&q=80",
        ingredients: [
            "2 × 185g cans premium tuna in olive oil",
            "4 large eggs, soft-boiled",
            "200g green beans, blanched",
            "150g cherry tomatoes, halved",
            "80g black olives",
            "1 little gem lettuce",
            "2 tbsp capers",
            "3 tbsp extra-virgin olive oil",
            "1 tbsp red wine vinegar",
            "1 tsp Dijon mustard",
            "Salt and black pepper"
        ],
        steps: [
            "Cook eggs in boiling water for 7 minutes. Cool in ice water, peel and halve.",
            "Whisk olive oil, vinegar, and Dijon together to make the dressing. Season well.",
            "Arrange lettuce leaves on two plates as the base.",
            "Divide tuna, eggs, green beans, tomatoes, and olives between the plates.",
            "Scatter capers and drizzle dressing generously over each salad."
        ],
        substitutions: [
            "Use fresh seared tuna for a more premium version",
            "Add roasted potatoes for a more substantial meal",
            "Replace olives with artichoke hearts"
        ],
        tags: ["lunch", "french", "high-protein", "low-carb", "salad"],
        difficulty: "easy",
        cuisineType: "french",
        costEstimate: 8.80,
        createdAt: Date(timeIntervalSinceNow: -86400 * 5),
        updatedAt: Date(),
        isPublic: true,
        rating: 4.5,
        ratingCount: 221
    )

    // MARK: - Dinners

    static let grilledSalmon = Recipe(
        id: "mock-recipe-015",
        title: "Mediterranean Herb-Crusted Salmon",
        cookTime: "20 min",
        prepTime: 10,
        servings: 4,
        calories: 420,
        imageUrl: "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?auto=format&fit=crop&w=800&q=80",
        ingredients: [
            "4 salmon fillets (approx. 180g each)",
            "3 tbsp fresh parsley, chopped",
            "2 tbsp fresh dill, chopped",
            "2 garlic cloves, minced",
            "Zest of 1 lemon",
            "3 tbsp olive oil",
            "Salt and black pepper",
            "Lemon wedges and capers to serve"
        ],
        steps: [
            "Preheat oven to 200°C or heat a cast-iron grill pan over high heat.",
            "Mix herbs, garlic, lemon zest, and 2 tbsp olive oil into a rough paste.",
            "Season salmon generously with salt and pepper.",
            "Press herb crust firmly onto the top of each fillet.",
            "Grill or bake skin-side down for 12–14 minutes until cooked through.",
            "Serve with lemon wedges, capers, and a green salad."
        ],
        substitutions: [
            "Use sea bass or cod instead of salmon",
            "Add Dijon mustard to the herb crust",
            "Finish with a drizzle of brown butter"
        ],
        tags: ["dinner", "seafood", "mediterranean", "healthy", "gluten-free"],
        difficulty: "easy",
        cuisineType: "mediterranean",
        costEstimate: 18.50,
        createdAt: Date(timeIntervalSinceNow: -86400 * 28),
        updatedAt: Date(timeIntervalSinceNow: -86400 * 5),
        isPublic: true,
        rating: 4.8,
        ratingCount: 512
    )

    static let chickenTikkaMasala = Recipe(
        id: "mock-recipe-016",
        title: "Chicken Tikka Masala",
        cookTime: "40 min",
        prepTime: 20,
        servings: 4,
        calories: 490,
        imageUrl: "https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=800&q=80",
        ingredients: [
            "800g chicken thighs, cubed",
            "250ml full-fat yogurt",
            "3 tbsp tikka spice paste",
            "2 tbsp vegetable oil",
            "2 large onions, finely diced",
            "4 garlic cloves, minced",
            "2 tsp grated ginger",
            "400g can crushed tomatoes",
            "200ml double cream",
            "1 tsp garam masala",
            "Fresh coriander and basmati rice to serve"
        ],
        steps: [
            "Marinate chicken in yogurt and 2 tbsp tikka paste for at least 1 hour (or overnight).",
            "Grill or cook chicken in a hot pan until charred. Set aside.",
            "Heat oil and fry onions until deep golden brown, about 15 minutes.",
            "Add garlic, ginger, and remaining tikka paste. Cook 2 minutes.",
            "Add crushed tomatoes. Simmer 15 minutes until sauce thickens.",
            "Stir in cream and grilled chicken. Simmer 10 minutes.",
            "Finish with garam masala. Serve with basmati rice and fresh coriander."
        ],
        substitutions: [
            "Use paneer instead of chicken for a vegetarian version",
            "Replace double cream with coconut cream",
            "Add spinach for extra nutrition"
        ],
        tags: ["dinner", "indian", "curry", "gluten-free"],
        difficulty: "medium",
        cuisineType: "indian",
        costEstimate: 14.00,
        createdAt: Date(timeIntervalSinceNow: -86400 * 24),
        updatedAt: Date(timeIntervalSinceNow: -86400 * 4),
        isPublic: true,
        rating: 4.9,
        ratingCount: 678
    )

    static let spaghettiBolognese = Recipe(
        id: "mock-recipe-017",
        title: "Classic Spaghetti Bolognese",
        cookTime: "60 min",
        prepTime: 15,
        servings: 6,
        calories: 580,
        imageUrl: "https://images.unsplash.com/photo-1598103442097-8b74394b95c1?auto=format&fit=crop&w=800&q=80",
        ingredients: [
            "500g beef mince",
            "150g pancetta, diced",
            "1 large onion, finely diced",
            "2 celery stalks, diced",
            "2 carrots, diced",
            "4 garlic cloves, minced",
            "200ml red wine",
            "2 × 400g cans crushed tomatoes",
            "2 tbsp tomato purée",
            "150ml whole milk",
            "500g spaghetti",
            "Freshly grated parmesan and basil to serve"
        ],
        steps: [
            "Render pancetta in a heavy-bottomed pot over medium heat. Remove and set aside.",
            "Brown beef mince in the same pot in batches. Season well.",
            "Add onion, celery, carrot, and garlic. Cook until softened, about 10 minutes.",
            "Pour in wine. Cook until evaporated, about 5 minutes.",
            "Add tomatoes, tomato purée, and pancetta. Season and simmer on low heat 45 minutes.",
            "Stir in milk and cook a further 10 minutes. Adjust seasoning.",
            "Cook spaghetti to al dente. Toss with sauce and serve with parmesan and basil."
        ],
        substitutions: [
            "Use a meat mixture of beef and pork for extra richness",
            "Add chicken livers for a more traditional Bolognese",
            "Use tagliatelle instead of spaghetti"
        ],
        tags: ["dinner", "italian", "classic", "meal-prep"],
        difficulty: "medium",
        cuisineType: "italian",
        costEstimate: 12.50,
        createdAt: Date(timeIntervalSinceNow: -86400 * 21),
        updatedAt: Date(timeIntervalSinceNow: -86400 * 3),
        isPublic: true,
        rating: 4.8,
        ratingCount: 891
    )

    static let koreanBulgogi = Recipe(
        id: "mock-recipe-018",
        title: "Korean Beef Bulgogi",
        cookTime: "15 min",
        prepTime: 15,
        servings: 4,
        calories: 450,
        imageUrl: "https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=800&q=80",
        ingredients: [
            "700g ribeye or sirloin, thinly sliced",
            "4 tbsp soy sauce",
            "2 tbsp sesame oil",
            "2 tbsp brown sugar",
            "4 garlic cloves, minced",
            "2 tsp grated ginger",
            "1 Asian pear, grated (acts as tenderiser)",
            "1 tbsp gochujang",
            "Spring onions, sesame seeds, lettuce cups and steamed rice to serve"
        ],
        steps: [
            "Combine soy sauce, sesame oil, sugar, garlic, ginger, pear, and gochujang in a bowl.",
            "Add beef slices and mix to coat. Marinate for at least 30 minutes.",
            "Heat a cast-iron skillet or BBQ grill over very high heat.",
            "Cook beef in batches for 2–3 minutes until caramelised and slightly charred.",
            "Serve in lettuce cups with steamed rice, sesame seeds, and sliced spring onions."
        ],
        substitutions: [
            "Use chicken thighs instead of beef",
            "Replace Asian pear with kiwi fruit",
            "Use portobello mushrooms for a vegetarian version"
        ],
        tags: ["dinner", "korean", "gluten-free", "high-protein"],
        difficulty: "medium",
        cuisineType: "korean",
        costEstimate: 16.00,
        createdAt: Date(timeIntervalSinceNow: -86400 * 17),
        updatedAt: Date(timeIntervalSinceNow: -86400 * 2),
        isPublic: true,
        rating: 4.9,
        ratingCount: 543
    )

    static let chickenEnchiladas = Recipe(
        id: "mock-recipe-019",
        title: "Chicken & Black Bean Enchiladas",
        cookTime: "35 min",
        prepTime: 20,
        servings: 4,
        calories: 520,
        imageUrl: "https://images.unsplash.com/photo-1599974579688-8dbdd335c77f?auto=format&fit=crop&w=800&q=80",
        ingredients: [
            "600g cooked chicken breast, shredded",
            "400g can black beans, drained",
            "8 flour tortillas",
            "400g enchilada sauce",
            "200g cheddar cheese, grated",
            "1 onion, sautéed",
            "2 tsp cumin",
            "1 tsp smoked paprika",
            "Soured cream, guacamole, and coriander to serve"
        ],
        steps: [
            "Preheat oven to 190°C. Mix chicken, black beans, onion, cumin, and paprika.",
            "Spread a thin layer of enchilada sauce in the bottom of a baking dish.",
            "Spoon filling onto each tortilla, roll tightly, and place seam-side down in dish.",
            "Pour remaining enchilada sauce over the tortillas. Top with cheddar.",
            "Cover with foil and bake 20 minutes. Remove foil and bake 10 more minutes until bubbly.",
            "Serve with soured cream, guacamole, and fresh coriander."
        ],
        substitutions: [
            "Use beef mince instead of chicken",
            "Replace flour tortillas with corn tortillas for gluten-free",
            "Add jalapeños for extra heat"
        ],
        tags: ["dinner", "mexican", "comfort", "family"],
        difficulty: "easy",
        cuisineType: "mexican",
        costEstimate: 13.00,
        createdAt: Date(timeIntervalSinceNow: -86400 * 13),
        updatedAt: Date(timeIntervalSinceNow: -86400 * 2),
        isPublic: true,
        rating: 4.6,
        ratingCount: 367
    )

    static let mushroomRisotto = Recipe(
        id: "mock-recipe-020",
        title: "Wild Mushroom Risotto",
        cookTime: "35 min",
        prepTime: 10,
        servings: 4,
        calories: 480,
        imageUrl: "https://images.unsplash.com/photo-1476124369491-e7addf5db371?auto=format&fit=crop&w=800&q=80",
        ingredients: [
            "350g Arborio rice",
            "400g mixed wild mushrooms",
            "1 large onion, finely diced",
            "3 garlic cloves, minced",
            "150ml dry white wine",
            "1.2L hot vegetable stock",
            "60g butter",
            "100g parmesan, grated",
            "2 tbsp olive oil",
            "Fresh thyme and parsley",
            "Salt and black pepper"
        ],
        steps: [
            "Heat stock and keep warm in a separate pan.",
            "Sauté mushrooms in 1 tbsp butter until golden. Season and set aside.",
            "In a heavy pan, heat olive oil and cook onion until soft. Add garlic and rice.",
            "Toast rice 2 minutes. Add wine and stir until absorbed.",
            "Add stock one ladle at a time, stirring constantly. This takes about 18–20 minutes.",
            "When rice is al dente, remove from heat. Stir in remaining butter, parmesan, and mushrooms.",
            "Rest 2 minutes, adjust seasoning, and serve with fresh herbs."
        ],
        substitutions: [
            "Use asparagus or courgette instead of mushrooms",
            "Replace white wine with extra stock",
            "Add truffle oil at the end for a luxurious finish"
        ],
        tags: ["dinner", "vegetarian", "italian", "comfort"],
        difficulty: "medium",
        cuisineType: "italian",
        costEstimate: 11.00,
        createdAt: Date(timeIntervalSinceNow: -86400 * 10),
        updatedAt: Date(timeIntervalSinceNow: -86400 * 1),
        isPublic: true,
        rating: 4.8,
        ratingCount: 456
    )

    static let padThai = Recipe(
        id: "mock-recipe-021",
        title: "Classic Pad Thai with Prawns",
        cookTime: "20 min",
        prepTime: 15,
        servings: 2,
        calories: 540,
        imageUrl: "https://images.unsplash.com/photo-1559314809-0d155014e29e?auto=format&fit=crop&w=800&q=80",
        ingredients: [
            "200g flat rice noodles",
            "300g raw king prawns, peeled",
            "3 eggs",
            "3 tbsp fish sauce",
            "2 tbsp tamarind paste",
            "1 tbsp palm sugar",
            "3 spring onions, sliced",
            "100g bean sprouts",
            "50g roasted peanuts, crushed",
            "3 tbsp vegetable oil",
            "2 garlic cloves, minced",
            "Lime wedges and chilli flakes to serve"
        ],
        steps: [
            "Soak rice noodles in warm water for 20 minutes until pliable. Drain.",
            "Mix fish sauce, tamarind paste, and palm sugar into a sauce.",
            "Heat oil in a wok over very high heat. Cook prawns until pink. Push to one side.",
            "Scramble eggs in the wok until just set.",
            "Add drained noodles and sauce. Toss vigorously for 2 minutes.",
            "Add bean sprouts and spring onions. Toss briefly.",
            "Serve topped with crushed peanuts, lime wedges, and chilli flakes."
        ],
        substitutions: [
            "Use tofu or chicken instead of prawns",
            "Replace tamarind with lime juice and a little ketchup",
            "Use soy sauce instead of fish sauce for a vegan version"
        ],
        tags: ["dinner", "thai", "asian", "quick"],
        difficulty: "medium",
        cuisineType: "thai",
        costEstimate: 13.50,
        createdAt: Date(timeIntervalSinceNow: -86400 * 8),
        updatedAt: Date(timeIntervalSinceNow: -86400 * 1),
        isPublic: true,
        rating: 4.7,
        ratingCount: 389
    )

    static let roastedChicken = Recipe(
        id: "mock-recipe-022",
        title: "Herb Butter Roast Chicken",
        cookTime: "90 min",
        prepTime: 15,
        servings: 6,
        calories: 510,
        imageUrl: "https://images.unsplash.com/photo-1598103442097-8b74394b95c1?auto=format&fit=crop&w=800&q=80",
        ingredients: [
            "1 whole chicken (approx. 1.8kg)",
            "100g butter, softened",
            "4 garlic cloves, minced",
            "1 tbsp fresh thyme leaves",
            "1 tbsp fresh rosemary, chopped",
            "1 lemon, halved",
            "Salt and black pepper",
            "500g new potatoes",
            "2 tbsp olive oil"
        ],
        steps: [
            "Preheat oven to 200°C. Mix butter with garlic, thyme, and rosemary.",
            "Carefully loosen chicken skin and rub herb butter under and over the skin.",
            "Season chicken generously inside and out. Stuff with lemon halves.",
            "Toss potatoes with olive oil and arrange around the chicken.",
            "Roast for 1 hour 20 minutes, basting halfway through.",
            "Rest for 15 minutes before carving. Serve with roasting juices and potatoes."
        ],
        substitutions: [
            "Use chicken thighs for a faster cook and more flavour",
            "Add root vegetables (carrots, parsnips) to the roasting tin",
            "Replace butter with olive oil for a dairy-free version"
        ],
        tags: ["dinner", "british", "comfort", "family", "meal-prep"],
        difficulty: "medium",
        cuisineType: "british",
        costEstimate: 14.00,
        createdAt: Date(timeIntervalSinceNow: -86400 * 6),
        updatedAt: Date(timeIntervalSinceNow: -86400 * 1),
        isPublic: true,
        rating: 4.7,
        ratingCount: 612
    )

    static let thaiGreenCurry = Recipe(
        id: "mock-recipe-023",
        title: "Thai Green Curry with Tofu",
        cookTime: "25 min",
        prepTime: 10,
        servings: 4,
        calories: 420,
        imageUrl: "https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?auto=format&fit=crop&w=800&q=80",
        ingredients: [
            "400g firm tofu, cubed",
            "2 × 400ml cans coconut milk",
            "3 tbsp green curry paste",
            "200g baby corn",
            "150g mange tout",
            "1 red bell pepper, sliced",
            "4 kaffir lime leaves",
            "2 tbsp fish sauce (or soy sauce)",
            "1 tbsp palm sugar",
            "Handful of Thai basil",
            "Jasmine rice to serve"
        ],
        steps: [
            "Press tofu and cut into cubes. Pan-fry until golden. Set aside.",
            "Open one can of coconut milk. Scoop the thick cream from the top into a wok.",
            "Cook cream over medium heat until bubbling and slightly separated.",
            "Add green curry paste and cook 2 minutes until fragrant.",
            "Add remaining coconut milk, kaffir lime leaves, fish sauce, and sugar.",
            "Add vegetables and tofu. Simmer 10 minutes.",
            "Finish with Thai basil. Serve with jasmine rice."
        ],
        substitutions: [
            "Use chicken breast or prawns instead of tofu",
            "Add bamboo shoots for an authentic texture",
            "Replace fish sauce with soy sauce for vegan"
        ],
        tags: ["dinner", "thai", "vegan", "gluten-free"],
        difficulty: "medium",
        cuisineType: "thai",
        costEstimate: 11.50,
        createdAt: Date(timeIntervalSinceNow: -86400 * 4),
        updatedAt: Date(),
        isPublic: true,
        rating: 4.7,
        ratingCount: 287
    )

    static let lambKofta = Recipe(
        id: "mock-recipe-024",
        title: "Lamb Kofta with Tzatziki",
        cookTime: "20 min",
        prepTime: 15,
        servings: 4,
        calories: 460,
        imageUrl: "https://images.unsplash.com/photo-1529042410759-befb1204b468?auto=format&fit=crop&w=800&q=80",
        ingredients: [
            "600g lamb mince",
            "1 onion, grated",
            "3 garlic cloves, minced",
            "2 tsp cumin",
            "1 tsp coriander",
            "½ tsp cinnamon",
            "¼ tsp cayenne",
            "2 tbsp fresh parsley, chopped",
            "200g Greek yogurt",
            "1 cucumber, grated and drained",
            "1 tbsp fresh mint",
            "Flatbreads and salad to serve"
        ],
        steps: [
            "Mix lamb with onion, garlic, cumin, coriander, cinnamon, cayenne, and parsley.",
            "Divide into 12 portions and shape around metal skewers.",
            "Make tzatziki by combining yogurt with cucumber, mint, and a pinch of salt.",
            "Grill kofta on a hot BBQ or griddle pan for 8–10 minutes, turning halfway.",
            "Serve with warm flatbreads, tzatziki, and a fresh tomato salad."
        ],
        substitutions: [
            "Use beef mince instead of lamb",
            "Shape into patties instead of skewers",
            "Serve in pitta bread with pickled onions"
        ],
        tags: ["dinner", "middle-eastern", "gluten-free", "high-protein"],
        difficulty: "easy",
        cuisineType: "middle-eastern",
        costEstimate: 15.00,
        createdAt: Date(timeIntervalSinceNow: -86400 * 3),
        updatedAt: Date(),
        isPublic: true,
        rating: 4.8,
        ratingCount: 224
    )

    // MARK: - Snacks

    static let hummusPlatter = Recipe(
        id: "mock-recipe-025",
        title: "Homemade Hummus Platter",
        cookTime: "5 min",
        prepTime: 10,
        servings: 6,
        calories: 180,
        imageUrl: "https://images.unsplash.com/photo-1534939561126-855b8675edd7?auto=format&fit=crop&w=800&q=80",
        ingredients: [
            "2 × 400g cans chickpeas, drained (reserve liquid)",
            "4 tbsp tahini",
            "Juice of 2 lemons",
            "3 garlic cloves",
            "4 tbsp ice water",
            "Salt to taste",
            "Extra-virgin olive oil, smoked paprika, and parsley to garnish",
            "Pitta, crudités, and olives to serve"
        ],
        steps: [
            "Add chickpeas, tahini, lemon juice, and garlic to a food processor.",
            "Blend for 1 minute. Add ice water and blend for 3 more minutes until very smooth.",
            "Season generously with salt. Add more lemon juice to taste.",
            "Spread onto a plate making a well in the centre.",
            "Drizzle with olive oil. Dust with paprika and scatter parsley.",
            "Serve with warm pitta, fresh crudités, and olives."
        ],
        substitutions: [
            "Add roasted red peppers for a different flavour",
            "Use white beans instead of chickpeas",
            "Blend in roasted garlic for a sweeter hummus"
        ],
        tags: ["snack", "vegan", "middle-eastern", "meal-prep", "gluten-free"],
        difficulty: "easy",
        cuisineType: "middle-eastern",
        costEstimate: 5.00,
        createdAt: Date(timeIntervalSinceNow: -86400 * 26),
        updatedAt: Date(timeIntervalSinceNow: -86400 * 4),
        isPublic: true,
        rating: 4.7,
        ratingCount: 356
    )

    static let energyBalls = Recipe(
        id: "mock-recipe-026",
        title: "Dark Chocolate & Almond Energy Balls",
        cookTime: "0 min",
        prepTime: 15,
        servings: 12,
        calories: 140,
        imageUrl: "https://images.unsplash.com/photo-1604329760661-e71dc83f8f26?auto=format&fit=crop&w=800&q=80",
        ingredients: [
            "200g medjool dates, pitted",
            "100g rolled oats",
            "50g almond butter",
            "30g dark chocolate chips (70%+)",
            "30g flaxseeds",
            "1 tsp vanilla extract",
            "Pinch of sea salt",
            "Desiccated coconut for rolling (optional)"
        ],
        steps: [
            "Soak dates in warm water for 5 minutes to soften. Drain.",
            "Add dates, oats, almond butter, flaxseeds, vanilla, and salt to a food processor.",
            "Blend until the mixture comes together into a sticky dough.",
            "Stir in chocolate chips by hand.",
            "Roll into 12 equal balls. Coat in desiccated coconut if using.",
            "Refrigerate for at least 30 minutes. Store in the fridge for up to 2 weeks."
        ],
        substitutions: [
            "Use peanut butter instead of almond butter",
            "Replace chocolate chips with dried cranberries",
            "Add chia seeds or hemp seeds for extra nutrition"
        ],
        tags: ["snack", "vegan", "meal-prep", "no-bake", "healthy"],
        difficulty: "easy",
        cuisineType: "modern",
        costEstimate: 7.50,
        createdAt: Date(timeIntervalSinceNow: -86400 * 23),
        updatedAt: Date(timeIntervalSinceNow: -86400 * 3),
        isPublic: true,
        rating: 4.6,
        ratingCount: 289
    )

    static let acaiBowl = Recipe(
        id: "mock-recipe-027",
        title: "Acai Power Bowl",
        cookTime: "0 min",
        prepTime: 10,
        servings: 1,
        calories: 390,
        imageUrl: "https://images.unsplash.com/photo-1590301157284-f0c7a08e0bef?auto=format&fit=crop&w=800&q=80",
        ingredients: [
            "100g frozen acai pulp",
            "100g frozen blueberries",
            "1 frozen banana",
            "50ml coconut water or almond milk",
            "2 tbsp granola",
            "Fresh banana slices",
            "Fresh strawberries",
            "1 tbsp honey",
            "1 tsp chia seeds",
            "Coconut flakes"
        ],
        steps: [
            "Blend frozen acai, blueberries, banana, and coconut water until thick and smooth.",
            "The mixture should be thicker than a smoothie — add liquid sparingly.",
            "Pour into a chilled bowl.",
            "Arrange toppings: granola, fresh fruit, chia seeds, and coconut flakes.",
            "Drizzle with honey and serve immediately."
        ],
        substitutions: [
            "Use frozen mango instead of acai",
            "Replace granola with toasted oats",
            "Add spirulina powder for extra nutrients"
        ],
        tags: ["snack", "vegan", "no-cook", "healthy", "smoothie-bowl"],
        difficulty: "easy",
        cuisineType: "brazilian",
        costEstimate: 6.00,
        createdAt: Date(timeIntervalSinceNow: -86400 * 8),
        updatedAt: Date(timeIntervalSinceNow: -86400 * 1),
        isPublic: true,
        rating: 4.5,
        ratingCount: 198
    )

    // MARK: - Grouped Collections

    static let breakfasts: [Recipe] = [
        avocadoToast, greekYogurtParfait, shakshuka,
        proteinPancakes, overnightOats, spinachFetaOmelette
    ]

    static let lunches: [Recipe] = [
        caesarSalad, quinoaBowl, lentilSoup, vietnameseSpringRolls,
        thaiPeanutNoodles, turkeyWrap, bibimbap, tunaNicoise
    ]

    static let dinners: [Recipe] = [
        grilledSalmon, chickenTikkaMasala, spaghettiBolognese, koreanBulgogi,
        chickenEnchiladas, mushroomRisotto, padThai, roastedChicken,
        thaiGreenCurry, lambKofta
    ]

    static let snacks: [Recipe] = [hummusPlatter, energyBalls, acaiBowl]

    static let all: [Recipe] = breakfasts + lunches + dinners + snacks

    static let featured: [Recipe] = [
        avocadoToast, quinoaBowl, grilledSalmon, hummusPlatter
    ]
}
#endif
