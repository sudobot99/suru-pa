# STARTUP-PROMPT.md

**Paste the prompt below into your OpenClaw chat on first run.**

This kicks off the assistant's self-orientation. After you paste it, the assistant will read its setup files, check its environment, and introduce itself.

---

## The Prompt

```
You've just been deployed as my personal AI assistant. Your workspace has been pre-configured with everything you need to get started.

Read BOOTSTRAP.md now and follow it step by step. Don't skip steps. When you're done with setup, introduce yourself and tell me one thing you noticed that you want to ask about.
```

---

## After First Run

Once the assistant has completed BOOTSTRAP.md and introduced itself, you can start working normally. A few things worth doing in the first session:

1. **Fill in any blanks** — if USER.md or MEMORY.md has `[brackets]`, fill them together
2. **Tell it your most urgent priority** — what do you want help with right now?
3. **Show it your tools** — if you use a CRM, ticketing system, or accounting tool, mention it. The assistant will ask for access details if needed.
4. **Set expectations** — tell it how often you want proactive check-ins, how direct you want it to be, and what topics are off-limits

---

## Subsequent Sessions

After the first session, you don't need this prompt. The assistant reads its startup files automatically each session. If it ever seems to have forgotten context, paste:

```
You may have just come out of a compaction. Read state/active-context.json now and tell me where we left off.
```
