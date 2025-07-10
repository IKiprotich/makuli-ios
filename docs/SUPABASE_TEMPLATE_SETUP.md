# Supabase Template System Setup

This document explains how to set up the meal plan template system in your Supabase database.

## Database Tables

### 1. `meal_plan_templates` Table

This table stores the template metadata.

```sql
CREATE TABLE meal_plan_templates (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT NOT NULL,
    category TEXT NOT NULL,
    difficulty TEXT NOT NULL,
    duration_days INTEGER NOT NULL DEFAULT 7,
    estimated_cost_min DECIMAL(10,2) NOT NULL,
    estimated_cost_max DECIMAL(10,2) NOT NULL,
    image_url TEXT,
    tags TEXT[] DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    popularity_score INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add RLS (Row Level Security) policies
ALTER TABLE meal_plan_templates ENABLE ROW LEVEL SECURITY;

-- Allow read access to all authenticated users
CREATE POLICY "Templates are viewable by authenticated users" ON meal_plan_templates
    FOR SELECT USING (auth.role() = 'authenticated');

-- Allow all authenticated users to create templates (for seeding functionality)
CREATE POLICY "Templates can be managed by authenticated users" ON meal_plan_templates
    FOR ALL USING (auth.role() = 'authenticated');
```

### 2. `template_meals` Table

This table stores the individual meals for each template.

```sql
CREATE TABLE template_meals (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    template_id UUID NOT NULL REFERENCES meal_plan_templates(id) ON DELETE CASCADE,
    day_of_week INTEGER NOT NULL CHECK (day_of_week >= 0 AND day_of_week <= 6),
    meal_type TEXT NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
    meal_name TEXT NOT NULL,
    recipe_id UUID REFERENCES recipes(id),
    cooking_time INTEGER NOT NULL DEFAULT 30,
    difficulty TEXT NOT NULL DEFAULT 'medium',
    position INTEGER NOT NULL DEFAULT 0,
    day TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add RLS policies
ALTER TABLE template_meals ENABLE ROW LEVEL SECURITY;

-- Allow read access to all authenticated users
CREATE POLICY "Template meals are viewable by authenticated users" ON template_meals
    FOR SELECT USING (auth.role() = 'authenticated');

-- Allow all authenticated users to create template meals (for seeding functionality)
CREATE POLICY "Template meals can be managed by authenticated users" ON template_meals
    FOR ALL USING (auth.role() = 'authenticated');

-- Add indexes for better performance
CREATE INDEX idx_template_meals_template_id ON template_meals(template_id);
CREATE INDEX idx_template_meals_day_order ON template_meals(template_id, day_of_week, position);
```

## Setup Instructions

### Step 1: Create the Tables

1. Go to your Supabase dashboard
2. Navigate to the SQL Editor
3. Run the SQL commands above to create the tables

### Step 2: Seed Sample Data (Optional)

You can either:

**Option A: Use the App's Seeding Feature**
- The app includes a seeding function that will populate sample templates
- When users first access templates and the database is empty, they'll see an option to "Setup Templates"
- This will automatically create 4 sample templates (Mediterranean, Budget-Friendly, Quick Meals, Healthy)

**Option B: Manual SQL Insert**
```sql
-- Insert a sample template
INSERT INTO meal_plan_templates (name, description, category, difficulty, estimated_cost_min, estimated_cost_max, tags) 
VALUES (
    'Mediterranean Week',
    'Fresh, healthy meals inspired by Mediterranean cuisine',
    'Mediterranean',
    'Intermediate',
    75.00,
    100.00,
    ARRAY['healthy', 'mediterranean', 'fresh', 'balanced']
);

-- Insert sample meals for the template (you'll need the template_id from above)
INSERT INTO template_meals (template_id, day_of_week, meal_type, meal_name, cooking_time, difficulty, position, day) VALUES
('your-template-id-here', 0, 'breakfast', 'Greek Yogurt with Honey and Nuts', 15, 'easy', 0, 'Monday'),
('your-template-id-here', 0, 'lunch', 'Mediterranean Quinoa Bowl', 25, 'medium', 1, 'Monday'),
('your-template-id-here', 0, 'dinner', 'Grilled Salmon with Asparagus', 30, 'medium', 2, 'Monday');
-- ... continue for all days and meals
```

