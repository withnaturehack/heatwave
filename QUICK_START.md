# Romeo & Juliet - Quick Start Guide

## 🚀 Start Here (5 minutes)

### What You Need:
- Node.js 18+
- Supabase account (free tier fine)
- Google OAuth credentials
- ElevenLabs API key

---

## Step 1: Environment Setup (2 min)

Create `.env.local`:
```env
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_key_here
GOOGLE_CLIENT_ID=your_id
GOOGLE_CLIENT_SECRET=your_secret
ELEVENLABS_API_KEY=your_key
NEXT_PUBLIC_ELEVENLABS_API_KEY=your_key
```

Get keys from:
- **Supabase:** https://supabase.com → Dashboard → Settings → API
- **Google:** https://console.cloud.google.com → OAuth 2.0
- **ElevenLabs:** https://elevenlabs.io → Settings → API Keys

---

## Step 2: Database Setup (2 min)

1. Go to Supabase Dashboard → **SQL Editor**
2. Copy-paste and run each migration file in order:
   - `supabase/01-normalize-profiles-schema.sql`
   - `supabase/02-profiles-rls.sql`
   - `supabase/03-membership-table.sql`
   - `supabase/04-membership-applications-table.sql`
   - `supabase/05-members-table.sql`
   - `supabase/06-matches-table.sql`
   - `supabase/07-messages-table.sql`

3. Verify: Go to **Table Editor** → See 6 tables listed

---

## Step 3: Start Development (1 min)

```bash
npm install
npm run dev
```

Open http://localhost:3000 → Sign in with Google

---

## Database Tables at a Glance

| Table | Purpose | Key Field |
|-------|---------|-----------|
| `profiles` | User profile data | `user_id` (FK to auth.users) |
| `membership` | Membership status | `user_id` |
| `membership_applications` | Applications | `user_id` |
| `members` | Approved members | `user_id` + `referral_code` |
| `matches` | Matches between users | `user_id`, `matched_user_id` |
| `messages` | Private messages | `match_id`, `sender_id` |

---

## Common Tasks

### View User Data
```sql
-- Profile
SELECT * FROM profiles WHERE user_id = 'user-uuid';

-- Membership
SELECT * FROM membership WHERE user_id = 'user-uuid';

-- Matches
SELECT * FROM matches 
WHERE user_id = 'user-uuid' OR matched_user_id = 'user-uuid';

-- Messages
SELECT * FROM messages WHERE match_id = 'match-uuid';
```

### Create Test Data
```sql
-- Manually create a match (for testing)
INSERT INTO matches (user_id, matched_user_id, status, match_reason)
VALUES ('user1-uuid', 'user2-uuid', 'pending_review', 'Test');

-- Approve a membership application
INSERT INTO members (user_id, referral_code)
VALUES ('user-uuid', 'REF123');
```

### Check Deployment
```bash
npm run build  # Should complete without errors
npm run dev    # Should run on :3000
```

---

## Project Structure

```
heatwave/
├── src/
│   ├── app/
│   │   ├── page.tsx              (landing)
│   │   ├── home/page.tsx         (dashboard)
│   │   ├── auth/callback         (auth flow)
│   │   ├── onboarding/           (4-step setup)
│   │   ├── voice/                (voice conversation)
│   │   ├── matches/              (match list) [TODO]
│   │   ├── chat/                 (messaging) [TODO]
│   │   └── api/                  (API routes)
│   ├── components/               (UI components)
│   ├── lib/                      (utilities & helpers)
│   └── types/database.ts         (TypeScript types)
├── supabase/                     (migrations)
├── public/                       (static assets)
└── DATABASE_SCHEMA.md            (full schema docs)
```

---

## Key Files to Know

| File | Purpose |
|------|---------|
| `LOCAL_SETUP_GUIDE.md` | Detailed setup with troubleshooting |
| `DATABASE_SCHEMA.md` | Complete database documentation |
| `TASK_1_COMPLETION_SUMMARY.md` | Phase 1 implementation details |
| `src/types/database.ts` | All TypeScript type definitions |
| `src/lib/saveProfileSection.ts` | Profile data saving logic |

---

## What's Ready

✅ Profile management (normalized schema)
✅ Membership system (database-backed)
✅ Photo validation (5MB, JPEG/PNG/WebP)
✅ Voice conversations (ElevenLabs integrated)
✅ Type safety (complete TypeScript types)
✅ Security (RLS on all tables)
✅ Documentation (comprehensive guides)

---

## What's Next

🚧 Match API routes
🚧 Match list UI
🚧 Chat interface
🚧 Real-time messaging
🚧 Match flow animations

See `romeo--juliet--full-copilotcursor-prompts-for-all-tasks-6u4fV.md` for all planned features.

---

## Troubleshooting

**"Table does not exist"**
→ Run migrations in Supabase SQL Editor

**"RLS policy violation"**
→ Make sure you're logged in and own the data

**"Can't sign in"**
→ Check Google OAuth credentials in .env.local

**"Port 3000 in use"**
→ `lsof -ti:3000 | xargs kill -9`

---

## Full Setup (Detailed)

👉 **Read LOCAL_SETUP_GUIDE.md for complete step-by-step instructions**

It includes:
- Pre-requisites and installation
- Supabase project setup
- Google OAuth configuration
- All 7 migrations with explanations
- Local development workflow
- Testing procedures
- Debugging tips
- Common issues & solutions

---

## Useful Links

- **Supabase:** https://supabase.com
- **Docs:** https://supabase.com/docs
- **Project:** https://github.com/withnaturehack/heatwave
- **Next.js:** https://nextjs.org/docs
- **React:** https://react.dev

---

## Git Branches

```bash
# Current work
git checkout profile-management-fix

# Start new feature
git checkout -b feature/matches-messaging
git checkout -b feature/match-flow-ui
```

---

## Quick Commands

```bash
# Development
npm run dev              # Start dev server
npm run build            # Build for production
npm run lint             # Check code

# Database
# Use Supabase SQL Editor in dashboard

# Git
git add .
git commit -m "feat: description"
git push origin branch-name
```

---

## Success Checklist

When you can do all of these locally:

- [ ] npm install completes
- [ ] npm run dev starts without errors
- [ ] Can sign in with Google
- [ ] Profile auto-created in database
- [ ] Can complete onboarding
- [ ] Photos upload successfully
- [ ] localStorage is empty (only DB used)
- [ ] Database migrations all run
- [ ] All 6 tables exist in Supabase

**Then you're ready to continue development!**

---

**That's it! You're ready to go. Happy coding! 🚀**

