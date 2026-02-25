# Suru-PA — Personal Assistant Template for OpenClaw

A battle-tested template for deploying OpenClaw as a personal AI assistant for business owners and executives.

Built from real-world use. Not a proof-of-concept.

---

## What This Gives You

- **Memory architecture** that survives context resets (compaction-proof)
- **Executive Assistant + CFO persona** — direct, opinionated, owner-minded
- **2nd Brain integration** via Obsidian — long-term knowledge storage that grows over time
- **Proactive heartbeat system** — periodic check-ins, never intrusive
- **Agent workflow patterns** — multi-agent coordination, PM decomposition, cost tracking
- **Startup prompt** — paste once, the assistant orients itself and gets to work

## Quickstart

```bash
curl -fsSL https://raw.githubusercontent.com/sudobot99/suru-pa/main/bootstrap.sh | bash
```

That's it. The one-liner installs everything, deploys the workspace, and walks you through OpenClaw onboarding.

**What you need beforehand:**
- macOS (Apple Silicon or Intel) — Linux support planned
- [Obsidian](https://obsidian.md) installed (for 2nd brain)
- API keys ready for: [Anthropic](https://console.anthropic.com), [OpenAI](https://platform.openai.com), or [Google AI Studio](https://aistudio.google.com) — the onboarding wizard will ask for them

**After the one-liner completes:**

1. **Fill in the workspace files:**
   - `~/.openclaw/workspace/USER.md` — who you're helping (name, business, contact info)
   - `~/.openclaw/workspace/SOUL.md` — adjust the persona (`{{owner_name}}`, `{{business_type}}`, `{{industry}}`)
   - `~/.openclaw/workspace/IDENTITY.md` — assistant name and vibe
   - `~/.openclaw/workspace/TOOLS.md` — local setup specifics (SSH hosts, devices, passwords manager)

2. **Set up Obsidian** — open `~/Documents/SecondBrain` as a vault in Obsidian, then run:
   ```bash
   obsidian-cli set-default "SecondBrain"
   ```

3. **Paste the startup prompt** (from `STARTUP-PROMPT.md`) into your OpenClaw chat. The assistant orients itself, reads its files, and gets to work.

4. **Seed MEMORY.md** — add business context, key people, infrastructure. The more you put in, the faster it gets useful.

## File Structure

```
├── setup.sh              # ← Run this first. Installs everything.
├── BOOTSTRAP.md          # First-run instructions (assistant reads this on day 1)
├── SOUL.md               # Persona and tone
├── USER.md               # Who you're helping
├── IDENTITY.md           # Assistant name and vibe
├── AGENTS.md             # Workflow directives + agent roster
├── HEARTBEAT.md          # Proactive monitoring config
├── MEMORY.md             # Long-term memory skeleton
├── TOOLS.md              # Local setup notes
├── STARTUP-PROMPT.md     # Paste this into OpenClaw on first run
├── state/
│   └── active-context.json   # Compaction survival kit
├── prompts/
│   └── pm-system-prompt.md   # PM decomposition workflow
├── obsidian-scaffold/    # Vault folder structure to copy into Obsidian
└── scripts/
    └── brain-dump-cron.md    # Instructions for setting up the brain dump automation
```

## Going Deeper

The base install gives you a smart assistant with memory. If you want the full stack — email + calendar intelligence, vector search over your inbox, semantic memory (Total Recall), and a living 2nd Brain in Obsidian — read the full setup guide:

**[→ Personal Assistant Setup Guide](PERSONAL-ASSISTANT-SETUP.md)**

Covers: M365 integration, database schemas, background automations, Total Recall configuration, Obsidian vault structure, agent roster, and a validation checklist.

---

## Philosophy

The value isn't in the data — it's in the architecture. Memory that survives resets. A persona that doesn't sycophant. An assistant that delegates instead of blocking. Obsidian as a growing brain that outlasts any single session.

Day 1 it knows your name. Week 2 it knows your business.

---

Built by [Suru Solutions](https://surusol.com). Runs on [OpenClaw](https://openclaw.ai).
