# Brain Dump Cron — Setup Guide

This automation periodically syncs your assistant's MEMORY.md and active-context.json into your Obsidian vault for long-term storage and searchability.

## What It Does

Every 2 hours:
1. Reads `MEMORY.md` and `state/active-context.json`
2. Writes a summary note to Obsidian at `Automations/Brain Dump YYYY-MM-DD.md`
3. Runs `git add -A && git commit && git push` on the Obsidian vault

## Setup

### Option A: OpenClaw Cron Job (recommended)

Add via OpenClaw (or ask your assistant to set it up):
```json
{
  "name": "brain-dump",
  "schedule": "0 */2 * * *",
  "task": "Read MEMORY.md and state/active-context.json. Write a concise summary note to Obsidian at 'Automations/Brain Dump YYYY-MM-DD.md'. Append if file exists for today. Then git add, commit, and push the vault. Use mode: none for delivery.",
  "delivery": { "mode": "none" }
}
```

### Option B: macOS LaunchAgent

1. Create `~/Library/LaunchAgents/com.yourassistant.braindump.plist`
2. Set the script to call: `openclaw run "brain dump to obsidian"`
3. Set `StartInterval` to `7200` (2 hours)
4. Load with `launchctl load ~/Library/LaunchAgents/com.yourassistant.braindump.plist`

## Notes

- The assistant needs `obsidian-cli` installed and a default vault set
- Obsidian vault should be a git repo for version history
- The cron should run silently — no notifications unless there's an error
