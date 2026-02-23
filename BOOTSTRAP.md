# BOOTSTRAP.md — Day 1 Setup

You just woke up. This is your birth certificate. Read it, do what it says, then archive it.

---

## Step 1: Figure Out Who You Are

Read these files in order:
1. `SOUL.md` — your persona, values, and how you operate
2. `IDENTITY.md` — your name and vibe
3. `USER.md` — who you're helping

If any of these files have unfilled `[brackets]`, note them and ask your human to fill them in.

---

## Step 2: Check Your Environment

Run a quick self-orientation:
- What tools do you have access to? (check available skills)
- Is git configured? (`git config user.email`)
- Is Obsidian CLI working? (`obsidian-cli print-default`)
- What's your OpenClaw agent ID and model?

---

## Step 3: Initialize Memory

Your memory starts blank. Seed it:
1. Open `MEMORY.md` — fill in what you know from `USER.md` and `SOUL.md`
2. Update `state/active-context.json` with your current task: `"First-run setup"`
3. Ask your human: *"What's the most important thing I should know about your business right now?"*
4. Ask: *"What's the one thing you most want help with?"*
5. Commit: `git commit -m "memory: initial seed from first-run setup"`

---

## Step 4: Set Up Obsidian (2nd Brain)

1. Open the `obsidian-scaffold/` folder as a vault in Obsidian (File → Open Folder as Vault)
2. Move/rename it to your preferred location (e.g. `~/Documents/MyBrain/`)
3. Run `obsidian-cli set-default "[vault-folder-name]"` to configure the CLI
4. Update `MEMORY.md` section 6 with the vault path
5. Run `obsidian-cli print-default` to verify

---

## Step 5: Introduce Yourself

Send your human a message introducing yourself:
- Your name
- What you're set up to help with
- One thing you noticed in the setup that you want to ask about
- Ask what they want to tackle first

Keep it short. Business first.

---

## Step 6: Archive This File

Once setup is complete, move this file:
```bash
mkdir -p memory/archive && mv BOOTSTRAP.md memory/archive/BOOTSTRAP.md
```

Then commit:
```bash
git add -A && git commit -m "setup: bootstrap complete, archived BOOTSTRAP.md"
git push
```

---

You're live. Go be useful.
