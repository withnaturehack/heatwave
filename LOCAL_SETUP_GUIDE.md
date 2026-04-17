# Romeo & Juliet Local Development Setup Guide

Complete instructions to set up and work with the Romeo & Juliet app locally.

---

## Prerequisites

- Node.js 18+ installed
- Git installed
- Supabase account (free tier works)
- Git cloned repository

---

## Step 1: Initial Setup

### 1.1 Clone the Repository
```bash
git clone https://github.com/withnaturehack/heatwave.git
cd heatwave
git checkout profile-management-fix
```

### 1.2 Install Dependencies
```bash
npm install
# or
yarn install
# or
pnpm install
```

### 1.3 Environment Variables
Create `.env.local` in the root directory:

```env
# Supabase
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key_here

# ElevenLabs (for voice conversations)
ELEVENLABS_API_KEY=your_elevenlabs_key_here
NEXT_PUBLIC_ELEVENLABS_API_KEY=your_elevenlabs_public_key

# Google OAuth (for authentication)
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
```

#### Getting Supabase Credentials:
1. Go to https://supabase.com → Sign in
2. Create a new project or select existing
3. Go to **Settings → API**
4. Copy:
   - `Project URL` → `NEXT_PUBLIC_SUPABASE_URL`
   - `anon public` key → `NEXT_PUBLIC_SUPABASE_ANON_KEY`

#### Getting ElevenLabs API Key:
1. Go to https://elevenlabs.io → Sign in
2. Navigate to **Settings → API Keys**
3. Copy your API key

---

## Step 2: Database Setup

### 2.1 Create Supabase Project
If you don't have a Supabase project:
1. Go to https://supabase.com
2. Click **New Project**
3. Fill in project details and create
4. Wait for project initialization (5-10 minutes)

### 2.2 Run Database Migrations
Run migrations in order in the Supabase SQL Editor:

1. Open Supabase Dashboard → **SQL Editor**
2. Create a new query and paste each migration:

**Migration 1:** `supabase/01-normalize-profiles-schema.sql`
```bash
# Copy entire file content and run in Supabase SQL Editor
```

**Migration 2:** `supabase/02-profiles-rls.sql`
```bash
# Copy entire file content and run in Supabase SQL Editor
```

**Migration 3:** `supabase/03-membership-table.sql`
```bash
# Copy entire file content and run in Supabase SQL Editor
```

**Migration 4:** `supabase/04-membership-applications-table.sql`
```bash
# Copy entire file content and run in Supabase SQL Editor
```

**Migration 5:** `supabase/05-members-table.sql`
```bash
# Copy entire file content and run in Supabase SQL Editor
```

**Migration 6:** `supabase/06-matches-table.sql`
```bash
# Copy entire file content and run in Supabase SQL Editor
```

**Migration 7:** `supabase/07-messages-table.sql`
```bash
# Copy entire file content and run in Supabase SQL Editor
```

### 2.3 Verify Migrations
In Supabase, go to **Table Editor** and verify these tables exist:
- `profiles`
- `membership`
- `membership_applications`
- `members`
- `matches`
- `messages`

---

## Step 3: Authentication Setup

### 3.1 Enable Google OAuth in Supabase

1. Go to Supabase Dashboard → **Authentication → Providers**
2. Find **Google** and click **Enable**
3. Follow instructions to set up Google OAuth credentials:
   - Go to https://console.cloud.google.com
   - Create a new project
   - Enable Google+ API
   - Create OAuth 2.0 credentials (Web application)
   - Set redirect URIs:
     - `https://your-project.supabase.co/auth/v1/callback`
     - `http://localhost:3000/auth/callback` (for local dev)
4. Copy Client ID and Client Secret into Supabase
5. Update `.env.local` with credentials

### 3.2 Test Authentication
1. Start dev server: `npm run dev`
2. Go to http://localhost:3000
3. Click login → Google
4. Sign in with a Google account
5. You should be redirected to home page

---

## Step 4: Start Development Server

```bash
npm run dev
```

The app will be available at http://localhost:3000

### Dev Server Features:
- Hot reload on file changes
- Source maps for debugging
- Console shows errors/warnings

