---
name: drafting-follow-up
description: Generate follow-up questions and action items after an assessment or call
arguments: customer-name
---

# ClickHouse Follow-Up

Generate follow-up for: **$ARGUMENTS**

## Instructions

1. Review the existing assessment or call notes
2. Identify gaps in information
3. List pending action items
4. Create file at `/customers/$ARGUMENTS/follow-up.md`

## Follow-Up Template

```markdown
# Follow-Up: $ARGUMENTS

**Date**: [Date]
**Context**: [Assessment / Discovery call / Technical deep-dive / Slack thread]

---

## Summary of Last Interaction

[2-3 sentences summarizing what was discussed/analyzed]

---

## Outstanding Questions

### Critical (Blocking Recommendations)
- [ ] **[Question]** - Needed to finalize [recommendation/decision]
- [ ] **[Question]** - Needed to finalize [recommendation/decision]

### Important (Improves Recommendations)
- [ ] [Question] - Would help with [aspect]
- [ ] [Question] - Would help with [aspect]

### Nice to Have
- [ ] [Question] - For completeness

---

## Information Requested

| Item | Format | Why Needed |
|------|--------|------------|
| Table DDL | `SHOW CREATE TABLE` output | Schema analysis |
| Query examples | SQL with actual column names | Optimization |
| EXPLAIN output | `EXPLAIN indexes=1` result | Index usage validation |
| Query log sample | system.query_log export | Performance analysis |
| Error messages | Full error text | Debugging |

---

## Action Items

### Our Actions
- [ ] [Action] - Owner: [Name] - Due: [Date]
- [ ] [Action] - Owner: [Name] - Due: [Date]

### Customer Actions
- [ ] [Action] - [Why needed]
- [ ] [Action] - [Why needed]

### Pending Decisions
- [ ] [Decision needed] - Waiting on: [Information/Person]

---

## Recommendations Status

| Recommendation | Status | Notes |
|----------------|--------|-------|
| [Recommendation 1] | Pending info / Ready / Implemented | [Notes] |
| [Recommendation 2] | Pending info / Ready / Implemented | [Notes] |

---

## Next Steps

1. [ ] [Immediate next step]
2. [ ] [Following step]
3. [ ] Schedule follow-up: [Date/trigger]

---

## Follow-Up Message Draft

[Optional: Draft Slack/email message to send to customer]

---

Hi [Name],

Following up on [our discussion / the assessment]. A few things:

**Questions**:
1. [Question]
2. [Question]

**Action items from our side**:
- [What we're doing]

**Recommended next steps**:
- [What they should do]

Let me know if you have any questions!

---
```

## Follow-Up Triggers

Generate a follow-up when:
- Assessment is complete but info is missing
- Customer hasn't responded in [X days]
- Implementation deadline is approaching
- New information changes recommendations

## Checklist

- [ ] Reviewed prior assessment/notes
- [ ] Questions are specific and actionable
- [ ] Action items have clear owners
- [ ] Next steps are defined
