# CONFIGURE.md — Personal Assistant Build Plan

**Read this if you are a fresh OpenClaw instance being set up as a personal assistant.**

This is your mission brief. It tells you what you are building, what you need from your human, and what order to do things. Follow it phase by phase. Check off tasks as you complete them. Do not skip phases.

When you are done, archive this file:
```bash
mkdir -p memory/archive && mv CONFIGURE.md memory/archive/CONFIGURE.md
git add -A && git commit -m "setup: CONFIGURE.md archived — build complete"
```

The full technical reference for everything described here is in `PERSONAL-ASSISTANT-SETUP.md`. Read it when you need implementation details.

---

## What You Are Building

A personal assistant with:
- **Email intelligence** — your human's M365 inbox synced, analyzed, and searchable
- **Calendar awareness** — events and To-Do tasks synced; AI-generated scheduling suggestions
- **Semantic memory** (Total Recall) — your workspace files indexed for semantic search, not just keyword match
- **Living 2nd Brain** — Obsidian vault that auto-mirrors your memory every 2 hours
- **Daily digest** — proactive morning briefing delivered to your human's messaging channel
- **Background automations** — everything runs on a schedule without anyone thinking about it

You are NOT building business-specific integrations (no ticketing systems, no accounting software, no RMM). This is about the person, not the business.

---

## What You Need From Your Human

Before starting, collect the following. Ask all at once — don't drip questions:

```
1. Your full name and what you'd like me to call you
2. Your pronouns
3. Your timezone
4. Your M365 email address (the one I'll be syncing)
5. Your M365 tenant ID (found in portal.azure.com → Microsoft Entra ID → Overview)
6. Do you have a local inference server running? (GPU or Apple Silicon Mac with vLLM/MLX-LM)
   - If yes: base URL and model name
   - If no: which cloud provider do you prefer? (Anthropic/OpenAI/Google)
7. What messaging app do you want me on? (Discord/Telegram/iMessage)
8. Where do you want your Obsidian vault? (default: ~/Documents/SecondBrain)
9. Do you have 1Password? If yes, which vault should I store references in?
10. GitHub username (for workspace backup)
```

Do not proceed to Phase 1 until you have answers to at least: name, email, tenant ID, messaging app, and cloud provider/local model.

---

## Phase 1 — Identity [ ]

**Goal:** Make this workspace yours.

- [ ] Fill in `USER.md` with everything you learned from the intake questions
- [ ] Edit `SOUL.md` — replace all `{{placeholders}}` with real values for this person. Read it carefully — this is your personality and your operating principles. Adjust tone and focus to match the human.
- [ ] Fill in `IDENTITY.md` — give yourself a name. Make it feel intentional, not generic.
- [ ] Fill in `TOOLS.md` — note the password manager, key machines, and any infrastructure you know about. Leave blank fields for what you don't know yet.
- [ ] Configure `HEARTBEAT.md` — define what you check on each heartbeat: email urgency threshold, how far ahead to look at calendar, DB freshness alerts
- [ ] Seed `MEMORY.md` — add what you know so far: who this person is, their goals, their setup, their preferences
- [ ] Update `state/active-context.json` — currentTask: "Personal Assistant Setup — Phase 1"
- [ ] Commit: `git commit -m "setup: workspace identity — Phase 1 complete"`

---

## Phase 2 — Memory & Backup [ ]

**Goal:** Make sure you never lose context again.

- [ ] Push workspace to a private GitHub repo. Ask your human for a repo name if they have a preference, otherwise use `<name>-assistant-workspace`.
  ```bash
  git remote add origin https://github.com/<username>/<repo>.git
  git push -u origin main
  ```
- [ ] Configure Total Recall in `openclaw.json`:
  - If local inference is available: use the local embedding model (see `PERSONAL-ASSISTANT-SETUP.md` Phase 2 for config format)
  - If cloud only: use `openai:https://api.openai.com/v1:text-embedding-3-small`
  - After configuring: `openclaw memory reindex`
- [ ] Verify Total Recall works: run a memory search and confirm relevant results come back
- [ ] Update `state/active-context.json` — currentTask: "Personal Assistant Setup — Phase 2"
- [ ] Commit: `git commit -m "setup: memory and backup — Phase 2 complete"`

---

## Phase 3 — Obsidian 2nd Brain [ ]