---

## Step 5: Database Workflow (Daily Development)

### Adding a Migration

1. Create file in `/supabase/` directory:
```bash
# Example: Adding a new column
# File: supabase/08-add-new-field.sql
```

2. Write idempotent SQL:
```sql
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS new_field text;
CREATE INDEX IF NOT EXISTS idx_profiles_new_field ON profiles(new_field);
```

3. Test locally:
   - Go to Supabase SQL Editor
   - Paste and run the migration
   - Verify in Table Editor

4. Update TypeScript types in `src/types/database.ts`

5. Commit:
```bash
git add supabase/08-add-new-field.sql src/types/database.ts
git commit -m "feat: add new field to profiles"
```

### Checking Data Locally

1. **Supabase Dashboard** → **Table Editor**
2. Click on any table to view/edit rows
3. Use **SQL Editor** for complex queries

### Common Queries

#### Check current user's profile:
```sql
SELECT * FROM profiles WHERE user_id = auth.uid();
```

#### Check all matches for a user:
```sql
SELECT * FROM matches 
WHERE user_id = 'user-uuid' OR matched_user_id = 'user-uuid'
ORDER BY created_at DESC;
```

#### Check messages in a match:
```sql
SELECT * FROM messages 
WHERE match_id = 'match-uuid'
ORDER BY created_at ASC;
```

#### Check membership status:
```sql
SELECT * FROM membership WHERE user_id = 'user-uuid';
```

---

## Step 6: Testing Workflows

### Test Profile Creation
1. Sign up with new Google account
2. Check Supabase Table Editor → `profiles`
3. New row should exist with `user_id` and `is_complete = false`

### Test Onboarding Flow
1. Click "Complete Your Profile"
2. Fill in basic information (step 1)
3. Upload 3 photos (step 2)
4. Select interests (step 3)
5. All data should save to `profiles` JSONB columns

### Test Voice Conversation
1. Click "Start Voice Conversation"
2. Answer questions via voice
3. Check `profiles.conversation_transcript` and `conversation_summary`
4. Check `profiles.voice_conversation_completed = true`

### Test Membership
1. User applies for membership
2. Check `membership_applications` table for submission
3. Admin approves in Supabase → Updates `members` table
4. User should see "Member" status

### Test Matches
1. Admin inserts match row in `matches` table:
```sql
INSERT INTO matches (user_id, matched_user_id, status, match_reason)
VALUES ('user1-uuid', 'user2-uuid', 'pending_review', 'Testing');
```
2. Both users should see match on `/matches` page
3. Accept → status changes to `introduced`
4. Both accept → status changes to `accepted`
5. Chat unlocked at `/chat/match-id`

### Test Messages
1. After both users accept match
2. User A sends message from chat
3. Message appears in `messages` table
4. User B receives message in real-time

---

## Step 7: Debugging

### Enable Debug Logging

In your code:
```typescript
console.log("[v0] Debugging info:", variable);
```

### Check Supabase Logs
1. Dashboard → **Logs** (bottom left)
2. View API requests and errors
3. Filter by table name

### Check Browser Console
1. Open DevTools (F12 or Cmd+Option+I)
2. Go to **Console** tab
3. Look for errors in red

### Inspect Network Requests
1. Open DevTools → **Network** tab
2. Perform action
3. Look for API calls to Supabase
4. Check response data

### Database Inspection
```sql
-- See all tables
SELECT tablename FROM pg_tables WHERE schemaname = 'public';

-- See table structure
\d+ profiles

-- Count rows in table
SELECT COUNT(*) FROM profiles;

-- Find issues
SELECT * FROM profiles WHERE user_id IS NULL;
```

---

## Step 8: Git Workflow

### Branch Names
```bash
# Feature branches
git checkout -b feature/new-feature

# Bug fixes
git checkout -b fix/bug-name

# From main branch
git checkout main
git pull origin main
git checkout -b feature/name
```

### Commit Messages
```bash
# Feature
git commit -m "feat: add new feature description"

# Bug fix
git commit -m "fix: describe the bug fix"

# Database change
git commit -m "db: add new table or migration"

# Documentation
git commit -m "docs: update README"

# Style/formatting
git commit -m "style: fix code formatting"
```

