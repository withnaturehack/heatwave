-- Create matches and messages tables for matching system
CREATE TABLE IF NOT EXISTS matches (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  matched_user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  match_score integer,
  match_decision text NOT NULL DEFAULT 'pending' 
  CHECK (match_decision IN ('pending', 'approved', 'rejected', 'expired')),
  compatibility_summary text,
  strengths jsonb,
  tensions jsonb,
  dealbreakers jsonb,
  match_reason text,
  archetype_dynamic text,
  introduced_at timestamptz,
  status text NOT NULL DEFAULT 'pending_review' 
  CHECK (status IN ('pending_review', 'introduced', 'accepted', 'declined', 'expired')),
  created_at timestamptz DEFAULT now() NOT NULL,
  updated_at timestamptz DEFAULT now() NOT NULL,
  CONSTRAINT different_users CHECK (user_id != matched_user_id)
);

-- Create messages table
CREATE TABLE IF NOT EXISTS messages (
  id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
  match_id uuid NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  sender_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  content text NOT NULL,
  read_at timestamptz,
  created_at timestamptz DEFAULT now() NOT NULL
);

-- Create updated_at trigger for matches
DROP TRIGGER IF EXISTS matches_updated_at ON matches;
CREATE TRIGGER matches_updated_at
BEFORE UPDATE ON matches
FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- RLS for matches
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;

-- Users can read matches where they are user_id OR matched_user_id
CREATE POLICY "users_read_own_matches" ON matches
FOR SELECT USING (auth.uid() = user_id OR auth.uid() = matched_user_id);

-- Only service role can insert/update (matching is server-side)
-- No user insert/update policies

-- RLS for messages
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Users can read messages from matches they're part of
CREATE POLICY "users_read_match_messages" ON messages
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM matches 
    WHERE matches.id = messages.match_id 
    AND (matches.user_id = auth.uid() OR matches.matched_user_id = auth.uid())
  )
);

-- Users can insert messages only to matches they're part of
CREATE POLICY "users_insert_messages" ON messages
FOR INSERT WITH CHECK (
  sender_id = auth.uid()
  AND EXISTS (
    SELECT 1 FROM matches 
    WHERE matches.id = match_id 
    AND (matches.user_id = auth.uid() OR matches.matched_user_id = auth.uid())
  )
);

-- No user delete for messages

-- Indexes
CREATE INDEX IF NOT EXISTS idx_matches_user_id ON matches(user_id);
CREATE INDEX IF NOT EXISTS idx_matches_matched_user_id ON matches(matched_user_id);
CREATE INDEX IF NOT EXISTS idx_matches_status ON matches(status);
CREATE INDEX IF NOT EXISTS idx_messages_match_id ON messages(match_id);
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_created_at ON messages(created_at);
