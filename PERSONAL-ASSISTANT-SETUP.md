# Personal Assistant Setup Guide

This is a setup framework for configuring OpenClaw as a full personal assistant — with email + calendar intelligence, semantic memory search (Total Recall), and a 2nd Brain in Obsidian. It is designed to be read and executed by the AI itself during initial setup.

---

## Before You Start

### Prerequisites Checklist

- [ ] macOS machine (Apple Silicon preferred, Intel OK)
- [ ] OpenClaw installed and gateway running (`openclaw gateway status`)
- [ ] Anthropic API key configured in OpenClaw
- [ ] Obsidian installed (`https://obsidian.md`)
- [ ] Microsoft 365 account with access to mail + calendar
- [ ] A Discord server (or other messaging channel) for daily digests + alerts
- [ ] Git + GitHub account for workspace backup
- [ ] (Optional) Local inference: Apple Silicon Mac or NVIDIA GPU with vLLM running

### Decisions to Make First

1. **What is this machine's name/role?** (e.g. "Home Mac", "Work Mac") — used in IDENTITY.md
2. **What messaging channel?** Discord or Telegram recommended
3. **Do you have local inference available?** If yes, note the base URL and model name
4. **Where will the Obsidian vault live?** Default: `~/Documents/SecondBrain`

---

## Phase 1 — Workspace Identity

Set up who this assistant is and who it's helping.

### Checklist

- [ ] Fill in `USER.md` completely — name, pronouns, family, timezone, business, goals, communication style
- [ ] Customize `SOUL.md` — replace all `{{placeholders}}` with real values. Adjust tone, duties, and financial focus to match the person
- [ ] Fill in `IDENTITY.md` — assistant name and personality descriptor
- [ ] Fill in `TOOLS.md` — password manager vault name, key machines, installed tools, GitHub username
- [ ] Commit everything: `git commit -m "setup: workspace identity configured"`

### Notes

- SOUL.md is the most important file. Spend time on it. A generic soul = a generic assistant.
- USER.md is what the assistant reads to understand context. More detail = fewer clarifying questions.
- TOOLS.md is a cheat sheet, not documentation. Add what's useful, skip the rest.

---

## Phase 2 — Memory System

Set up long-term memory and Total Recall (semantic search).

### Checklist

- [ ] Seed `MEMORY.md` with initial context:
  - Key people (family, colleagues, important relationships)
  - Business/work context (employer, role, key tools)
  - Goals (personal and professional)
  - Infrastructure (machines, key services, credentials location)
  - Anything the assistant should never forget
- [ ] Update `state/active-context.json` with current task: `"Initial setup"`
- [ ] Commit: `git commit -m "memory: initial seed"`
- [ ] Push workspace to GitHub (create a private repo for this): `git remote add origin <url> && git push -u origin main`

### Total Recall (Semantic Memory Search)

Total Recall indexes your workspace files into a vector store so the assistant can semantically search memory — not just keyword match.

To enable it, add to `openclaw.json` under agent config:

```
memorySearch.embedding: <provider>:<base_url>:<model_id>
```

Options:
- **Cloud (easiest):** Use OpenAI embeddings (`text-embedding-3-small`) — costs fractions of a cent
- **Local (free):** Point to a local vLLM or MLX-LM server running an embedding model
  - Recommended: `mlx-community/Qwen3-Embedding-8B-mxfp8` on Apple Silicon (4096 dims, high quality)
  - Lightweight alternative: `nomic-embed-text` or `mxbai-embed-large`

Run `openclaw memory reindex` after configuring to build the initial index.

---

## Phase 3 — Obsidian 2nd Brain

Set up the structured knowledge vault that survives beyond any single session.

### Checklist

- [ ] Create the vault directory: `~/Documents/SecondBrain/` (or preferred location)
- [ ] Set it as the default vault: `obsidian-cli set-default "SecondBrain"`
- [ ] Open in Obsidian: File → Open Folder as Vault → select the directory
- [ ] Create the base folder structure:
  - `Brain/` — MEMORY.md mirror + active context (auto-updated)
  - `People/` — profiles for key relationships
  - `Projects/` — active and archived projects
  - `Decisions/` — architecture and decision log
  - `Business/` — work/business context (customize to your situation)
  - `Research/` — notes, articles, saved content
  - `Automations/` — documentation for background automations
