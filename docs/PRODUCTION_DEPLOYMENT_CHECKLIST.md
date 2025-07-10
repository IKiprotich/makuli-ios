# 🚀 Production Deployment Checklist for Makuli

## Pre-Deployment Verification

### ✅ 1. Database Setup
- [ ] Run SQL setup script in Supabase production environment (`docs/SUPABASE_PRODUCTION_SETUP.sql`)
- [ ] Verify all tables created with proper RLS policies
- [ ] Test database connection from app
- [ ] Seed production data using `ProductionSeeder.seedProductionDatabase()`
- [ ] Verify 14+ meal plan templates seeded successfully
- [ ] Verify 294+ template meals seeded successfully
- [ ] Test template selection and plan creation flows

### ✅ 2. Configuration & Environment
- [ ] Update `Configuration.swift` with production Supabase URLs and keys
- [ ] Secure API keys using Keychain storage for production
- [ ] Set proper environment detection (`isProduction = true` for release builds)
- [ ] Configure proper build configurations (Release vs Debug)
- [ ] Test configuration switching between development and production

### ✅ 3. Authentication & Security
- [ ] Configure Google OAuth for production domain
- [ ] Update `Google Auth Client.plist` with production OAuth credentials
- [ ] Test user registration and login flows
- [ ] Verify email confirmation (if enabled)
- [ ] Test password recovery flow
- [ ] Verify RLS policies protect user data properly

### ✅ 4. Core Functionality Testing
- [ ] **User Onboarding Flow**
  - [ ] Age, gender, goals, diet preferences input
  - [ ] Data saves to profiles table correctly
  - [ ] Onboarding completion tracking works
  
- [ ] **Meal Plan Creation**
  - [ ] Template selection displays 14 templates correctly
  - [ ] Template-based plan creation works end-to-end
  - [ ] AI meal plan generation (if OpenAI key configured)
  - [ ] Plan data saves to plans and plan_recipes tables
  
- [ ] **Plans Management**
  - [ ] View existing plans
  - [ ] Week detail view displays meals correctly
  - [ ] Mark meals as completed
  - [ ] Plan completion tracking
  
- [ ] **Grocery Lists**
  - [ ] Generate grocery list from meal plan
  - [ ] Mark items as purchased
  - [ ] Grocery list persists correctly
  
- [ ] **Recipes**
  - [ ] Browse recipes from database
  - [ ] Recipe detail view
  - [ ] Recipe search and filtering

### ✅ 5. Data Operations
- [ ] All database operations use `SupabaseManager.shared`
- [ ] No mock data in production builds
- [ ] Proper error handling and retry logic implemented
- [ ] Database operations work offline (cached data)
- [ ] Data validation and sanitization implemented

### ✅ 6. Performance & Optimization
- [ ] Image loading and caching optimized
- [ ] Database queries optimized with proper indexes
- [ ] Large lists use pagination
- [ ] Loading states implemented throughout app
- [ ] Memory usage optimized
- [ ] Network requests have timeouts

### ✅ 7. Error Handling & Monitoring
- [ ] Production logging system implemented (`ProductionLogger`)
- [ ] Crash reporting configured (Crashlytics/Sentry)
- [ ] Analytics events tracking configured
- [ ] User-friendly error messages
- [ ] Network error handling
- [ ] Offline mode handling

### ✅ 8. App Store Preparation
- [ ] **Info.plist Configuration**
  - [ ] Display name set to "Makuli"
  - [ ] Version number updated
  - [ ] Privacy usage descriptions added
  - [ ] App Transport Security configured
  
- [ ] **App Icon & Assets**
  - [ ] App icon updated (all sizes)
  - [ ] Launch screen configured
  - [ ] App screenshots prepared
  
- [ ] **Code Signing**
  - [ ] Distribution certificate configured
  - [ ] Provisioning profiles for production
  - [ ] Push notification entitlements (if used)

