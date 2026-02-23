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

## What You Need

- macOS (Apple Silicon or Intel) — Linux support planned
- [Obsidian](https://obsidian.md) installed (for 2nd brain) — the setup script handles everything else
- API keys for: [Anthropic](https://console.anthropic.com), [OpenAI](https://platform.openai.com), [Google AI Studio](https://aistudio.google.com)

## Quickstart

1. **Clone this repo:**
   ```bash
   git clone https://github.com/sudobot99/suru-pa.git ~/suru-pa && cd ~/suru-pa
   ```

2. **Run the setup script** — installs all dependencies and deploys the workspace:
   ```bash
   bash setup.sh
   ```
   **Installs:** OpenClaw, Claude Code CLI, Codex CLI, Gemini CLI, GitHub CLI, 1Password CLI, obsidian-cli, Node.js v22. Configures git, sets up Obsidian vault, and deploys template files to your OpenClaw workspace.

3. **Fill in the blanks** — edit these files:
   - `USER.md` — who you're helping
   - `IDENTITY.md` — name and personality for the assistant
   - `SOUL.md` — adjust tone, industry focus, key duties
   - `TOOLS.md` — add local setup specifics (SSH hosts, devices, etc.)

3. **Set up Obsidian** — open the `obsidian-scaffold/` folder as an Obsidian vault, then rename/move to your preferred location. Update `MEMORY.md` section 7 with the vault path.

4. **Paste the startup prompt** (from `STARTUP-PROMPT.md`) into your OpenClaw chat. The assistant will orient itself.

5. **Seed MEMORY.md** — add your business context, key people, infrastructure. The more you put in, the faster it gets useful.

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

## Philosophy

The value isn't in the data — it's in the architecture. Memory that survives resets. A persona that doesn't sycophant. An assistant that delegates instead of blocking. Obsidian as a growing brain that outlasts any single session.

Day 1 it knows your name. Week 2 it knows your business.

---

Built by [Suru Solutions](https://surusol.com). Runs on [OpenClaw](https://openclaw.ai).
