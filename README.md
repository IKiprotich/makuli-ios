# Makuli 🍽️

A SwiftUI meal planning app with AI-powered meal generation and template-based planning.

## Features

- 🤖 **AI Meal Generation** - Custom meal plans using OpenAI
- 📋 **Template System** - Predefined meal plan templates  
- 👤 **User Profiles** - Personalized dietary preferences
- 🛒 **Grocery Lists** - Automatic shopping list generation
- 📊 **Progress Tracking** - Meal completion analytics
- 🔐 **Authentication** - Secure login with Google OAuth

## Tech Stack

- **Frontend**: SwiftUI (iOS)
- **Backend**: Supabase (PostgreSQL)
- **AI**: OpenAI API
- **Auth**: Supabase Auth + Google OAuth

## Quick Start

1. **Setup Database**: Follow the setup guide in [`docs/SUPABASE_TEMPLATE_SETUP.md`](docs/SUPABASE_TEMPLATE_SETUP.md)
2. **Configure AI**: Set up OpenAI integration using [`docs/AI_MEAL_PLAN_GENERATION.md`](docs/AI_MEAL_PLAN_GENERATION.md)
3. **Run the App**: Open `Makuli.xcodeproj` in Xcode and build

## Documentation

📖 **[Complete Documentation](docs/README.md)** - Comprehensive guides, architecture overview, and troubleshooting

### Quick Links
- [AI Meal Plan Generation Setup](docs/AI_MEAL_PLAN_GENERATION.md)
- [Supabase Template Database Setup](docs/SUPABASE_TEMPLATE_SETUP.md)

## Project Structure

```
Makuli/
├── docs/                 # Documentation
├── Makuli/              # iOS App Source
│   ├── Models/          # Data models
│   ├── Views/           # SwiftUI views  
│   ├── ViewModels/      # State management
│   ├── Services/        # API integrations
│   └── Utils/           # Utilities
├── Makuli.xcodeproj/    # Xcode project
└── README.md           # This file
```

## Recent Updates

- ✅ Added database-driven meal plan templates
- ✅ Enhanced PlansView with template selection
- ✅ Implemented automatic template seeding
- ✅ Improved error handling across ViewModels
- ✅ Organized comprehensive documentation

---

For detailed setup instructions and development guidelines, see the **[docs](docs/)** folder. 
