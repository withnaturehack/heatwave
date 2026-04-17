# Task 1: Profile Management - Deployment Checklist

## Pre-Deployment

- [ ] Database backup created
- [ ] Code review completed
- [ ] All tests passing
- [ ] Team notified of deployment

## Database Migration Steps

### Step 1: Run Migration
1. Go to Supabase Dashboard → SQL Editor
2. Copy entire contents of `/supabase/01-normalize-profiles-schema.sql`
3. Run the query
4. Wait for completion (should complete in <1 second)

### Step 2: Verify Schema
```sql
-- Run these checks in SQL Editor to verify migration success:

-- Check profiles table structure
\d profiles

-- Should show:
-- id: uuid (primary key)
-- user_id: uuid (NOT NULL, UNIQUE, FK to auth.users)
-- display_name, social_link, main_photo_url, photo2_url, photo3_url
-- is_complete: boolean
-- created_at, updated_at: timestamp

-- Check for any data integrity issues
SELECT COUNT(*) as total_profiles,
       COUNT(user_id) as profiles_with_user_id
FROM profiles;

-- Result should show same count for both
```

## Code Deployment

- [ ] Merge branch into main
- [ ] Deploy to production via Vercel
- [ ] Verify no build errors
- [ ] Check CloudFlare/DNS propagation

## Post-Deployment Testing

### Test 1: New User Sign-Up
1. Sign up with new email
2. Verify redirected to `/membership-access`
3. Verify profile was created (check in Supabase)
4. Enter referral code
5. Verify membership record created
6. Complete onboarding (step 2, 3)
7. Verify all profile data saved correctly

### Test 2: Photo Upload
1. At step 3, try uploading:
   - [ ] Valid JPEG (< 5MB) - should work
   - [ ] Valid PNG (< 5MB) - should work
   - [ ] File > 5MB - should show error
   - [ ] Non-image file - should show error
   - [ ] Invalid format (e.g., .txt) - should show error
2. Try submitting without main photo - should show error
3. Submit with 1-3 photos - should work

### Test 3: Membership Redirect
1. New user without membership should redirect to `/membership-access`
2. User with valid referral code should proceed to `/onboarding`
3. Back button to return should work

### Test 4: ElevenLabs Token
1. Complete profile and reach voice step
2. Should successfully get ElevenLabs token
3. Conversation should work end-to-end

## Rollback Plan (If Needed)

If migration causes issues:

```sql
-- Rollback migration
-- WARNING: This will revert to old schema - data will be in old format
-- Only use if migration causes critical issues

-- 1. Revert code to previous version
-- 2. Delete new profiles with only user_id set
-- 3. Restore from backup if needed
```

## Monitoring Post-Deployment

Watch for errors in:
- [ ] Vercel edge function logs
- [ ] Supabase auth logs
- [ ] Database query logs (Supabase Dashboard)
- [ ] Client-side error tracking

Check for:
- [ ] 401/403 errors on profile queries
- [ ] Photo upload failures
- [ ] Membership access denials (unexpected)
- [ ] Profile creation failures

## Success Criteria

✅ All new sign-ups successfully create profiles
✅ Photo validation works correctly
✅ Membership system works with database (no localStorage)
✅ Auth callback creates profile on sign-up
✅ No errors in logs
✅ All onboarding flows complete successfully

## Deployment Sign-Off

- [ ] Reviewed by: ___________
- [ ] Deployed by: ___________
- [ ] Date: ___________
- [ ] Status: ✅ PRODUCTION READY

---

## Files Changed Summary

| File | Change | Reason |
|------|--------|--------|
| `supabase/01-normalize-profiles-schema.sql` | NEW | Production migration script |
| `supabase/profiles-table.sql` | Updated | Normalized schema (id + user_id) |
| `src/app/onboarding/step-3/page.tsx` | Updated | Photo file validation (5MB, format) |
| `src/app/page.tsx` | Updated | Removed localStorage, added DB queries |
| `src/app/onboarding/step-2/page.tsx` | Updated | Removed localStorage, added DB query |
| `src/app/auth/callback/page.tsx` | Updated | Auto-create profile on sign-up |

## Quick Reference: Migration Command

```sql
-- Full migration (copy & paste into Supabase SQL Editor)
BEGIN;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS user_id uuid;
UPDATE profiles SET user_id = id WHERE user_id IS NULL AND id IS NOT NULL;
ALTER TABLE profiles DROP CONSTRAINT IF EXISTS profiles_pkey;
ALTER TABLE profiles RENAME COLUMN id TO old_id;
ALTER TABLE profiles ADD COLUMN id uuid PRIMARY KEY DEFAULT gen_random_uuid();
ALTER TABLE profiles ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE profiles ADD CONSTRAINT profiles_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;
ALTER TABLE profiles ADD CONSTRAINT profiles_user_id_key UNIQUE(user_id);
ALTER TABLE profiles DROP COLUMN old_id;
CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON profiles(user_id);
COMMIT;
```