### Step 3: Configure Row Level Security (RLS)

The tables include RLS policies that:
- Allow all authenticated users to read templates
- Restrict template creation/editing to admin users (optional)

### Troubleshooting RLS Issues

If you encounter Row-Level Security errors during template seeding, you may need to update the policies:

**Error: "new row violates row-level security policy"**

This means the current policies are too restrictive. Run this SQL to fix:

```sql
-- Drop the restrictive policies if they exist
DROP POLICY IF EXISTS "Templates can be managed by admin" ON meal_plan_templates;
DROP POLICY IF EXISTS "Template meals can be managed by admin" ON template_meals;

-- Create policies that allow authenticated users to manage templates
CREATE POLICY "Templates can be managed by authenticated users" ON meal_plan_templates
    FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Template meals can be managed by authenticated users" ON template_meals
    FOR ALL USING (auth.role() = 'authenticated');
```

**Alternative: Temporarily Disable RLS for Seeding**

```sql
-- Disable RLS temporarily
ALTER TABLE meal_plan_templates DISABLE ROW LEVEL SECURITY;
ALTER TABLE template_meals DISABLE ROW LEVEL SECURITY;

-- Re-enable after seeding (optional)
-- ALTER TABLE meal_plan_templates ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE template_meals ENABLE ROW LEVEL SECURITY;
```

### Step 4: Update Existing Schema (if needed)

If you already have the `plans` and `recipes` tables, make sure they're compatible:

```sql
-- Ensure recipes table exists with proper structure
CREATE TABLE IF NOT EXISTS recipes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    title TEXT NOT NULL,
    cook_time TEXT,
    servings INTEGER,
    image_name TEXT,
    ingredients JSONB,
    steps TEXT[],
    substitutions TEXT[],
    tags TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

## Template Categories

The app supports these predefined categories:

- **Mediterranean** 🫒 - Fresh, healthy Mediterranean cuisine
- **Keto** 🥑 - Low-carb, high-fat meals
- **Budget-Friendly** 💰 - Affordable meal options
- **Vegetarian** 🥬 - Plant-based meals
- **Quick Meals** ⚡ - Fast meals under 20 minutes
- **Comfort Food** 🍲 - Hearty, satisfying meals
- **Healthy** 🥗 - Nutritious, balanced meals
- **Family Style** 👨‍👩‍👧‍👦 - Large portions for families

## Usage in App

Once the database is set up:

1. **Fetch Templates**: The app will automatically load templates from the database
2. **Category Filtering**: Users can filter templates by category
3. **Template Selection**: Users can preview and select templates
4. **Plan Creation**: Selected templates are converted to user-specific meal plans
5. **Recipe Integration**: Templates can reference existing recipes in your database

## Maintenance

### Adding New Templates

Use the app's admin seeding function or manually insert via SQL:

```sql
INSERT INTO meal_plan_templates (name, description, category, difficulty, estimated_cost_min, estimated_cost_max, tags) 
VALUES ('Your Template Name', 'Description', 'Category', 'Difficulty', 50.00, 75.00, ARRAY['tag1', 'tag2']);
```

### Updating Template Popularity

The `popularity_score` field can be used to track which templates are most popular:

```sql
UPDATE meal_plan_templates 
SET popularity_score = popularity_score + 1 
WHERE id = 'template-id';
```

### Analytics Queries

Track template usage:

```sql
-- Most popular templates
SELECT name, popularity_score 
FROM meal_plan_templates 
ORDER BY popularity_score DESC;

-- Templates by category
SELECT category, COUNT(*) as template_count 
FROM meal_plan_templates 
WHERE is_active = true 
GROUP BY category;
``` 