-- Rewrite RLS policies for profiles table
-- Drop all existing profiles policies
DO $$ 
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN 
    SELECT policyname FROM pg_policies 
    WHERE tablename = 'profiles'
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON profiles', 
    pol.policyname);
  END LOOP;
END $$;

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Users can read their own profile
CREATE POLICY "users_read_own_profile" ON profiles
FOR SELECT USING (auth.uid() = user_id);

-- Users can create their own profile
CREATE POLICY "users_insert_own_profile" ON profiles
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can update their own profile
CREATE POLICY "users_update_own_profile" ON profiles
FOR UPDATE USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

-- No user delete — service role only