**Goal:** Create a structured knowledge vault that grows over time.

- [ ] Create vault directory at the path your human specified (default: `~/Documents/SecondBrain`)
- [ ] Have your human open it in Obsidian: File → Open Folder as Vault → select the directory
- [ ] Once open, set it as the CLI default: `obsidian-cli set-default "SecondBrain"` (or whatever the vault folder name is)
- [ ] Create the base folder structure:
  - `Brain/` — auto-synced memory mirror (don't manually edit)
  - `People/` — profiles for key relationships
  - `Projects/` — active and archived projects
  - `Decisions/` — architecture log, key decisions
  - `Research/` — notes, articles, saved content
  - `Automations/` — notes on what's running in the background
- [ ] Create `Decisions/Architecture Log.md` — log each setup decision as you make it
- [ ] Create `People/<Human Name>.md` — a profile for your human based on what you know so far
- [ ] Push vault to a private GitHub repo for backup
- [ ] Update `state/active-context.json` — currentTask: "Personal Assistant Setup — Phase 3"
- [ ] Commit: `git commit -m "setup: Obsidian 2nd Brain — Phase 3 complete"`

---

## Phase 4 — M365 Integration [ ]

**Goal:** Get API access to your human's email and calendar.

You need an Azure app registration with the right permissions. This requires either your human to do it themselves, or a tenant admin to grant consent.

Walk your human through this (see `PERSONAL-ASSISTANT-SETUP.md` Phase 4 for the exact steps):

- [ ] App registered in Microsoft Entra ID
- [ ] Client ID, Tenant ID, and Client Secret collected and stored securely (1Password if available)
- [ ] Graph API permissions granted:
  - `Mail.Read`
  - `Calendars.ReadWrite`
  - `Tasks.ReadWrite.All` (requires admin consent)
  - `User.Read.All`
- [ ] Admin consent granted for all permissions
- [ ] Test the token: try a simple Graph API call to confirm access works
  ```bash
  # Quick test — should return your human's mailbox info
  curl -s -H "Authorization: Bearer <token>" \
    "https://graph.microsoft.com/v1.0/users/<email>/mailboxSettings" | head -20
  ```
- [ ] Store credentials as environment variables (never hardcode in scripts)
- [ ] Update `state/active-context.json` — currentTask: "Personal Assistant Setup — Phase 4"
- [ ] Commit (no secrets): `git commit -m "setup: M365 integration — Phase 4 complete"`

---

## Phase 5 — Databases [ ]

**Goal:** Create the two databases that power email + calendar intelligence.

- [ ] Create the `data/` directory in your scripts folder
- [ ] Create `padata.db` with all required tables (see `PERSONAL-ASSISTANT-SETUP.md` Phase 5 for the exact `CREATE TABLE` SQL)
  - Tables: `emails`, `calendar_events`, `todo_tasks`, `calendar_suggestions`, `email_response_stats`, `sync_state`, `interest_signals`, `discovery_feed`, `preferences`
- [ ] Create `embeddings.db` with the `email_embeddings` table
- [ ] Verify both DBs are writable and the schemas are correct:
  ```bash
  sqlite3 data/padata.db ".tables"
  sqlite3 data/embeddings.db ".tables"
  ```
- [ ] Update `state/active-context.json` — currentTask: "Personal Assistant Setup — Phase 5"
- [ ] Commit: `git commit -m "setup: databases created — Phase 5 complete"`

---

## Phase 6 — Sync Scripts [ ]

**Goal:** Write the scripts that keep data fresh.

These scripts are the engine. Write each one, test it manually, then move to the next.

- [ ] `sync-email.ts` — M365 inbox → `padata.db` emails table
  - Use delta queries (store delta link in `sync_state`)
  - Add `Prefer: outlook.body-content-type="text"` header (prevents marking emails as read)
  - Test: `npx tsx scripts/sync-email.ts` — should ingest at least 1 email
- [ ] `sync-calendar.ts` — M365 calendar → `padata.db` calendar_events table
  - Use `calendarView/delta` with `Prefer: odata.maxpagesize=50` header (NOT `$top` query param)
  - Test: `npx tsx scripts/sync-calendar.ts`
- [ ] `sync-todos.ts` — M365 To-Do → `padata.db` todo_tasks table
  - Test: `npx tsx scripts/sync-todos.ts`
- [ ] `analyze-emails.ts` — LLM-tag emails with `has_question`, `has_deadline`, `urgency_score`, `sender_type`
  - Use the local LLM endpoint if available; fall back to cloud
  - Test: `npx tsx scripts/analyze-emails.ts`
- [ ] `embed-emails.ts` — generate vector embeddings for email bodies → `embeddings.db`
  - Use the embedding model configured in Phase 2
  - Test: `npx tsx scripts/embed-emails.ts`
- [ ] `generate-suggestions.ts` — LLM generates calendar block suggestions from open tickets/tasks
  - Test: `npx tsx scripts/generate-suggestions.ts`
- [ ] `discord-digest.ts` (or equivalent for chosen messaging channel) — morning briefing
  - Include: open tasks, today's calendar, flagged emails, one discovery item
  - Test: `npx tsx scripts/discord-digest.ts`
- [ ] `brain-dump.sh` — mirror MEMORY.md + active-context.json to Obsidian vault, commit if changed
  - Test: `bash scripts/brain-dump.sh`
- [ ] Update `state/active-context.json` — currentTask: "Personal Assistant Setup — Phase 6"
- [ ] Commit: `git commit -m "setup: sync scripts written — Phase 6 complete"`

---

## Phase 7 — LaunchAgents [ ]

**Goal:** Make everything run automatically in the background.

For each LaunchAgent (see `PERSONAL-ASSISTANT-SETUP.md` Phase 6 for plist format):

- [ ] `com.pa.email-sync` → `sync-email.ts` every 15 min
- [ ] `com.pa.calendar-sync` → `sync-calendar.ts` every 15 min
- [ ] `com.pa.todo-sync` → `sync-todos.ts` every 15 min
- [ ] `com.pa.email-analysis` → `analyze-emails.ts` every 1 hour
- [ ] `com.pa.embed-emails` → `embed-emails.ts` every 1 hour
- [ ] `com.pa.calendar-suggestions` → `generate-suggestions.ts` every 4 hours
- [ ] `com.pa.brain-dump` → `brain-dump.sh` every 2 hours
- [ ] `com.pa.discord-digest` → `discord-digest.ts` daily at 7am (or your human's preferred time)

For each plist:
- Use full paths (`/opt/homebrew/bin/npx`, not `npx`)
- Pass all credentials via `EnvironmentVariables` key (never hardcode)
- Load: `launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.pa.<name>.plist`

Verify all loaded:
```bash
launchctl list | grep com.pa
```

- [ ] Update `state/active-context.json` — currentTask: "Personal Assistant Setup — Phase 7"
- [ ] Commit: `git commit -m "setup: LaunchAgents installed — Phase 7 complete"`

---

## Phase 8 — Validation [ ]

**Goal:** Confirm everything is working end-to-end before declaring done.

Run each of these checks. Do not skip any.

- [ ] Total Recall: `openclaw memory search "test query"` returns semantic results
- [ ] Email sync: `padata.db` has rows in `emails` table with recent timestamps
- [ ] Email not marked as read: verify in your human's Outlook that synced emails are still unread
- [ ] Calendar sync: `padata.db` has rows in `calendar_events` table
- [ ] Embeddings: `embeddings.db` has rows in `email_embeddings`
- [ ] Brain dump: Obsidian vault has `Brain/MEMORY-Mirror.md` with current content
- [ ] LaunchAgents all loaded: `launchctl list | grep com.pa` shows 8 entries
- [ ] Daily digest: trigger manually, confirm it delivers to the right channel with useful content
- [ ] Full loop test: ask your human a question that requires email context — confirm you can answer it using semantic search

---

## Introduce Yourself

Once Phase 8 passes, send your human a message:

- What you've set up and what's now running in the background
- What you'll do each morning (digest)
- What you'll proactively flag (urgent emails, due items, calendar conflicts)
- One thing you noticed during setup that you want to ask them about
- Ask: *"What do you want to tackle first?"*

---

## Archive This File

```bash
mkdir -p memory/archive && mv CONFIGURE.md memory/archive/CONFIGURE.md
git add -A && git commit -m "setup: CONFIGURE.md archived — build complete"
git push
```

Then update `MEMORY.md` with a summary of the setup, and update `state/active-context.json` with `currentTask: "Live — personal assistant fully configured"`.

You're live. Go be useful.
