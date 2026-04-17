-- Membership applications table for tracking applications separately
-- Idempotent: safe to run multiple times

CREATE TABLE IF NOT EXISTS membership_applications (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  form_data jsonb,
  referral_code text,
  status text DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  submitted_at timestamptz DEFAULT now(),
  reviewed_at timestamptz,
  reviewed_by uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  notes text,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

-- Enable RLS
ALTER TABLE membership_applications ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "users_read_own_application" ON membership_applications;
DROP POLICY IF EXISTS "users_insert_own_application" ON membership_applications;

-- Users can read their own application
CREATE POLICY "users_read_own_application" ON membership_applications
FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own application
CREATE POLICY "users_insert_own_application" ON membership_applications
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Only service role can update
-- No user update policy

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_membership_applications_user_id ON membership_applications(user_id);
CREATE INDEX IF NOT EXISTS idx_membership_applications_status ON membership_applications(status);

-- Trigger for updated_at
DROP TRIGGER IF EXISTS membership_applications_updated_at ON membership_applications;
CREATE TRIGGER membership_applications_updated_at
BEFORE UPDATE ON membership_applications
FOR EACH ROW EXECUTE FUNCTION update_updated_at();
