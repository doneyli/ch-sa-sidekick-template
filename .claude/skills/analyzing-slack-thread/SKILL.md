---
name: analyzing-slack-thread
description: Load customer context and produce a structured situation analysis from Slack threads. Use when a customer posts a question, when triaging a support thread, when analyzing a Slack conversation before responding, or when you need to understand the full context of a customer interaction.
arguments: customer-name
model: sonnet
---

# Slack Thread Intake

Build context and produce a situation analysis for: **$ARGUMENTS**

## Voice

This is an **internal deliverable** (sidekick → SA). Follow `@sa-persona.md` — internal voice. Present options with tradeoffs, flag unknowns, defer architecture decisions. Do NOT produce a customer response — that's the SA's call.

## Instructions

1. **Read ALL files in `/customers/$ARGUMENTS/`** — Build full context:
   - Slack threads / conversation files (look for `slack-`, `thread-`, or files with conversation content)
   - Prior assessments, reviews, follow-ups
   - DDL, schema files, query files
   - Call transcripts, meeting notes
   - Any config files or benchmark results

2. **Identify the most recent conversation** — Find the newest Slack thread or conversation file by date prefix (`YYYY-MM-DD-*`). This is the active question.

3. **Cross-reference prior context** — Check if we've already addressed parts of this question in earlier files. Note what's new vs. what's a follow-up.

4. **Produce the intake summary** — Write to `/customers/$ARGUMENTS/YYYY-MM-DD-intake.md` using today's date.

5. **Do NOT produce a customer response** — End with a suggested next step (which skill to invoke). The SA decides whether and how to respond.

## Output Template

```markdown
# Intake: $ARGUMENTS

**Date:** YYYY-MM-DD
**Status:** Active
**Issue:** Intake and situation analysis — [one-line summary of the active question]

## Status Updates
- **YYYY-MM-DD** — Original creation

---

## Customer Snapshot

| Field | Value |
|-------|-------|
| Company | [Name] |
| ClickHouse Version | [Version or Unknown — flag if unknown] |
| Deployment | Cloud / Self-managed / Unknown |
| Engagement History | [Brief: first contact, N interactions, ongoing optimization, etc.] |
| Key Tables | [Main tables mentioned across files] |

---

## What They're Asking

[Distill the actual question from the thread. Strip the noise. If there are multiple questions, enumerate them. If the question is ambiguous, note the ambiguity.]

1. **Primary question**: [The main thing they need answered]
2. **Secondary question**: [If applicable]
3. **Implicit question**: [What they didn't ask but probably need to know]

---

## Prior Context

[What we've already told this customer across all prior interactions. Reference specific files.]

- **[YYYY-MM-DD-file.md]**: [What was covered, key recommendations made]
- **[YYYY-MM-DD-file.md]**: [What was covered, outstanding items]
- **Outstanding items**: [Anything we promised or they asked about that's still open]

---

## Technical Situation

### Schema Summary
```sql
-- Key DDL (abbreviated — full DDL in customer folder)
```

### Known Issues
- [Anti-patterns already identified in prior reviews]
- [Rule violations already flagged]

### New Information
- [What's new in this thread that we haven't seen before]

---

## Suggested Response Approach

**Recommended skill**: `/skill-name` — [Why this skill fits]

**Key points to address**:
1. [Point to cover in the response]
2. [Point to cover in the response]
3. [Point to cover in the response]

**Tone note**: [Any tone considerations — e.g., "They seem frustrated, acknowledge the issue before diving into fixes" or "They're technically savvy, skip the basics"]

---

## Open Questions

[What's missing before we can give a solid response. These might need to go back to the customer.]

- [ ] [Missing information — e.g., "We don't have their ClickHouse version"]
- [ ] [Missing information — e.g., "No DDL provided for the table they're querying"]
- [ ] [Ambiguity — e.g., "Unclear if they want a quick fix or a structural redesign"]
```

## Checklist

- [ ] All files in `/customers/$ARGUMENTS/` were read
- [ ] Most recent conversation/thread identified
- [ ] Actual question distilled (not just thread summary)
- [ ] Prior context cross-referenced — no repeat recommendations
- [ ] Suggested response approach includes specific skill recommendation
- [ ] Open questions listed for anything blocking a solid response
