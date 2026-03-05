---
name: drafting-slack-response
description: Generate a concise, customer-friendly Slack response
arguments: optional customer-name or topic
---

# ClickHouse Slack Response

Generate a concise Slack response for: **$ARGUMENTS**

## Instructions

1. If a full assessment exists, summarize key points
2. Keep response under 500 words (ideal: 200-300)
3. Lead with the answer/recommendation
4. Include copy-paste SQL when relevant
5. End with clear next steps

## Voice

This is a **customer-facing deliverable**. Follow `@sa-persona.md` — deliverable voice, **Slack channel**.

- **Mirror the customer's tone** — if they're casual, match it. If they opened with "hey", respond with "Hey [Name]!"
- **Pick up their language** — if they said "our ingestion pipeline is choking", use "pipeline" and "choking" in your response, not "data loading process is experiencing issues"
- **Casual by default** — Slack is a conversation, not a document. No sign-off needed.

## Response Template

```markdown
Hey [Name]!

[1-2 sentence TL;DR — the answer, not the preamble]

**Why it happens**: [Root cause in plain terms, ClickHouse jargon is fine]

**The fix**: [What to do, with context on why]

```sql
-- Copy-paste ready, not fragments
ALTER TABLE ...
```

**Verify it's working**:
```sql
EXPLAIN indexes=1 SELECT ...
```

[If version-dependent]: Note: This requires ClickHouse X.X+

**Quick checklist**:
- [ ] [Action item]
- [ ] [Action item]

[If need more info]:
To nail this down, could you share:
- [Specific question]
- [Specific question]

Happy to dig deeper / Let me know if you want to hop on a call.
```

## Slack-Specific Structure

- Keep response under 500 words (ideal: 200-300)
- Lead with TL;DR — the answer, not the preamble
- Include copy-paste SQL when relevant
- End with clear next steps or engagement offer

## Common Patterns

### Quick Schema Advice
```markdown
Hey [Name]! For [use case], I'd recommend:

```sql
ORDER BY (col1, col2, col3)
```

This works because [brief explanation]. Per `schema-pk-*` best practices, [key point].
```

### Query Optimization
```markdown
The slow performance is due to [root cause].

Try this instead:
```sql
-- Optimized query
```

This avoids [problem] by [solution]. Verify with:
```sql
EXPLAIN indexes=1 SELECT ...
```
```

### Need More Info
```markdown
Hey [Name]! To nail this down I need a bit more context:

1. What's your ClickHouse version? (Cloud or self-managed?)
2. Can you share the table DDL (`SHOW CREATE TABLE`)?
3. What's your typical query pattern?

In the meantime, the general guidance is [brief answer with caveat].
```

## Checklist

- [ ] Response is under 500 words
- [ ] SQL examples are copy-paste ready
- [ ] Clear next steps provided
- [ ] Version requirements noted if applicable
- [ ] Voice matches `@sa-persona.md` deliverable voice
