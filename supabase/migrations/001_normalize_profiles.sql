-- Canonical profiles schema normalization
-- profiles.id = profile's own uuid (auto-generated primary key)
-- profiles.user_id = FK to auth.users(id), UNIQUE, NOT NULL

-- Step 1: Create new profiles table with correct schema
CREATE TABLE IF NOT EXISTS profiles_new (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  display_name text,
  social_link text,
  main_photo_url text,
  photo2_url text,
  photo3_url text,
  is_complete boolean DEFAULT false,
  basic_information jsonb,
  location_and_future_plans jsonb,
  work_and_life_stage jsonb,
  education_and_intellectual_life jsonb,
  relationship_direction_and_readiness jsonb,
  family_and_children jsonb,
  lifestyle jsonb,
  values_faith_and_culture jsonb,
  political_and_social_outlook jsonb,
  physical_and_attraction jsonb,
  conversation_transcript jsonb,
  conversation_summary text,
  elevenlabs_conversation_id text,
  voice_conversation_completed boolean DEFAULT false,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

-- Step 2: Copy data from old profiles table if it exists
DO $$ 
BEGIN
  IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'profiles') THEN
    INSERT INTO profiles_new (
      id,
      user_id,
      display_name,
      social_link,
      main_photo_url,
      photo2_url,
      photo3_url,
      is_complete,
      basic_information,
      location_and_future_plans,
      work_and_life_stage,
      education_and_intellectual_life,
      relationship_direction_and_readiness,
      family_and_children,
      lifestyle,
      values_faith_and_culture,
      political_and_social_outlook,
      physical_and_attraction,
      conversation_transcript,
      conversation_summary,
      elevenlabs_conversation_id,
      voice_conversation_completed,
      created_at,
      updated_at
    )
    SELECT
      COALESCE(id, gen_random_uuid()),
      id as user_id,
      display_name,
      social_link,
      main_photo_url,
      photo2_url,
      photo3_url,
      is_complete,
      basic_information,
      location_and_future_plans,
      work_and_life_stage,
      education_and_intellectual_life,
      relationship_direction_and_readiness,
      family_and_children,
      lifestyle,
      values_faith_and_culture,
      political_and_social_outlook,
      physical_and_attraction,
      conversation_transcript,
      conversation_summary,
      elevenlabs_conversation_id,
      voice_conversation_completed,
      COALESCE(created_at, now()),
      COALESCE(updated_at, now())
    FROM profiles;
  END IF;
END $$;

-- Step 3: Drop old table and rename new one
DROP TABLE IF EXISTS profiles CASCADE;
ALTER TABLE profiles_new RENAME TO profiles;

-- Step 4: Create indexes
CREATE INDEX IF NOT EXISTS idx_profiles_user_id ON profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_profiles_created_at ON profiles(created_at);

-- Step 5: Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Step 6: Create updated_at trigger
DROP TRIGGER IF EXISTS profiles_updated_at ON profiles;
CREATE TRIGGER profiles_updated_at
BEFORE UPDATE ON profiles
FOR EACH ROW EXECUTE FUNCTION update_updated_at();