### ✅ 9. Legal & Compliance
- [ ] Privacy Policy created and accessible
- [ ] Terms of Service created and accessible
- [ ] GDPR compliance (if applicable)
- [ ] App Store Review Guidelines compliance
- [ ] Content rating appropriate

### ✅ 10. Testing
- [ ] **Device Testing**
  - [ ] iPhone (various sizes)
  - [ ] iPad compatibility
  - [ ] iOS version compatibility (minimum supported)
  
- [ ] **Network Conditions**
  - [ ] WiFi connection
  - [ ] Cellular connection
  - [ ] Poor network conditions
  - [ ] Offline mode
  
- [ ] **User Scenarios**
  - [ ] New user onboarding
  - [ ] Existing user returning
  - [ ] Plan creation and management
  - [ ] Grocery list usage
  - [ ] Recipe browsing

---

## Production Deployment Steps

### Step 1: Database Preparation
```sql
-- Run in Supabase SQL Editor
\i docs/SUPABASE_PRODUCTION_SETUP.sql
```

### Step 2: Seed Production Data
```swift
// In app or through Developer Panel
try await ProductionSeeder.seedProductionDatabase()
```

### Step 3: Verify Production Readiness
```swift
// Use DatabaseSeeder to verify
let readiness = await DatabaseSeeder.verifyProductionReadiness()
print("Production Ready: \(readiness.isReady)")
```

### Step 4: Build Configuration
- Switch to Release build configuration
- Ensure no debug code in production
- Test with production Supabase database
- Verify analytics and crash reporting

### Step 5: App Store Submission
- Archive build for distribution
- Upload to App Store Connect
- Configure metadata and screenshots
- Submit for review

---

## Production Monitoring

### Key Metrics to Monitor
- [ ] User registration rate
- [ ] Meal plan creation success rate
- [ ] Database query performance
- [ ] Crash-free session rate
- [ ] App launch time
- [ ] Network request success rate

### Logging Examples
```swift
// Log user actions
ProductionLogger.logEvent("meal_plan_created", parameters: [
    "template_id": templateId,
    "generation_method": "template"
])

// Log errors
ProductionLogger.logError(error, context: "MealPlanGeneration")
```

---

## Rollback Plan

### If Issues Arise After Deployment
1. **App Level Issues**
   - Submit hotfix update to App Store
   - Use feature flags to disable problematic features
   
2. **Database Issues**
   - Restore from backup
   - Fix data migration scripts
   - Re-run production seeder if needed

3. **API Issues**
   - Fallback to cached data
   - Display appropriate error messages
   - Implement graceful degradation

---

## Post-Deployment Tasks

### First 24 Hours
- [ ] Monitor crash reports
- [ ] Check user registration flow
- [ ] Verify database performance
- [ ] Monitor app store ratings

### First Week
- [ ] Analyze user behavior
- [ ] Check completion rates for key flows
- [ ] Monitor support requests
- [ ] Gather user feedback

### Ongoing
- [ ] Regular database backups
- [ ] Performance monitoring
- [ ] User feedback analysis
- [ ] Feature usage analytics
- [ ] Security monitoring

---

## Emergency Contacts

**Database Issues:** Check Supabase dashboard and logs
**App Store Issues:** Apple Developer Support
**Crash Monitoring:** Check configured crash reporting service
**General Issues:** Check `ProductionLogger` output and analytics

---

## Success Criteria

**Launch is considered successful when:**
- [ ] 95%+ crash-free session rate
- [ ] <2s app launch time
- [ ] 90%+ meal plan creation success rate
- [ ] 85%+ onboarding completion rate
- [ ] 4.0+ App Store rating (after initial reviews)

---

## Version History

- **v1.0.0** - Initial production release
  - 14 meal plan templates
  - 294+ template meals
  - Full user onboarding
  - Meal plan creation and management
  - Grocery list generation
  - Recipe browsing

---

**Remember:** Test everything twice, deploy once! 🚀 