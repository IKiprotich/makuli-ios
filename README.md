# Makuli 🍽️

> **Meal planning App for iOS** — personalized nutrition, intelligent automation, and a seamless user experience built with SwiftUI.

[![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS%2017%2B-blue?logo=apple)](https://developer.apple.com/xcode/swiftui/)
[![Supabase](https://img.shields.io/badge/Backend-Supabase-3ECF8E?logo=supabase)](https://supabase.com)
[![OpenAI](https://img.shields.io/badge/AI-OpenAI-412991?logo=openai)](https://openai.com)

---

## Overview

Makuli is a production-grade iOS meal planning app that combines a clean SwiftUI interface and a Supabase PostgreSQL backend. Users get personalized meal plans based on dietary preferences, with automatic grocery list generation and progress analytics, all secured through Google OAuth.

---

## Features

| Feature | Description |
|---|---|
| 📋 **Template System** | Curated, database-driven meal plan templates for quick-start planning |
| 👤 **User Profiles** | Stores dietary preferences, allergies, and calorie targets per user |
| 🛒 **Grocery Lists** | Automatically aggregates ingredients from a meal plan into a consolidated shopping list |
| 📊 **Progress Tracking** | Visual analytics dashboard tracking meal completion over time |
| 🔐 **Authentication** | Secure, passwordless login via Supabase Auth + Google OAuth 2.0 |

---

## Tech Stack

```
iOS App        SwiftUI · MVVM · Combine · Async/Await
Backend        Supabase (PostgreSQL + Realtime + Storage)
Auth           Supabase Auth · Google OAuth 2.0
Tooling        Xcode 15 · Swift Package Manager
```

### Architecture

Makuli follows the **MVVM pattern** with a clean separation of concerns:

- **Models** — Codable structs mapped directly to Supabase schema
- **ViewModels** — `@Observable` classes handling business logic and async data fetching
- **Views** — Declarative SwiftUI views bound to ViewModels, with zero business logic
- **Services** — Thin wrappers around Supabase and OpenAI clients, injected via environment

---

## Project Structure

```
Makuli/
├── docs/                        # Setup guides and architecture docs
│   └── SUPABASE_TEMPLATE_SETUP.md
├── Makuli/
│   ├── Models/                  # Codable data models
│   ├── Views/                   # SwiftUI view hierarchy
│   ├── ViewModels/              # State management (@Observable)
│   ├── Services/                # Supabase 
│   └── Utils/                   # Extensions and helpers
├── Makuli.xcodeproj/
└── README.md
```

---

## Quick Start

**Prerequisites:** Xcode 15+, a Supabase project, an OpenAI API key

```bash
# 1. Clone the repo
git clone https://github.com/your-username/makuli.git
cd makuli

# 2. Set up the database
# Follow docs/SUPABASE_TEMPLATE_SETUP.md

# 3. Open in Xcode and build
open Makuli.xcodeproj
```

---

## Documentation

| Guide | Description |
|---|---|
| 📖 [Complete Docs](docs/README.md) | Architecture overview, data models, and troubleshooting |
| 🗄️ [Database Setup](docs/SUPABASE_TEMPLATE_SETUP.md) | Supabase schema, RLS policies, and template seeding |

---

## Recent Updates

- ✅ Introduced database-driven meal plan templates with automatic seeding
- ✅ Rebuilt `PlansView` with template browsing and one-tap plan creation
- ✅ Standardized error handling across all ViewModels
- ✅ Reorganised and expanded developer documentation

---

## Why Makuli?

Building Makuli meant solving real engineering challenges:

- **Offline-first UX** — Caching meal plans locally so the app stays usable without a connection
- **Real-time sync** — Using Supabase Realtime to keep grocery lists in sync across devices
- **Secure data access** — Row-Level Security policies ensuring users can only access their own data

---

*Built with Swift, curiosity, and too many meal prep ideas.*
