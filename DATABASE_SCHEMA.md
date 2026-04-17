# Romeo & Juliet Database Schema

## Complete Overview

This document describes all tables created for the Romeo & Juliet dating app.

---

## TABLE 1: `profiles` (Existing - Normalized)

**Purpose:** Store user profile information including personal details and conversation data.

**Columns:**
```sql
id                                    uuid PRIMARY KEY (auto-generated)
user_id                              uuid UNIQUE NOT NULL (FK → auth.users.id)
display_name                         text
social_link                          text
main_photo_url                       text
photo2_url                           text
photo3_url                           text
is_complete                          boolean DEFAULT false
basic_information                    jsonb
location_and_future_plans            jsonb
work_and_life_stage                  jsonb
education_and_intellectual_life      jsonb
relationship_direction_and_readiness jsonb
family_and_children                  jsonb
lifestyle                            jsonb
values_faith_and_culture             jsonb
political_and_social_outlook         jsonb
physical_and_attraction              jsonb
conversation_transcript              jsonb
conversation_summary                 text
elevenlabs_conversation_id           text
voice_conversation_completed         boolean
created_at                           timestamptz DEFAULT now()
updated_at                           timestamptz DEFAULT now()
```

**Indexes:**
- `idx_profiles_user_id` on `user_id`

**RLS Policies:**
- SELECT: Users can read their own profile (`auth.uid() = user_id`)
- INSERT: Users can create their own profile
- UPDATE: Users can update their own profile
- DELETE: None (service role only)

---

## TABLE 2: `membership` (New - Created)

**Purpose:** Track membership status and applications.

**Columns:**
```sql
id                      uuid PRIMARY KEY (auto-generated)
user_id                 uuid UNIQUE NOT NULL (FK → auth.users.id, ON DELETE CASCADE)
status                  text NOT NULL DEFAULT 'pending'
                        CHECK (status IN ('pending', 'approved', 'rejected', 'applied'))
referral_code_used      text
application_data        jsonb
applied_at              timestamptz DEFAULT now()
approved_at             timestamptz
created_at              timestamptz DEFAULT now()
updated_at              timestamptz DEFAULT now()
```

**Indexes:**
- `idx_membership_user_id` on `user_id`
- `idx_membership_status` on `status`

**RLS Policies:**
- SELECT: Users can read their own membership
- INSERT: Users can insert their own application
- UPDATE: Service role only
- DELETE: Service role only

---

## TABLE 3: `matches` (New - Created)

**Purpose:** Store match records between users with compatibility analysis.

**Columns:**
```sql
id                       uuid PRIMARY KEY (auto-generated)
user_id                  uuid NOT NULL (FK → auth.users.id, ON DELETE CASCADE)
matched_user_id          uuid NOT NULL (FK → auth.users.id, ON DELETE CASCADE)
match_score              integer
match_decision           text NOT NULL DEFAULT 'pending'
                         CHECK (match_decision IN ('pending', 'approved', 'rejected', 'expired'))
compatibility_summary    text
strengths                jsonb (array of strings)
tensions                 jsonb (array of strings)
dealbreakers             jsonb (array of strings)
match_reason             text
archetype_dynamic        text
introduced_at            timestamptz
status                   text NOT NULL DEFAULT 'pending_review'
                         CHECK (status IN ('pending_review', 'introduced', 'accepted', 'declined', 'expired'))
created_at               timestamptz DEFAULT now()
updated_at               timestamptz DEFAULT now()
```

**Indexes:**
- `idx_matches_user_id` on `user_id`
- `idx_matches_matched_user_id` on `matched_user_id`
- `idx_matches_status` on `status`

**RLS Policies:**
- SELECT: Users can read matches where they are `user_id` OR `matched_user_id`
- INSERT: Service role only
- UPDATE: Service role only
- DELETE: Service role only

---

## TABLE 4: `messages` (New - Created)

**Purpose:** Store private messages between matched users.

**Columns:**
```sql
id          uuid PRIMARY KEY (auto-generated)
match_id    uuid NOT NULL (FK → matches.id, ON DELETE CASCADE)
sender_id   uuid NOT NULL (FK → auth.users.id, ON DELETE CASCADE)
content     text NOT NULL
read_at     timestamptz
created_at  timestamptz DEFAULT now()
```

