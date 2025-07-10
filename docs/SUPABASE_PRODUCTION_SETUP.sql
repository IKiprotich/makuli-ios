-- =====================================================
-- SUPABASE PRODUCTION DATABASE SETUP
-- Run this SQL in your Supabase SQL Editor for production
-- =====================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. PROFILES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS profiles (
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
    subscription_type TEXT CHECK (subscription_type IN ('free', 'monthly', 'yearly')),
    plans_created_this_month INTEGER DEFAULT 0,
    ai_generations_this_month INTEGER DEFAULT 0,
    last_plan_reset DATE DEFAULT CURRENT_DATE
);

-- RLS Policies for profiles
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own profile" ON profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON profiles;

CREATE POLICY "Users can view own profile" ON profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Users can insert own profile" ON profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- =====================================================
-- 2. RECIPES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS recipes (
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
    rating DECIMAL(3,2) DEFAULT 0.0,
    rating_count INTEGER DEFAULT 0
);

-- RLS Policies for recipes
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view public recipes" ON recipes;
DROP POLICY IF EXISTS "Users can create recipes" ON recipes;
DROP POLICY IF EXISTS "Users can update own recipes" ON recipes;

CREATE POLICY "Anyone can view public recipes" ON recipes FOR SELECT USING (is_public = true);
CREATE POLICY "Users can create recipes" ON recipes FOR INSERT WITH CHECK (auth.uid() = created_by);
CREATE POLICY "Users can update own recipes" ON recipes FOR UPDATE USING (auth.uid() = created_by);

-- =====================================================
-- 3. MEAL PLAN TEMPLATES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS meal_plan_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    category TEXT NOT NULL,
    difficulty TEXT NOT NULL CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
    duration_days INTEGER DEFAULT 7,
    estimated_cost_min DECIMAL(10,2),
    estimated_cost_max DECIMAL(10,2),
    image_url TEXT,
    tags JSONB DEFAULT '[]',
    is_active BOOLEAN DEFAULT TRUE,
    popularity_score INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES auth.users(id),
    
    -- Template metadata
    icon TEXT,
    color_scheme TEXT,
    target_calories_per_day INTEGER,
    macros JSONB -- {'protein': 30, 'carbs': 40, 'fat': 30}
);

-- RLS Policies for meal_plan_templates
ALTER TABLE meal_plan_templates ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view active templates" ON meal_plan_templates;
DROP POLICY IF EXISTS "Authenticated users can create templates" ON meal_plan_templates;

CREATE POLICY "Anyone can view active templates" ON meal_plan_templates FOR SELECT USING (is_active = true);
CREATE POLICY "Authenticated users can create templates" ON meal_plan_templates FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- =====================================================
-- 4. TEMPLATE MEALS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS template_meals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    template_id UUID REFERENCES meal_plan_templates(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6),
    meal_type TEXT NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
    meal_name TEXT NOT NULL,
    recipe_id UUID REFERENCES recipes(id),
    cooking_time INTEGER,
    difficulty TEXT CHECK (difficulty IN ('easy', 'medium', 'hard')),
    position INTEGER DEFAULT 0,
    day TEXT NOT NULL,
    estimated_cost DECIMAL(10,2),
    
    -- Meal metadata
    calories INTEGER,
    prep_time INTEGER,
    ingredients JSONB DEFAULT '[]',
    instructions JSONB DEFAULT '[]'
);

-- RLS Policies for template_meals
ALTER TABLE template_meals ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Anyone can view template meals" ON template_meals;
DROP POLICY IF EXISTS "Authenticated users can create template meals" ON template_meals;

CREATE POLICY "Anyone can view template meals" ON template_meals FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create template meals" ON template_meals FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- =====================================================
-- 5. PLANS TABLE (User's meal plans)
-- =====================================================
CREATE TABLE IF NOT EXISTS plans (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    week_start DATE NOT NULL,
    week_end DATE NOT NULL,
    total_cost DECIMAL(10,2),
    is_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Plan metadata
    template_id UUID REFERENCES meal_plan_templates(id),
    generation_method TEXT CHECK (generation_method IN ('template', 'ai', 'manual')) DEFAULT 'template',
    is_favorite BOOLEAN DEFAULT FALSE,
    completion_percentage DECIMAL(5,2) DEFAULT 0.0
);

-- RLS Policies for plans
ALTER TABLE plans ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own plans" ON plans;
DROP POLICY IF EXISTS "Users can create own plans" ON plans;
DROP POLICY IF EXISTS "Users can update own plans" ON plans;
DROP POLICY IF EXISTS "Users can delete own plans" ON plans;

CREATE POLICY "Users can view own plans" ON plans FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own plans" ON plans FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own plans" ON plans FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own plans" ON plans FOR DELETE USING (auth.uid() = user_id);

-- =====================================================
-- 6. PLAN RECIPES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS plan_recipes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_id UUID REFERENCES plans(id) ON DELETE CASCADE,
    recipe_id UUID REFERENCES recipes(id),
    day_of_week INTEGER NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6),
    meal_type TEXT NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
    position INTEGER DEFAULT 0,
    day TEXT NOT NULL,
    is_completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP WITH TIME ZONE,
    
    -- Recipe override data (for customized meals)
    custom_meal_name TEXT,
    custom_ingredients JSONB,
    custom_instructions JSONB,
    custom_cook_time INTEGER,
    notes TEXT
);

-- RLS Policies for plan_recipes
ALTER TABLE plan_recipes ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can view own plan recipes" ON plan_recipes;
DROP POLICY IF EXISTS "Users can modify own plan recipes" ON plan_recipes;

