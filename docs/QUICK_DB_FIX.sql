-- =====================================================
-- QUICK DATABASE FIX - Run this if you got column errors
-- =====================================================

-- First, clean up any partially created tables
DROP TABLE IF EXISTS grocery_items CASCADE;
DROP TABLE IF EXISTS plan_recipes CASCADE;
DROP TABLE IF EXISTS plans CASCADE;
DROP TABLE IF EXISTS template_meals CASCADE;
DROP TABLE IF EXISTS meal_plan_templates CASCADE;
DROP TABLE IF EXISTS recipes CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- CORRECTED PROFILES TABLE
-- =====================================================
CREATE TABLE profiles (
    id UUID PRIMARY KEY DEFAULT auth.uid(),
    name TEXT,
    email TEXT UNIQUE NOT NULL,
    age INTEGER,
    gender TEXT CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
    goal TEXT CHECK (goal IN ('lose_weight', 'gain_weight', 'maintain_weight', 'build_muscle', 'improve_health')),
    diet TEXT CHECK (diet IN ('none', 'vegetarian', 'vegan', 'keto', 'paleo', 'mediterranean', 'gluten_free')),
    budget TEXT CHECK (budget IN ('low', 'medium', 'high')),
    is_premium BOOLEAN DEFAULT FALSE,
    subscription_renewal TIMESTAMP WITH TIME ZONE,
    profile_image_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_onboarding_completed BOOLEAN DEFAULT FALSE,
    
    -- Subscription tracking
    subscription_type TEXT CHECK (subscription_type IN ('free', 'monthly', 'yearly')) DEFAULT 'free',
    plans_created_this_month INTEGER DEFAULT 0,
    ai_generations_this_month INTEGER DEFAULT 0,
    last_plan_reset TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- CORRECTED RECIPES TABLE WITH is_public COLUMN
-- =====================================================
CREATE TABLE recipes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    cook_time TEXT,
    prep_time INTEGER,
    servings INTEGER,
    calories INTEGER,
    image_url TEXT,
    ingredients JSONB NOT NULL DEFAULT '[]',
    steps JSONB NOT NULL DEFAULT '[]',
    substitutions JSONB DEFAULT '[]',
    tags JSONB DEFAULT '[]',
    difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')) DEFAULT 'medium',
    cuisine_type TEXT,
    cost_estimate DECIMAL(10,2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id),
    is_public BOOLEAN DEFAULT TRUE,
    rating DECIMAL(3,2) DEFAULT 0.0 CHECK (rating >= 0.0 AND rating <= 5.0),
    rating_count INTEGER DEFAULT 0
);

-- =====================================================
-- RLS POLICIES FOR SEEDING FIX
-- =====================================================

-- RLS Policies for profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;

CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- RLS Policies for recipes - FIXED FOR SEEDING
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view public recipes" ON recipes;
DROP POLICY IF EXISTS "Users can create recipes" ON recipes;
DROP POLICY IF EXISTS "Users can update own recipes" ON recipes;

CREATE POLICY "Anyone can view public recipes" ON recipes FOR SELECT USING (is_public = true);
-- Allow authenticated users to create recipes (for seeding) OR when they own them
CREATE POLICY "Users can create recipes" ON recipes FOR INSERT WITH CHECK (
    auth.role() = 'authenticated' AND 
    (created_by IS NULL OR auth.uid() = created_by)
);
CREATE POLICY "Users can update own recipes" ON recipes FOR UPDATE USING (auth.uid() = created_by);

-- Now continue with the rest of the tables from the main SQL file...
-- After running this, run the full SUPABASE_PRODUCTION_SETUP.sql file 