- [ ] Create `Decisions/Architecture Log.md` — document setup decisions here as you go
- [ ] Commit vault to a private GitHub repo for backup: `git init && git remote add origin <url>`
- [ ] Install `brain-dump` LaunchAgent (see Phase 6) so MEMORY.md auto-mirrors to vault every 2 hours

---

## Phase 4 — M365 Integration (Email + Calendar)

Connect Microsoft 365 for email and calendar intelligence.

### App Registration in Azure Entra

You need to register an app in Azure to get API access to mail and calendar.

- [ ] Go to: `https://portal.azure.com` → Azure Active Directory → App registrations → New registration
- [ ] Name: `OpenClaw Personal Assistant` (or similar)
- [ ] Account type: Single tenant
- [ ] No redirect URI needed (client credentials flow)
- [ ] After creation, note: **Application (client) ID** and **Directory (tenant) ID**
- [ ] Create a client secret: Certificates & secrets → New client secret → note the value immediately (won't show again)
- [ ] Add Graph API Application Permissions (not Delegated):
  - `Mail.Read` — read emails
  - `Mail.ReadWrite` — if you want sync to mark items (optional)
  - `Calendars.ReadWrite` — read + write calendar events
  - `Tasks.ReadWrite.All` — read/write To-Do tasks (requires admin consent)
  - `User.Read.All` — resolve user info
- [ ] Grant admin consent for all permissions
- [ ] Store credentials securely (1Password recommended)

### Sync Scripts to Install

These scripts run on a schedule via LaunchAgents (see Phase 6). You write them once, they run forever.

| Script | What it does | M365 endpoint |
|--------|-------------|--------------|
| `sync-email.ts` | Pulls new emails into `personal.db` using Graph delta | `/users/{id}/mailFolders/inbox/messages/delta` |
| `sync-calendar.ts` | Pulls calendar events (±90 days) using delta | `/users/{id}/calendarView/delta` |
| `sync-todos.ts` | Pulls To-Do tasks from all lists | `/users/{id}/todo/lists/{id}/tasks/delta` |

**Critical implementation notes:**
- Always use **delta queries** with stored delta links in `sync_state` table — never full sync on every run
- For `calendarView/delta`: use `Prefer: odata.maxpagesize=50` header instead of `$top=50` query param (`$top` is not supported on calendarView delta)
- Add `Prefer: outlook.body-content-type="text"` to all message fetch calls to prevent Exchange from marking emails as read
- Store credentials as environment variables, never hardcoded

---

## Phase 5 — Database Setup

Two databases. Keep them separate.

### `personal.db` — Operational Data

Create with the following tables:

```sql
CREATE TABLE emails (
  id TEXT PRIMARY KEY,
  conversation_id TEXT,
  subject TEXT,
  from_address TEXT,
  from_name TEXT,
  to_addresses TEXT,
  body_text TEXT,
  body_preview TEXT,
  received_at TEXT,
  is_read INTEGER DEFAULT 0,
  has_attachments INTEGER DEFAULT 0,
  importance TEXT,
  folder_id TEXT,
  has_question INTEGER,
  has_deadline INTEGER,
  deadline_date TEXT,
  sender_type TEXT,
  urgency_score REAL,
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE calendar_events (
  id TEXT PRIMARY KEY,
  subject TEXT,
  body_preview TEXT,
  start_time TEXT,
  end_time TEXT,
  location TEXT,
  is_all_day INTEGER DEFAULT 0,
  is_cancelled INTEGER DEFAULT 0,
  organizer_email TEXT,
  show_as TEXT,
  importance TEXT,
  response_status TEXT,
  is_recurring INTEGER DEFAULT 0,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE todo_tasks (
  id TEXT PRIMARY KEY,
  list_id TEXT,
  list_name TEXT,
  title TEXT,
  body_text TEXT,
  status TEXT,
  importance TEXT,
  due_date TEXT,
  reminder_date TEXT,
  completed_at TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  updated_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE calendar_suggestions (
  id TEXT PRIMARY KEY,
  source_type TEXT,
  source_id TEXT,
  suggested_title TEXT,
  suggested_start TEXT,
  suggested_end TEXT,
  suggested_duration_hours REAL,
  reason TEXT,
  confidence REAL,
  status TEXT DEFAULT 'pending',
  metadata TEXT,
  created_at TEXT DEFAULT (datetime('now')),
  reviewed_at TEXT,
  graph_event_id TEXT
);

CREATE TABLE email_response_stats (
  sender_address TEXT PRIMARY KEY,
  sender_name TEXT,
  total_received INTEGER DEFAULT 0,
  avg_response_hours REAL,
  last_received_at TEXT,
  last_responded_at TEXT,
  updated_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE sync_state (
  key TEXT PRIMARY KEY,
  value TEXT,
  updated_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE interest_signals (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  topic TEXT,
  signal_type TEXT,
  weight REAL DEFAULT 1.0,
  timestamp TEXT DEFAULT (datetime('now')),
  decay_factor REAL DEFAULT 0.95
);

CREATE TABLE discovery_feed (
  id TEXT PRIMARY KEY,
  title TEXT,
  url TEXT,
  source TEXT,
  summary TEXT,
  relevance_score REAL,
  date TEXT,
  clicked INTEGER DEFAULT 0,
  dismissed INTEGER DEFAULT 0,
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE TABLE preferences (
  key TEXT PRIMARY KEY,
  value TEXT,
  updated_at TEXT DEFAULT (datetime('now'))
);
```

### `embeddings.db` — Vector Search

```sql
CREATE TABLE email_embeddings (
  email_id TEXT PRIMARY KEY,
  body_text TEXT,
  embedding BLOB,
  model TEXT,
  dimensions INTEGER,
  created_at TEXT DEFAULT (datetime('now'))
);
```

**Notes:**
- Keep `embeddings.db` separate — it will grow large (email bodies + float32 vectors)
- Embedding model recommendation: `mlx-community/Qwen3-Embedding-8B-mxfp8` (4096 dims, Apple Silicon)
- Lightweight alternative: `nomic-embed-text` (768 dims, runs anywhere, good quality)
- Run embedding generation as a background job, not inline with sync

---

## Phase 6 — Background Automations (LaunchAgents)

These keep everything fresh without you thinking about it. Each is a macOS LaunchAgent — a plist file in `~/Library/LaunchAgents/` that runs on a schedule.

### Required LaunchAgents

| Label | Script | Interval | Purpose |
|-------|--------|----------|---------|
| `com.pa.email-sync` | `sync-email.ts` | 900s (15 min) | Pull new emails from M365 |
| `com.pa.calendar-sync` | `sync-calendar.ts` | 900s (15 min) | Pull calendar events from M365 |
| `com.pa.todo-sync` | `sync-todos.ts` | 900s (15 min) | Pull To-Do tasks from M365 |
| `com.pa.email-analysis` | `analyze-emails.ts` | 3600s (1 hr) | LLM-tag emails (questions, deadlines, urgency) |
| `com.pa.calendar-suggestions` | `generate-suggestions.ts` | 14400s (4 hr) | Generate calendar block suggestions from open items |
| `com.pa.brain-dump` | `brain-dump.sh` | 7200s (2 hr) | Mirror MEMORY.md + active-context to Obsidian |
| `com.pa.embed-emails` | `embed-emails.ts` | 3600s (1 hr) | Generate embeddings for new emails |
| `com.pa.discord-digest` | `discord-digest.ts` | Daily 7am | Morning briefing to Discord |

### LaunchAgent Checklist (per agent)

- [ ] Create plist in `~/Library/LaunchAgents/com.pa.<name>.plist`
- [ ] Use full paths for executables (`/opt/homebrew/bin/npx`, not `npx`)
- [ ] Set working directory to the project root (`WorkingDirectory` key)
- [ ] Pass required environment variables as `EnvironmentVariables` dict in plist
- [ ] Load with: `launchctl load ~/Library/LaunchAgents/com.pa.<name>.plist`
- [ ] Verify loaded: `launchctl list | grep com.pa`
- [ ] Test run: `launchctl kickstart -k gui/$(id -u)/com.pa.<name>`

### Brain Dump Script

The brain dump runs every 2 hours and does two things:
1. Copies the latest `MEMORY.md` verbatim into `~/SecondBrain/Brain/MEMORY-Mirror.md`
2. Formats `state/active-context.json` into a readable `~/SecondBrain/Brain/Active-Context.md`
3. Commits and pushes the vault if content changed

It's deterministic — no LLM, no API calls, always succeeds.

---

## Phase 7 — Agent Configuration

### Workspace Files for Each Agent

Each agent gets its own workspace copy. At minimum, non-main agents need:
- Their role defined in `AGENTS.md`
- Same `SOUL.md` and `USER.md` as main (for context)
- Read access to `MEMORY.md`

### Recommended Agents

| Agent | Model | Purpose | When to use |
|-------|-------|---------|-------------|
| `main` | Claude Sonnet or Gemini Flash | Primary coordinator | Always — this is the default |
| `opus-brain` | Claude Opus | Deep analysis, hard decisions | Complex reasoning, architecture decisions |
| `researcher` | Gemini Pro or Flash | Web research + synthesis | "Research X for me", "What's happening in Y" |
| `scribe` | Gemini Flash | Writing, notes, documentation | Drafts, summaries, Obsidian updates |

### Optional: Local Agents

If you have local inference (Apple Silicon Mac with MLX-LM or NVIDIA GPU with vLLM):

| Agent | Use Case | Minimum Hardware |
|-------|---------|-----------------|
| `local-coder` | Code tasks, scripts | M2 Pro / RTX 3080 |
| `local-analyst` | Long doc analysis, triage | M2 Max / RTX 3090 |

Local agents cost $0/token. Use them for high-volume or repetitive tasks (email triage, embedding generation, routine analysis). Use cloud agents for anything requiring best-in-class reasoning.

---

## Phase 8 — Messaging Channel

Connect OpenClaw to your preferred messaging app for alerts, digests, and conversation.

### Checklist

- [ ] Run `openclaw channels --help` to see available channel types
- [ ] Configure your preferred channel (Discord or Telegram recommended)
- [ ] Create a private server/group for personal use
- [ ] Set up at minimum these channels/threads:
  - `#general` — main conversation with the assistant
  - `#alerts` — urgent flags (due today, overdue items, anomalies)
  - `#digest` — daily morning briefing destination
  - `#research` — web research summaries, saved articles
- [ ] Test a message from the assistant: `openclaw agent "say hello and tell me what day it is"`

---

## Phase 9 — Validation Checklist

Run through these after setup to confirm everything is wired correctly.

### Memory
- [ ] `openclaw memory search "something from MEMORY.md"` returns relevant results (Total Recall working)
- [ ] Brain dump runs successfully: `bash scripts/brain-dump.sh`
- [ ] Obsidian vault has `Brain/MEMORY-Mirror.md` and `Brain/Active-Context.md`

### Email
- [ ] `sync-email.ts` runs without errors, ingests at least 1 email
- [ ] `personal.db` has rows in `emails` table
- [ ] Email does NOT get marked as read in Outlook after sync (verify in mail client)
- [ ] `embed-emails.ts` runs and generates vectors for new emails

### Calendar
- [ ] `sync-calendar.ts` runs without errors
- [ ] `personal.db` has rows in `calendar_events` table
- [ ] `sync-todos.ts` runs (may need `Tasks.ReadWrite.All` app permission in Azure)

### Automations
- [ ] All LaunchAgents loaded: `launchctl list | grep com.pa`
- [ ] No crash logs: `log show --predicate 'senderImagePath contains "launchd"' --last 1h | grep com.pa`

### Daily Digest
- [ ] `discord-digest.ts` runs without errors
- [ ] Digest appears in the correct channel
- [ ] Content is personalized (not generic)

---

## Known Gotchas

1. **`calendarView/delta` and `$top`** — Graph API does not support `$top` as a query param on calendar delta endpoints. Use `Prefer: odata.maxpagesize=50` as a header instead.

2. **To-Do tasks require admin consent** — The `Tasks.ReadWrite.All` permission in Graph API is an application permission and requires tenant admin consent. If the token works for mail but not tasks, this is why.

3. **Email marked as read** — Fetching email body content via Graph API can trigger Exchange's auto-read behavior. Always add `Prefer: outlook.body-content-type="text"` header to message fetch calls.

4. **LaunchAgent PATH issues** — LaunchAgents run in a minimal environment without your shell PATH. Always use full paths for every executable: `/opt/homebrew/bin/npx`, `/opt/homebrew/bin/node`, etc.

5. **Embedding dimensions must match** — If you change embedding models, you must wipe and re-generate all embeddings. The vector dimensions in the DB must be consistent.

6. **Delta links expire** — Graph API delta links expire after ~30 days of inactivity. If a sync script fails with a 410 Gone error, delete the delta link from `sync_state` and let it do a full sync on the next run.

7. **`set -e` in bootstrap scripts** — If the OpenClaw onboarding step exits non-zero (user cancels), the entire bootstrap script aborts. Wrap interactive steps with `|| true` if aborting is acceptable.

---

## File Structure Reference

```
~/.openclaw/workspace/
├── SOUL.md                    # Persona — customize per person
├── USER.md                    # Human context — fill in fully
├── IDENTITY.md                # Assistant name and vibe
├── AGENTS.md                  # Workflow directives + agent roster
├── HEARTBEAT.md               # Proactive check-in config
├── MEMORY.md                  # Long-term memory — keep updated
├── TOOLS.md                   # Local setup specifics
├── state/
│   └── active-context.json    # Current task state — update constantly
├── scripts/
│   ├── sync-email.ts          # M365 email sync
│   ├── sync-calendar.ts       # M365 calendar sync
│   ├── sync-todos.ts          # M365 To-Do sync
│   ├── analyze-emails.ts      # LLM email tagging
│   ├── embed-emails.ts        # Vector embedding generation
│   ├── generate-suggestions.ts # Calendar suggestion engine
│   ├── discord-digest.ts      # Daily morning briefing
│   └── brain-dump.sh          # MEMORY.md → Obsidian mirror
├── data/
│   ├── personal.db            # Operational data (email, calendar, tasks)
│   └── embeddings.db          # Email bodies + vectors
└── launchagents/
    ├── com.pa.email-sync.plist
    ├── com.pa.calendar-sync.plist
    ├── com.pa.todo-sync.plist
    ├── com.pa.email-analysis.plist
    ├── com.pa.embed-emails.plist
    ├── com.pa.calendar-suggestions.plist
    ├── com.pa.brain-dump.plist
    └── com.pa.discord-digest.plist
```

---

## Setup Order Summary

1. ✅ Phase 1 — Workspace identity (SOUL, USER, IDENTITY, TOOLS)
2. ✅ Phase 2 — Memory system (MEMORY.md seed + Total Recall config)
3. ✅ Phase 3 — Obsidian vault structure + git backup
4. ✅ Phase 4 — M365 app registration + Graph API permissions
5. ✅ Phase 5 — Create `personal.db` and `embeddings.db` with correct schemas
6. ✅ Phase 6 — Write and install all LaunchAgents
7. ✅ Phase 7 — Configure agents in openclaw.json
8. ✅ Phase 8 — Connect messaging channel
9. ✅ Phase 9 — Validate everything end-to-end

**Estimated setup time:** 2-4 hours for someone who knows what they're doing. Half of that is the Azure app registration and Graph API permissions.