**Indexes:**
- `idx_messages_match_id` on `match_id`
- `idx_messages_sender_id` on `sender_id`
- `idx_messages_created_at` on `created_at`

**RLS Policies:**
- SELECT: Users can read messages where match_id belongs to a match they're part of
- INSERT: Users can insert messages only if they're part of the match
- UPDATE: Service role only
- DELETE: Service role only

---

## TABLE 5: `membership_applications` (New - Created)

**Purpose:** Track membership applications separately from approval status.

**Columns:**
```sql
id              uuid PRIMARY KEY (auto-generated)
user_id         uuid UNIQUE NOT NULL (FK → auth.users.id, ON DELETE CASCADE)
form_data       jsonb
referral_code   text
status          text DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected'))
submitted_at    timestamptz DEFAULT now()
reviewed_at     timestamptz
reviewed_by     uuid (FK → auth.users.id)
notes           text
created_at      timestamptz DEFAULT now()
updated_at      timestamptz DEFAULT now()
```

**Indexes:**
- `idx_membership_applications_user_id` on `user_id`
- `idx_membership_applications_status` on `status`

**RLS Policies:**
- SELECT: Users can read their own application
- INSERT: Users can submit their own application
- UPDATE: Service role only
- DELETE: Service role only

---

## TABLE 6: `members` (New - Created)

**Purpose:** Track approved members with referral codes.

**Columns:**
```sql
id              uuid PRIMARY KEY (auto-generated)
user_id         uuid UNIQUE NOT NULL (FK → auth.users.id, ON DELETE CASCADE)
referral_code   text UNIQUE NOT NULL
referrer_id     uuid (FK → auth.users.id, ON DELETE SET NULL)
joined_at       timestamptz DEFAULT now()
active          boolean DEFAULT true
created_at      timestamptz DEFAULT now()
updated_at      timestamptz DEFAULT now()
```

**Indexes:**
- `idx_members_user_id` on `user_id`
- `idx_members_referral_code` on `referral_code`
- `idx_members_active` on `active`

**RLS Policies:**
- SELECT: Users can read their own member record
- INSERT: Service role only
- UPDATE: Service role only
- DELETE: Service role only

---

## Triggers & Functions

### `update_updated_at()` Function
Automatically updates `updated_at` timestamp on any row modification.

Applied to: `profiles`, `membership`, `matches`, `messages`, `membership_applications`, `members`

---

## Migration Scripts Order

1. `01-normalize-profiles-schema.sql` - Create/normalize profiles table
2. `02-profiles-rls.sql` - Create RLS policies for profiles
3. `03-membership-table.sql` - Create membership table
4. `04-membership-applications-table.sql` - Create membership_applications table
5. `05-members-table.sql` - Create members table
6. `06-matches-table.sql` - Create matches table
7. `07-messages-table.sql` - Create messages table

---

## Data Relationships

```
auth.users (Supabase)
├── profiles (1:1 via user_id)
├── membership (1:1 via user_id)
├── membership_applications (1:1 via user_id)
├── members (1:1 via user_id)
├── matches (1:N via user_id and matched_user_id)
└── messages (1:N via sender_id)

matches (1:N with messages)
└── messages (N:1 via match_id)
```

---

## Security Notes

1. **Row Level Security (RLS):** Enabled on all tables
2. **User Isolation:** Users can only access their own data
3. **Service Role Operations:** Membership approval, match creation, and message management are service-role only
4. **Cascading Deletes:** User deletion cascades to all related records
5. **Data Validation:** CHECK constraints on status fields

---

## Example Queries

### Get user's own profile
```sql
SELECT * FROM profiles WHERE user_id = auth.uid();
```

### Get user's membership status
```sql
SELECT * FROM membership WHERE user_id = auth.uid();
```

### Get user's matches
```sql
SELECT * FROM matches 
WHERE user_id = auth.uid() OR matched_user_id = auth.uid()
ORDER BY created_at DESC;
```

### Get messages for a match
```sql
SELECT * FROM messages 
WHERE match_id = $1 
ORDER BY created_at ASC;
```

