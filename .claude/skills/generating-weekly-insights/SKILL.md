---
name: generating-weekly-insights
description: Generate an end-of-week SA activity insights report from Langfuse trace data
arguments: none
---

# Weekly Insights Report

Generate an end-of-week activity and learning insights report.

## Voice

This is an **internal deliverable**. Follow `@sa-persona.md` — internal voice. Reflective, honest, actionable. Not customer-facing. Use first person ("you did X", "pattern emerging around Y"). Be direct about what worked and what didn't.

## Instructions

### Step 1: Extract Data from Langfuse

Run the data extraction script to pull the past week's activity:

```bash
templates/weekly-insights-extract.sh \
    --days 7 \
    --output-dir insights
```

If the script fails (missing env vars, Langfuse unreachable), fall back to reading the Langfuse state file at `~/.claude/state/langfuse_state.json` and the recent transcript `.jsonl` files in `~/.claude/projects/` to reconstruct activity manually.

### Step 2: Read the Extracted Data

Read both output files:
- `insights/weekly_insights_YYYYMMDD.json` — structured data
- `insights/weekly_insights_YYYYMMDD.md` — human-readable summary

### Step 3: Read Prior Insights (if they exist)

Check `insights/` for previous weekly reports. Look for patterns that span multiple weeks — recurring topics, persistent gaps, improvement trends.

### Step 4: Analyze and Generate Report

Write the report to `insights/YYYY-MM-DD-weekly-insights.md` using today's date.

## Report Template

```markdown
# Weekly Insights — Week of {start_date}

**Generated:** {date}
**Coverage:** {start_date} to {end_date}

---

## This Week at a Glance

- **{N} sessions** across **{M} customers/projects**
- **{top_customer}** was the heaviest engagement ({turns} turns)
- **{top_skill}** was the most-used skill ({count}x)
- {one_sentence_headline — e.g., "Heavy week on query optimization, lighter on new assessments"}

---

## Customer Activity

| Customer | Sessions | Turns | What Was Done |
|----------|----------|-------|---------------|
| {customer} | {n} | {n} | {brief — e.g., "Query optimization benchmarks, assessment delivery"} |

### Engagement Depth
- **Deep engagements** (>10 turns): {list — indicates complex problems}
- **Quick hits** (1-3 turns): {list — indicates routine lookups or simple responses}

---

## What Worked Well

- {Observation about a skill/workflow that performed well — e.g., "The benchmark script + assessment skill combo produced a polished Acme Corp deliverable in one pass"}
- {Observation about an effective pattern}

## What Didn't Work / Friction Points

- {Observation about something that required lots of iteration, re-tries, or manual editing}
- {Gap identified — e.g., "No skill for X, had to write it manually"}

---

## Patterns Emerging

### Topics
- {Recurring topic — e.g., "Third week in a row with ORDER BY / primary key questions. Consider a dedicated guide."}
- {Topic cluster — e.g., "Several customers asking about refreshable MVs — the pattern is becoming standard."}

### Customer Anti-Patterns
- {If the same ClickHouse anti-pattern appeared across multiple customers, call it out — e.g., "Two customers this week with unique-ID ORDER BY keys. The schema-pk rules caught both, but consider a specific Slack template for this."}

### Tool/Skill Usage
- {Observation about tool usage — e.g., "Heavy docs-research usage (15x) suggests lots of investigative work this week vs. known-pattern application."}
- {Underused tool/skill — e.g., "/drafting-follow-up only used once despite 4 customer calls. Consider making it a habit."}

---

## Lessons Learned

### Technical
- {Specific technical lesson — e.g., "ClickHouse GROUPING SETS blocks projections (confirmed in Acme Corp engagement). Added to mental model."}
- {Edge case discovered}

### Process
- {Process improvement — e.g., "Running benchmarks BEFORE writing the assessment saved a full revision cycle"}
- {Workflow insight}

### Rules/Skills to Update
- [ ] {Specific improvement — e.g., "Add a rule about CTE inlining behavior causing 10x regression with multi-reference CTEs"}
- [ ] {New skill idea — e.g., "Create a /reviewing-queries skill for one-off query optimization requests"}
- [ ] {Existing skill tweak — e.g., "Assessment skill needs a section for 'What We Tested' (methodology) — customers keep asking"}

---

## Improvement Areas

### As an SA
- {Self-improvement insight — e.g., "Spent too long on Q3 optimization when the MV was the obvious answer. Bias toward 'live' solutions."}
- {Knowledge gap to fill}

### For the Sidekick
- {System improvement — e.g., "Weekly insights workflow needs Langfuse dashboard queries for faster data pull"}
- {Automation opportunity}

---

## Next Week Focus

- {Priority — e.g., "Follow up on Acme Corp MV staleness decision"}
- {Planned improvement — e.g., "Codify the benchmark workflow into reusable templates"}
- {Learning goal — e.g., "Deep-dive on ClickHouse query cache behavior for the next optimization engagement"}

---

*Reflect. Iterate. Compound.*
```

## Analysis Guidelines

When generating the report, follow these principles:

1. **Be honest about friction** — If a skill produced bad output or a workflow was clunky, say so. That's how improvements get identified.

2. **Look for compounding patterns** — Things that appeared in 2+ sessions are patterns. Things that appeared in 3+ weeks are trends. Call them out differently.

3. **Connect customer work to learning** — Every engagement teaches something. Extract the lesson, not just the activity log.

4. **Identify rule/skill gaps** — If you had to explain something from scratch that should have been a rule or template, that's a gap. Flag it with a specific action item.

5. **Track improvement velocity** — Compare to prior weeks if available. Are sessions getting shorter for similar tasks? Are fewer manual edits needed? That's the system getting better.

6. **Don't fabricate insights** — If the data is thin (few sessions, limited variety), say so. "Light week — not enough data for pattern detection" is a valid finding.

## Checklist

- [ ] Data extraction script ran successfully (or fallback used)
- [ ] All customer engagements from the week are accounted for
- [ ] At least 2 "lessons learned" identified (technical + process)
- [ ] At least 1 actionable improvement item for rules/skills
- [ ] Compared to prior week if prior report exists
- [ ] Report saved to `insights/YYYY-MM-DD-weekly-insights.md`
