# AI Meal Plan Generation - Buildplate

## Overview

The Buildplate app now includes AI-powered meal plan generation that creates personalized 7-day meal plans based on user preferences, featuring delicious Western cuisine within specified budgets.

## Features

### Core Features
- **Personalized Generation**: Creates custom 7-day meal plans based on user age, gender, dietary preferences, budget, and health goals
- **Western Cuisine Focus**: Features popular dishes from US, UK, and European cuisines
- **Budget-Aware Planning**: Respects user-specified budget ranges with USD pricing
- **Recipe Integration**: Automatically matches generated meals with existing recipe database
- **Mock Mode**: Fallback mock responses for testing without API keys

### User Experience
- Simple preference input flow
- Real-time generation with loading indicators  
- Detailed meal plan results with cost breakdown
- One-tap plan saving to database
- Seamless navigation back to Plans view

## Technical Implementation

### Architecture
```
MealPlanGenerationView
├── MealPlanPreferencesView (Input)
├── AIService (Generation)
├── PlanViewModel (Saving)
└── Recipe Matching (Integration)
```

### Key Components

#### 1. MealPlanPreferencesView
- **Purpose**: Collects user preferences for meal plan generation
- **Inputs**: Age, gender, dietary restrictions, budget, health goals
- **Budget Options**: Low ($40-60), Medium ($60-100), High ($100+)
- **Validation**: Ensures all required fields are completed

#### 2. AIService
- **Provider**: OpenAI GPT-4 API
- **Input**: Structured user preferences
- **Output**: Comprehensive 7-day meal plan with Western dishes
- **Fallback**: Mock responses when API key not configured

#### 3. MealPlanGenerationView
- **States**: Idle, Generating, Generated, Saving, Saved, Error
- **Features**: Loading indicators, cost display, plan preview
- **Actions**: Generate plan, save to database, retry on error

#### 4. Recipe Matching System
- **Exact Matching**: Finds recipes by exact title match
- **Fuzzy Matching**: Uses keyword-based partial matching
- **Auto-Creation**: Generates new Recipe objects from AI data
- **Categorization**: Intelligent ingredient classification

### AI Prompt Engineering

#### System Prompt
```
You are a professional nutritionist and meal planner specializing in Western cuisine. 
Generate healthy, culturally appropriate meal plans based on user preferences, 
focusing on popular dishes from the US, UK, and European cuisines.
```

#### User Prompt Structure
- User demographics (age, gender)
- Dietary preferences and restrictions
- Budget constraints
- Health goals
- Week start date

#### Response Format
- JSON structured response
- 7 days of meals (breakfast, lunch, dinner)
- Per-meal details: name, cooking time, difficulty, ingredients, instructions, cost
- Total estimated cost in USD

### Error Handling

#### Generation Errors
- API connection failures
- Invalid API responses
- Rate limiting
- JSON parsing errors

#### Recovery Strategies
- Automatic retry with exponential backoff
- Fallback to mock responses
- User-friendly error messages
- Manual retry options

#### Database Errors
- Plan save failures with rollback
- Conflict resolution
- Data validation

## Data Models

### MealPlanGenerationRequest
```swift
struct MealPlanGenerationRequest {
    let age: Int
    let gender: String
    let dietaryPreferences: String
    let budget: String
    let goal: String
    let weekStart: String
}
```

### MealPlanGenerationResponse
```swift
struct MealPlanGenerationResponse {
    let weekTitle: String
    let totalEstimatedCost: Double // USD
    let meals: [DayMeals]
}
```

### GeneratedMeal
```swift
struct GeneratedMeal {
    let name: String
    let cookingTime: Int
    let difficulty: String
    let ingredients: [String]
    let instructions: [String]
    let estimatedCost: Double // USD
}
```

## Configuration

### OpenAI Setup
1. Sign up for OpenAI API access
2. Create API key in OpenAI dashboard
3. Add key to Config.plist or environment variable
4. Enable AI generation in app

### Budget Ranges
- **Low**: $40-60 per week
- **Medium**: $60-100 per week  
- **High**: $100+ per week

### Dietary Options
- Vegetarian, Vegan
- No Pork, No Beef
- Gluten-Free, Dairy-Free
- Custom restrictions

## Usage Flow

1. **Access**: User taps "Generate New Plan" in Plans view
2. **Preferences**: User completes preference form
3. **Generation**: AI creates personalized meal plan
4. **Review**: User reviews generated plan and cost
5. **Save**: Plan saved to database and user navigated to Plans view

## Performance Considerations

### Response Times
- API calls: 2-5 seconds typical
- Mock responses: 2 seconds simulated delay
- Database saves: <1 second

### Cost Optimization
- Efficient prompts to minimize token usage
- Caching of common responses
- Rate limiting compliance

### User Experience
- Loading states for all async operations
- Progress indicators during generation
- Smooth animations and transitions

## Future Enhancements

### Planned Features
1. **Multi-language Support**: Localized meal names and instructions
2. **Background Generation**: Queue system for batch processing
3. **Plan Templates**: Pre-defined plan types for quick generation
4. **Nutrition Analysis**: Detailed nutritional breakdown
5. **Shopping Lists**: Auto-generated grocery lists
6. **Cost Tracking**: Historical cost analysis

### Cuisine Expansion
- **Regional Options**: Regional American, French, Italian, British cuisines
- **Seasonal Menus**: Season-specific ingredients and dishes
- **Local Adaptation**: Integration with local grocery store APIs

### AI Improvements
- **Learning**: User feedback integration
- **Personalization**: Improved recommendations based on history
- **Variety**: Enhanced meal diversity algorithms

## Testing

### Mock Data
- Complete 7-day Western meal plan
- Realistic cost estimates in USD
- Variety of difficulty levels and cuisines

### Test Scenarios
- All preference combinations
- Error conditions and recovery
- Database integration
- UI state management

## Conclusion

The AI meal plan generation feature is now fully implemented and ready for use. Users can generate personalized Western meal plans with a single tap, and the system automatically handles recipe matching, database storage, and error recovery.

The feature is designed to be:
- **User-friendly**: Simple, intuitive interface
- **Reliable**: Robust error handling and fallbacks
- **Flexible**: Supports wide range of preferences and dietary needs
- **Global**: Focused on Western cuisine for US, UK, and European markets 