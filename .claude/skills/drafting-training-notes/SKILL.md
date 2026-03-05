---
name: drafting-training-notes
description: Generate training/workshop content for customer enablement
arguments: customer-name or topic
---

# ClickHouse Training Notes

Generate training content for: **$ARGUMENTS**

## Instructions

1. Identify the audience level (beginner, intermediate, advanced)
2. Focus on practical, hands-on content
3. Include exercises and examples
4. Create file at `/customers/$ARGUMENTS/training-notes.md` or `/training/[topic].md`

## Training Notes Template

```markdown
# Training: $ARGUMENTS

**Date**: [Date]
**Audience**: [Team/role]
**Level**: [Beginner / Intermediate / Advanced]
**Duration**: [X hours]

---

## Learning Objectives

By the end of this session, participants will be able to:
1. [Objective 1 - action verb + outcome]
2. [Objective 2]
3. [Objective 3]

---

## Prerequisites

- [ ] ClickHouse access (version X.X+)
- [ ] Basic SQL knowledge
- [ ] [Other prerequisites]

---

## Agenda

| Time | Topic | Type |
|------|-------|------|
| [00:00] | Introduction & Overview | Lecture |
| [00:15] | [Topic 1] | Lecture + Demo |
| [00:45] | [Exercise 1] | Hands-on |
| [01:00] | [Topic 2] | Lecture + Demo |
| [01:30] | [Exercise 2] | Hands-on |
| [02:00] | Q&A and Wrap-up | Discussion |

---

## Module 1: [Topic Name]

### Key Concepts

**[Concept 1]**
[Explanation in 2-3 sentences]

**[Concept 2]**
[Explanation]

### Demo

```sql
-- Demo: [Description]
-- Step 1: [What we're showing]
SELECT ...

-- Step 2: [What we're showing]
SELECT ...
```

### Key Takeaways
- [Point 1]
- [Point 2]
- [Point 3]

---

## Module 2: [Topic Name]

### Key Concepts

[Content]

### Demo

```sql
-- Demo queries
```

### Key Takeaways
- [Points]

---

## Exercises

### Exercise 1: [Title]

**Objective**: [What participants will practice]

**Setup**:
```sql
-- Create sample table
CREATE TABLE training_exercise_1 ...
```

**Tasks**:
1. [Task description]
   ```sql
   -- Hint: Use ...
   ```

2. [Task description]

3. [Task description]

**Solution** (for instructor):
```sql
-- Solution queries
```

### Exercise 2: [Title]

[Same structure]

---

## Common Questions

**Q: [Frequently asked question]?**
A: [Answer]

**Q: [Question]?**
A: [Answer]

---

## Best Practices Covered

| Topic | Best Practice | Rule Reference |
|-------|---------------|----------------|
| [Topic] | [Practice] | `rule-name` |
| [Topic] | [Practice] | `rule-name` |

---

## Resources

### Documentation
- [Topic](URL) - Official docs
- [Topic](URL) - Official docs

### Practice Datasets
- [Dataset name] - [Description]
- [Dataset name] - [Description]

### Further Learning
- [Resource] - [Description]
- [Resource] - [Description]

---

## Appendix: Reference Commands

### Useful Queries
```sql
-- Check table size
SELECT
    table,
    formatReadableSize(sum(bytes_on_disk)) as size,
    sum(rows) as rows
FROM system.parts
WHERE active
GROUP BY table
ORDER BY sum(bytes_on_disk) DESC;

-- Check query performance
SELECT
    query,
    query_duration_ms,
    read_rows,
    read_bytes
FROM system.query_log
WHERE type = 'QueryFinish'
ORDER BY event_time DESC
LIMIT 10;
```

### Useful Settings
```sql
-- See query plan
SET allow_experimental_analyzer = 1;  -- If version supports
EXPLAIN PLAN SELECT ...;

-- Profile query
SET send_logs_level = 'trace';
```

---

## Feedback

[Space for participant feedback or instructor notes]
```

## Training Topics Library

### Beginner Topics
- ClickHouse Overview & Architecture
- Basic SQL in ClickHouse
- Understanding MergeTree
- Basic Schema Design
- Getting Started with Inserts

### Intermediate Topics
- Primary Key Design
- Partitioning Strategies
- Query Optimization Basics
- Materialized Views
- Working with Arrays and Nested

### Advanced Topics
- Advanced Query Optimization
- Distributed Tables
- Projections
- Performance Tuning
- Operational Best Practices

## Checklist

- [ ] Learning objectives are measurable
- [ ] Content matches audience level
- [ ] Demos are tested and working
- [ ] Exercises have clear instructions
- [ ] Solutions provided for instructor
- [ ] Resources are current
