-- Membership table for tracking status and applications
-- Idempotent: safe to run multiple times

CREATE TABLE IF NOT EXISTS membership (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid NOT NULL UNIQUE REFERENCES auth.users(id) ON DELETE CASCADE,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'applied')),
  referral_code_used text,
  application_data jsonb,
  applied_at timestamptz DEFAULT now(),
  approved_at timestamptz,
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

-- Enable RLS
ALTER TABLE membership ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "users_read_own_membership" ON membership;
DROP POLICY IF EXISTS "users_insert_own_membership" ON membership;

-- Users can read their own membership
CREATE POLICY "users_read_own_membership" ON membership
FOR SELECT USING (auth.uid() = user_id);

-- Users can insert their own application
CREATE POLICY "users_insert_own_membership" ON membership
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Only service role can update status (approve/reject)
-- No user update policy

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_membership_user_id ON membership(user_id);
CREATE INDEX IF NOT EXISTS idx_membership_status ON membership(status);

-- Trigger for updated_at
DROP TRIGGER IF EXISTS membership_updated_at ON membership;
CREATE TRIGGER membership_updated_at
BEFORE UPDATE ON membership
FOR EACH ROW EXECUTE FUNCTION update_updated_at();
