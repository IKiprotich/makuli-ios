# Makuli Documentation

Welcome to the Makuli meal planning app documentation. This folder contains comprehensive guides for setup, configuration, and features.

## 📚 Documentation Index

### Setup & Configuration

- **[AI Meal Plan Generation](AI_MEAL_PLAN_GENERATION.md)** - Complete guide to setting up AI-powered meal plan generation using OpenAI API
- **[Supabase Template Setup](SUPABASE_TEMPLATE_SETUP.md)** - Database setup for meal plan templates, including SQL scripts and RLS policies

## 🏗️ Architecture Overview

Makuli is a SwiftUI-based meal planning application with the following key components:

### Backend Infrastructure
- **Supabase**: PostgreSQL database with real-time capabilities
- **OpenAI API**: AI-powered meal plan generation
- **Authentication**: Supabase Auth with Google OAuth

### Database Schema
- `profiles` - User profile information
- `plans` - User meal plans
- `plan_recipes` - Individual meals within plans
- `recipes` - Recipe database
- `grocery_list` - Shopping list items
- `meal_plan_templates` - Predefined meal plan templates
- `template_meals` - Individual meals within templates

### Key Features
1. **AI Meal Plan Generation** - Custom meal plans based on user preferences
2. **Template System** - Predefined meal plan templates for quick setup
3. **User Profiles** - Personalized dietary preferences and goals
4. **Recipe Management** - Comprehensive recipe database
5. **Grocery Lists** - Automatic shopping list generation
6. **Progress Tracking** - Meal plan completion and health metrics

## 🚀 Quick Start

1. **Database Setup**
   - Follow [Supabase Template Setup](SUPABASE_TEMPLATE_SETUP.md) to create required tables
   - Configure Row Level Security policies
   - Set up authentication

2. **AI Integration**
   - Follow [AI Meal Plan Generation](AI_MEAL_PLAN_GENERATION.md) to configure OpenAI API
   - Add API keys to your environment
   - Test AI meal plan generation

3. **App Configuration**
   - Update `Configuration.swift` with your API keys
   - Configure Supabase client in `SupabaseManager.swift`
   - Test authentication flow

## 🔧 Development

### Project Structure
```
Makuli/
├── Models/           # Data models and structures
├── Views/            # SwiftUI views
├── ViewModels/       # ObservableObject classes
├── Services/         # API and business logic
├── Utils/            # Utilities and configurations
└── Components/       # Reusable UI components
```

### Key Services
- **AuthManager** - Authentication and user management
- **SupabaseManager** - Database operations
- **AIService** - OpenAI API integration
- **TemplateService** - Meal plan template management

### Development Guidelines
- Use async/await for all network operations
- Implement proper error handling with user-friendly messages
- Follow MVVM architecture pattern
- Use `@StateObject` for ViewModels and `@EnvironmentObject` for shared state

## 📱 Features

### Core Functionality
- ✅ User authentication (email/password, Google OAuth)
- ✅ AI meal plan generation with customization
- ✅ Predefined meal plan templates
- ✅ Recipe database with search and filtering
- ✅ Automatic grocery list generation
- ✅ Progress tracking and analytics
- ✅ User profile management

### Recent Additions
- 🆕 **Template System** - Database-driven meal plan templates
- 🆕 **Enhanced UI** - Improved PlansView with dual creation options
- 🆕 **Sample Data** - Automatic seeding of template database
- 🆕 **Category Filtering** - Browse templates by cuisine type

## 🐛 Troubleshooting

### Common Issues

**Database Connection Issues**
- Verify Supabase URL and API keys in `Configuration.swift`
- Check Row Level Security policies
- Ensure tables exist with proper schema

**AI Generation Failures**
- Verify OpenAI API key is valid and has credits
- Check network connectivity
- Review error logs in `Logger` output

**Template Loading Issues**
- Ensure `meal_plan_templates` and `template_meals` tables exist
- Run seeding function if database is empty
- Check RLS policies allow read access

## 📝 Contributing

When adding new features:

1. Create appropriate models in `Models/`
2. Add service layer in `Services/`
3. Create ViewModels for state management
4. Build SwiftUI views with proper accessibility
5. Update documentation

## 📄 License

This project is part of the Makuli meal planning application.

---

For specific setup instructions, refer to the individual documentation files listed above. 