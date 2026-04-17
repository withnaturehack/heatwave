-- Run in Supabase Dashboard → SQL Editor
-- Creates the profiles table with proper schema: separate id and user_id columns

-- Create table if it doesn't exist (for new projects)
CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name text,
  social_link text,
  main_photo_url text,
  photo2_url text,
  photo3_url text,
  is_complete boolean DEFAULT false,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Create index for user_id lookups
CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON profiles(user_id);

-- Add missing columns if they don't exist
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS display_name text;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS social_link text;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS main_photo_url text;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS photo2_url text;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS photo3_url text;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS is_complete boolean DEFAULT false;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS created_at timestamp with time zone DEFAULT now();
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS updated_at timestamp with time zone DEFAULT now();
