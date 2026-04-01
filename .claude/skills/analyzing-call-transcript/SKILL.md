---
name: analyzing-call-transcript
description: Extract structured information from a customer call transcript. Use when processing meeting notes, when a call recording or transcript needs summarization, when extracting action items or decisions from a call, or when you need structured notes from any customer conversation.
arguments: customer-name
model: sonnet
---

# Call Transcript Analysis

Extract structured notes from a call transcript for: **$ARGUMENTS**

## Voice

This is an **internal deliverable** (sidekick → SA). Follow `@sa-persona.md` — internal voice. Structured extraction, not customer-facing. Flag important items, attribute quotes to speakers, defer on next steps.

## Instructions

1. **Load transcript from `/customers/$ARGUMENTS/`** — Look for:
   - `call-transcripts/` subfolder
   - Any file with "transcript", "call", "meeting", or "notes" in the name
   - PDF files (may contain exported transcripts)
   - Files with recent dates that contain conversation-style content

2. **Extract structured information** — Follow the template below. Focus on:
   - What was decided (not what was discussed)
   - Specific technical requirements (numbers, features, constraints)
   - Action items with owners
   - Anything that sounded like a concern or objection

3. **Do NOT invoke `/clickhouse-best-practices` or `/researching-documentation`** — This is extraction, not analysis. Technical analysis happens in a follow-up skill.

4. **Write output** — Save to `/customers/$ARGUMENTS/YYYY-MM-DD-call-analysis.md` using today's date.

## Output Template

```markdown
# Call Analysis: $ARGUMENTS

**Date:** YYYY-MM-DD
**Status:** Active
**Issue:** Call transcript analysis — [call topic]

## Status Updates
- **YYYY-MM-DD** — Original creation

---

## Call Metadata

| Field | Value |
|-------|-------|
| Call Date | [Date of the call, not today's date] |
| Duration | [If known] |
| Attendees | [Names and roles — ours and theirs] |
| Topic | [One-line topic] |
| Recording/Transcript Source | [Zoom, Gong, manual notes, etc.] |

---

## Key Decisions Made

[Decisions that were agreed upon during the call — not suggestions, not discussions, actual decisions.]

- **[Decision]** — [Who decided, brief context]
- **[Decision]** — [Who decided, brief context]

*If no firm decisions were made, state that explicitly.*

---

## Technical Requirements Mentioned

[Specific numbers, features, and constraints heard during the call]

| Requirement | Detail | Speaker | Confidence |
|-------------|--------|---------|------------|
| Data volume | [X TB / X rows] | [Who said it] | Firm / Approximate / Aspirational |
| Latency target | [X ms / X sec] | [Who said it] | Firm / Approximate / Aspirational |
| [Feature need] | [Detail] | [Who said it] | Firm / Approximate / Aspirational |

---

## Open Questions

[Questions that were asked but not answered, or explicitly deferred]

- [ ] **[Question]** — Asked by [who], deferred because [reason]
- [ ] **[Question]** — Came up in context of [topic], needs follow-up

---

## Action Items

| # | Action | Owner | Deadline | Status |
|---|--------|-------|----------|--------|
| 1 | [Action] | [Name] | [Date or "TBD"] | Open |
| 2 | [Action] | [Name] | [Date or "TBD"] | Open |

---

## Customer Concerns / Objections

[Anything that sounded like pushback, worry, hesitation, or risk aversion]

- **[Concern]**: [What they said, paraphrased. Who said it.]
- **[Concern]**: [What they said, paraphrased. Who said it.]

*If none detected, state "No significant concerns raised."*

---

## Opportunities

[Signals for expansion, upsell, deeper engagement, or technical deep-dives]

- **[Signal]**: [What was said that suggests this opportunity]
- **[Signal]**: [What was said that suggests this opportunity]

---

## Suggested Next Steps

[What skill to invoke next based on the call content]

- **Immediate**: [e.g., "/drafting-follow-up $ARGUMENTS" to send summary email]
- **Short-term**: [e.g., "/drafting-technical-assessment $ARGUMENTS" if technical deep-dive was requested]
- **If applicable**: [e.g., "/preparing-meeting $ARGUMENTS" for the next call]

---

## Raw Quotes

[Key verbatim quotes worth referencing later — for proposals, follow-ups, or internal context]

> "[Exact quote]"
> — [Speaker], on [topic]

> "[Exact quote]"
> — [Speaker], on [topic]
```

## Checklist

- [ ] All speakers identified with roles
- [ ] Every action item has an owner assigned
- [ ] No key decisions missed (cross-check with action items)
- [ ] Technical requirements include specific numbers where mentioned
- [ ] Concerns/objections captured with attribution
- [ ] Suggested next steps include specific skill recommendations