### Push and Create PR
```bash
git add .
git commit -m "feat: description"
git push origin feature/name
```

Then go to GitHub and create a Pull Request.

---

## Step 9: Environment Variables Reference

### Complete `.env.local` Template

```env
# ============================================
# SUPABASE (Required)
# ============================================
NEXT_PUBLIC_SUPABASE_URL=https://xxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGc...

# ============================================
# AUTHENTICATION (Required)
# ============================================
GOOGLE_CLIENT_ID=xxxxx.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=GOCSPX-xxxxx

# ============================================
# VOICE & AI (Optional)
# ============================================
ELEVENLABS_API_KEY=sk_xxxxx
NEXT_PUBLIC_ELEVENLABS_API_KEY=sk_xxxxx

# ============================================
# DEVELOPMENT (Optional)
# ============================================
NODE_ENV=development
DEBUG=*
```

### Getting Each Key:

**Supabase Keys:**
- Dashboard → Settings → API → Copy keys

**Google OAuth:**
- https://console.cloud.google.com → Create OAuth credentials

**ElevenLabs:**
- https://elevenlabs.io → Settings → API Keys

---

## Step 10: Common Issues & Solutions

### Issue: "Invalid login credentials"
**Solution:** Check `.env.local` has correct Supabase URL and keys

### Issue: "Table does not exist"
**Solution:** Run all migrations in order in Supabase SQL Editor

### Issue: "RLS policy violation"
**Solution:** 
1. Make sure you're logged in
2. Check RLS policies allow your user (use `auth.uid()`)
3. Check `user_id` matches `auth.uid()`

### Issue: "Photos not uploading"
**Solution:** 
1. Check file size < 5MB
2. Check file type is JPEG/PNG/WebP
3. Check Supabase storage bucket exists
4. Check storage policies allow authenticated uploads

### Issue: "Voice not working"
**Solution:**
1. Check ElevenLabs API key is valid
2. Check browser microphone permission
3. Check `ELEVENLABS_API_KEY` in `.env.local`

### Issue: "Port 3000 already in use"
**Solution:**
```bash
# Kill process on port 3000
# macOS/Linux:
lsof -ti:3000 | xargs kill -9

# Windows:
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# Or use different port:
npm run dev -- -p 3001
```

---

## Step 11: Performance Tips

### Enable Query Caching
Use SWR for data fetching:
```typescript
import useSWR from 'swr';

const { data: profile } = useSWR(
  [`profile`, userId],
  fetcher,
  { revalidateOnFocus: false }
);
```

### Database Query Optimization
- Use indexes (already created in migrations)
- Select only needed columns
- Use `.single()` when expecting one row
- Avoid N+1 queries with JOIN

### Image Optimization
- Compress photos before upload
- Use next/image component
- Set `placeholder="blur"`

---

## Step 12: Deployment Checklist

Before deploying to production:

- [ ] All migrations run successfully
- [ ] Environment variables set in Vercel
- [ ] RLS policies reviewed
- [ ] Rate limiting configured
- [ ] Error logging set up
- [ ] Backups configured in Supabase
- [ ] Custom domain configured
- [ ] CORS settings reviewed

---

## Useful Commands

```bash
# Development
npm run dev          # Start dev server
npm run build        # Build for production
npm run lint         # Check code quality
npm test             # Run tests

# Database
# Access Supabase CLI
npx supabase link    # Link to project
npx supabase migration list  # View migrations

# Git
git status           # Check uncommitted changes
git log --oneline    # View commit history
git diff             # See changes before commit
```

---

## Resources

- **Supabase Docs:** https://supabase.com/docs
- **Next.js Docs:** https://nextjs.org/docs
- **React Docs:** https://react.dev
- **ElevenLabs Docs:** https://elevenlabs.io/docs
- **TypeScript Docs:** https://www.typescriptlang.org/docs

---

## Support

For issues:
1. Check DATABASE_SCHEMA.md for table structure
2. Review TASK_1_COMPLETION_SUMMARY.md for what was done
3. Check browser console for errors
4. Check Supabase logs
5. Review code in relevant component

