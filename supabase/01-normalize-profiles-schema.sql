-- Migration: Normalize profiles table schema
-- Adds user_id column and restructures primary key
-- Run this after backing up your profiles data

BEGIN;

-- Step 1: Add user_id column if it doesn't exist
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS user_id uuid;

-- Step 2: Populate user_id from id (if id was previously used as FK to auth.users)
-- Only update rows where user_id is NULL and id exists
UPDATE profiles
SET user_id = id
WHERE user_id IS NULL AND id IS NOT NULL;

-- Step 3: Create a new id column with uuid_generate_v4() default
-- First, temporarily drop the primary key constraint
ALTER TABLE profiles
DROP CONSTRAINT IF EXISTS profiles_pkey;

-- Rename old id to auth_id temporarily
ALTER TABLE profiles
RENAME COLUMN id TO old_id;

-- Create new id column with uuid_generate_v4()
ALTER TABLE profiles
ADD COLUMN id uuid PRIMARY KEY DEFAULT gen_random_uuid();

-- Step 4: Make user_id NOT NULL and add foreign key
ALTER TABLE profiles
ALTER COLUMN user_id SET NOT NULL;

ALTER TABLE profiles
ADD CONSTRAINT profiles_user_id_fkey FOREIGN KEY (user_id)
REFERENCES auth.users(id) ON DELETE CASCADE;

-- Step 5: Add unique constraint on user_id (one profile per user)
ALTER TABLE profiles
ADD CONSTRAINT profiles_user_id_key UNIQUE(user_id);

-- Step 6: Drop the old_id column since we now have proper separation
ALTER TABLE profiles
DROP COLUMN old_id;

-- Step 7: Ensure indexes are in place for performance
CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON profiles(user_id);

COMMIT;
