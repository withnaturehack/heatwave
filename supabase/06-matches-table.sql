-- Matches table for storing matches between users
-- Idempotent: safe to run multiple times

CREATE TABLE IF NOT EXISTS matches (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  matched_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  match_score integer,
  match_decision text NOT NULL DEFAULT 'pending' CHECK (match_decision IN ('pending', 'approved', 'rejected', 'expired')),
  compatibility_summary text,
  strengths jsonb,
  tensions jsonb,
  dealbreakers jsonb,
  match_reason text,
  archetype_dynamic text,
  introduced_at timestamptz,
  status text NOT NULL DEFAULT 'pending_review' CHECK (status IN ('pending_review', 'introduced', 'accepted', 'declined', 'expired')),
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL
);

-- Enable RLS
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if any
DROP POLICY IF EXISTS "users_read_own_matches" ON matches;
DROP POLICY IF EXISTS "users_see_both_directions" ON matches;

-- Users can read matches where they are user_id OR matched_user_id
CREATE POLICY "users_read_own_matches" ON matches
FOR SELECT USING (auth.uid() = user_id OR auth.uid() = matched_user_id);

-- Only service role can insert/update
-- No user policies

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_matches_user_id ON matches(user_id);
CREATE INDEX IF NOT EXISTS idx_matches_matched_user_id ON matches(matched_user_id);
CREATE INDEX IF NOT EXISTS idx_matches_status ON matches(status);
CREATE INDEX IF NOT EXISTS idx_matches_created_at ON matches(created_at);

-- Trigger for updated_at
DROP TRIGGER IF EXISTS matches_updated_at ON matches;
CREATE TRIGGER matches_updated_at
BEFORE UPDATE ON matches
FOR EACH ROW EXECUTE FUNCTION update_updated_at();