CREATE POLICY "Users can view own plan recipes" ON plan_recipes FOR SELECT USING (
    plan_id IN (SELECT id FROM plans WHERE user_id = auth.uid())
);
CREATE POLICY "Users can modify own plan recipes" ON plan_recipes FOR ALL USING (
    plan_id IN (SELECT id FROM plans WHERE user_id = auth.uid())
);

-- =====================================================
-- 7. GROCERY ITEMS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS grocery_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    plan_id UUID REFERENCES plans(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    quantity TEXT,
    category TEXT,
    emoji TEXT,
    is_purchased BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Additional metadata
    estimated_cost DECIMAL(10,2),
    store_section TEXT,
    notes TEXT,
    priority INTEGER DEFAULT 0 -- 0=low, 1=medium, 2=high
);

-- RLS Policies for grocery_items
ALTER TABLE grocery_items ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Users can manage own grocery items" ON grocery_items;

CREATE POLICY "Users can manage own grocery items" ON grocery_items FOR ALL USING (auth.uid() = user_id);

-- =====================================================
-- 8. PERFORMANCE INDEXES
-- =====================================================

-- Profiles indexes
CREATE INDEX IF NOT EXISTS idx_profiles_email ON profiles(email);
CREATE INDEX IF NOT EXISTS idx_profiles_subscription ON profiles(subscription_type, subscription_renewal);

-- Recipes indexes
CREATE INDEX IF NOT EXISTS idx_recipes_public ON recipes(is_public) WHERE is_public = true;
CREATE INDEX IF NOT EXISTS idx_recipes_tags ON recipes USING gin(tags);
CREATE INDEX IF NOT EXISTS idx_recipes_difficulty ON recipes(difficulty);
CREATE INDEX IF NOT EXISTS idx_recipes_cuisine ON recipes(cuisine_type);
CREATE INDEX IF NOT EXISTS idx_recipes_rating ON recipes(rating DESC);

-- Templates indexes
CREATE INDEX IF NOT EXISTS idx_templates_active ON meal_plan_templates(is_active) WHERE is_active = true;
CREATE INDEX IF NOT EXISTS idx_templates_category ON meal_plan_templates(category);
CREATE INDEX IF NOT EXISTS idx_templates_popularity ON meal_plan_templates(popularity_score DESC);

-- Template meals indexes
CREATE INDEX IF NOT EXISTS idx_template_meals_template ON template_meals(template_id);
CREATE INDEX IF NOT EXISTS idx_template_meals_day_type ON template_meals(day_of_week, meal_type);

-- Plans indexes
CREATE INDEX IF NOT EXISTS idx_plans_user_week ON plans(user_id, week_start);
CREATE INDEX IF NOT EXISTS idx_plans_user_date ON plans(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_plans_template ON plans(template_id);

-- Plan recipes indexes
CREATE INDEX IF NOT EXISTS idx_plan_recipes_plan_day ON plan_recipes(plan_id, day_of_week);
CREATE INDEX IF NOT EXISTS idx_plan_recipes_completion ON plan_recipes(plan_id, is_completed);

-- Grocery items indexes
CREATE INDEX IF NOT EXISTS idx_grocery_user_plan ON grocery_items(user_id, plan_id);
CREATE INDEX IF NOT EXISTS idx_grocery_purchased ON grocery_items(user_id, is_purchased);

-- =====================================================
-- 9. FUNCTIONS AND TRIGGERS
-- =====================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers
DROP TRIGGER IF EXISTS update_profiles_updated_at ON profiles;
CREATE TRIGGER update_profiles_updated_at
    BEFORE UPDATE ON profiles
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_recipes_updated_at ON recipes;
CREATE TRIGGER update_recipes_updated_at
    BEFORE UPDATE ON recipes
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_templates_updated_at ON meal_plan_templates;
CREATE TRIGGER update_templates_updated_at
    BEFORE UPDATE ON meal_plan_templates
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_plans_updated_at ON plans;
CREATE TRIGGER update_plans_updated_at
    BEFORE UPDATE ON plans
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_grocery_updated_at ON grocery_items;
CREATE TRIGGER update_grocery_updated_at
    BEFORE UPDATE ON grocery_items
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Function to reset monthly limits
CREATE OR REPLACE FUNCTION reset_monthly_limits()
RETURNS void AS $$
BEGIN
    UPDATE profiles 
    SET 
        plans_created_this_month = 0,
        ai_generations_this_month = 0,
        last_plan_reset = CURRENT_DATE
    WHERE last_plan_reset < CURRENT_DATE - INTERVAL '1 month';
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- 10. INITIAL DATA VERIFICATION
-- =====================================================

-- Verify table creation
DO $$
BEGIN
    RAISE NOTICE 'Database setup completed successfully!';
    RAISE NOTICE 'Tables created: profiles, recipes, meal_plan_templates, template_meals, plans, plan_recipes, grocery_items';
    RAISE NOTICE 'RLS policies enabled for all tables';
    RAISE NOTICE 'Performance indexes created';
    RAISE NOTICE 'Triggers for updated_at timestamps active';
    RAISE NOTICE '';
    RAISE NOTICE 'Next steps:';
    RAISE NOTICE '1. Run the production seeder to populate templates and recipes';
    RAISE NOTICE '2. Test user registration and profile creation';
    RAISE NOTICE '3. Verify meal plan creation functionality';
    RAISE NOTICE '4. Configure backup and monitoring';
END $$; 