---
name: researching-documentation
description: Perform thorough multi-pass documentation research with gap analysis for ClickHouse questions
arguments: question
---

# ClickHouse Documentation Research

Perform comprehensive documentation research for: **$ARGUMENTS**

## Purpose

This skill enforces a systematic multi-pass search approach to:
- Find documented facts across multiple related topics
- Identify documentation gaps explicitly
- Distinguish between documented facts and inferences
- Discover related concepts that single queries miss

## Instructions

### Step 1: Decompose the Question

Break down the question into 4-5 specific sub-questions. ALWAYS include:

1. **Direct query**: The literal question being asked
2. **Privilege/Permission query**: Related access control or privileges (if applicable)
3. **Alternative approaches**: Other ways to accomplish the same goal
4. **Settings/Configuration**: Relevant server or session settings
5. **Version-specific behavior**: Version requirements or behavioral changes

**Example decomposition** for "What privilege is required for ALTER TABLE DROP PARTITION?":
- "DROP PARTITION privilege ClickHouse"
- "ALTER TABLE privileges hierarchy ClickHouse"
- "DETACH PARTITION vs DROP PARTITION ClickHouse"
- "partition management permissions ClickHouse"
- "ALTER privilege requirements ClickHouse"

### Step 2: Execute Parallel Searches

**MANDATORY**: Use the MCP tool `mcp__clickhouse-docs__search_clickhouse_knowledge_sources` to run ALL sub-questions **simultaneously** (parallel tool calls).

Record the number of results for each query.

### Step 3: Analyze Results for Gaps

After receiving search results, explicitly check:

- [ ] Is the direct answer documented?
- [ ] Are privilege requirements clearly stated?
- [ ] Is there a hierarchy or inheritance documented?
- [ ] Are there undocumented assumptions?
- [ ] What related topics are mentioned but not explained?

### Step 4: Follow-up Searches

Run additional searches for:
- Concepts mentioned in initial results that need clarification
- Alternative terminology discovered
- Related settings or features referenced

### Step 5: Synthesize Findings

Categorize all findings into:
- **Documented** (high confidence) - Direct quotes/references with URLs
- **Inferred** (medium confidence) - Logical deductions from documented facts
- **Gaps** (unknown) - Questions that cannot be answered from docs

## Output Template

```markdown
# Documentation Research: $ARGUMENTS

## Search Strategy

### Sub-questions Generated
| # | Query | Results |
|---|-------|---------|
| 1 | [Query text] | [# results or "no results"] |
| 2 | [Query text] | [# results or "no results"] |
| 3 | [Query text] | [# results or "no results"] |
| 4 | [Query text] | [# results or "no results"] |
| 5 | [Query text] | [# results or "no results"] |

---

## Documented Facts (High Confidence)

These findings come directly from official documentation:

| Finding | Source URL |
|---------|------------|
| [Fact 1] | [URL] |
| [Fact 2] | [URL] |

### Key Documentation Excerpts

> [Direct quote from docs]
> — Source: [URL]

---

## Inferences (Medium Confidence)

Logical deductions based on documented patterns:

| Inference | Reasoning |
|-----------|-----------|
| [Inference 1] | Based on [documented fact], we can infer... |
| [Inference 2] | By analogy with [similar feature]... |

---

## Documentation Gaps

Information that **cannot be found** in official documentation:

- [ ] [Gap 1: What's missing and why it matters]
- [ ] [Gap 2: What's missing and why it matters]

### Recommendations for Gaps
- [How to work around or verify the gap - e.g., test in dev, check source code, ask community]

---

## Follow-up Searches

Additional searches triggered by initial findings:

| Discovered Concept | Query | Results |
|-------------------|-------|---------|
| [Concept] | [Query] | [Summary of findings] |

---

## Answer

### Confidence Level: [High / Medium / Low]

[Clear answer to the original question]

### Caveats
- [Any limitations or version dependencies]
- [Gaps that affect the answer]

### Verification Steps
- [How to verify this answer in practice]
```

## When to Use This Skill

- Complex documentation questions where a single search is insufficient
- Questions involving privileges, permissions, or access control
- Questions about feature interactions or compatibility
- Any question where the first search didn't provide a complete answer
- When performing customer assessments (invoked automatically by `/drafting-technical-assessment`)

## Checklist Before Completing

- [ ] Generated at least 4 sub-questions
- [ ] Ran parallel searches for ALL sub-questions
- [ ] Explicitly identified documentation gaps
- [ ] Distinguished documented facts from inferences
- [ ] Provided confidence level for the answer
- [ ] Included verification steps
