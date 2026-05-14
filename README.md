# Makuli 🍽️

iOS meal planning app — curated recipes, weekly plans, and grocery lists, built with SwiftUI and Supabase.

[![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS%2018%2B-blue?logo=apple)](https://developer.apple.com/xcode/swiftui/)
[![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?logo=supabase)](https://supabase.com)

---

## Screenshots

| Home | Plans | Profile |
|:---:|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/fe6ada14-8e40-42c3-a29b-0b3b03dd5613" width="220" /> | <img src="https://github.com/user-attachments/assets/c44e0433-e6bc-456d-86e8-91ea5537041d" width="220" /> | <img src="https://github.com/user-attachments/assets/df68d853-b28e-419e-b534-a8b567b4f248" width="220" /> |

| Plan Creation | Recipes | Grocery List |
|:---:|:---:|:---:|
| <img src="https://github.com/user-attachments/assets/102468c7-a03b-4678-9833-4c39e91ae5e0" width="220" /> | <img src="https://github.com/user-attachments/assets/35595b33-207d-4cdf-a0d9-7f2098f17eb2" width="220" /> | <img src="https://github.com/user-attachments/assets/bcae5f47-d905-4ddc-96f3-d90bc052397e" width="220" /> |

---

## Stack

```
SwiftUI + MVVM        iOS 18 · Async/Await · Combine
Supabase              PostgreSQL · Auth · Row-Level Security
Auth                  Google OAuth 2.0
Tooling               Xcode 16 · Swift Package Manager
```

---

## Features

- **Home dashboard** — progress ring, 7-day week strip, colour-coded meal rows, recipe discovery
- **Template planning** — 15 weekly templates including a full Kenyan Cuisine week
- **47 recipes** — Kenyan/East African, Mediterranean, Asian, Indian, Mexican, Italian, and more
- **Rich meal images** — every meal card shows a food photo via `AsyncImage` with shimmer loading
- **Grocery list** — auto-generated from all ingredients in a plan
- **Profile** — editable avatar, dietary preferences, usage stats
- **Auto-seeding** — full recipe and template library seeds on first launch, no manual setup

---

## Recipe Library

**🇰🇪 Kenyan & East African** — Nyama Choma · Kenyan Pilau · Ugali na Sukuma Wiki · Githeri · Mukimo · Mandazi · Chapati 

**🌊 Mediterranean** — Herb-Crusted Salmon · Shakshuka · Quinoa Bowl · Lamb Kofta · Wild Mushroom Risotto

**🥢 Asian** — Chicken Tikka Masala · Teriyaki Salmon · Thai Green Curry · Pad Thai · Korean Bulgogi · Bibimbap · Pho Bo

**🌍 More** — Jollof Rice · Chicken Shawarma · Beef Tacos · Lamb Biryani · Tuscan Garlic Chicken · Miso Aubergine

---

## Quick Start

```bash
git clone https://github.com/IKiprotich/makuli.git
open Makuli.xcodeproj
```

Set `SUPABASE_URL` and `SUPABASE_ANON_KEY` in `Configuration.swift`, then run. The seeder populates all tables on first launch.

**One SQL migration required:**
```sql
ALTER TABLE plan_recipes ADD COLUMN IF NOT EXISTS custom_image_url text;
```

---


