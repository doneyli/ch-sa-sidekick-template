# SA Sidekick Template

An AI-powered SA tooling system built on [Claude Code](https://docs.anthropic.com/en/docs/claude-code). Acts as a junior Solutions Architect — does the docs research, drafts customer deliverables, enforces ClickHouse best practices, and provides structured workflows for every SA deliverable type.

The SA makes the architecture calls. The sidekick does the legwork.

## Quick Start

### 1. Create your project from this template

Click **"Use this template"** on GitHub, or:

```bash
git clone https://github.com/YOUR_ORG/ch-sa-sidekick-template.git my-sa-sidekick
cd my-sa-sidekick
```

### 2. Install external dependencies

The sidekick relies on two external components that are not bundled in this repo:

**ClickHouse Best Practices Rules** (28 curated rules, installed globally):

```bash
npx skills add clickhouse/agent-skills
```

This installs the `/clickhouse-best-practices` skill globally. Multiple skills in this repo invoke it automatically during analysis — it's the first step in every technical assessment.

**ClickHouse Docs MCP Server** (live documentation search):

```bash
claude mcp add --transport sse clickhouse-docs https://knowledge.clickhouse.com/mcp/sse
```

This gives the sidekick direct access to ClickHouse documentation via the `mcp__clickhouse-docs__search_clickhouse_knowledge_sources` tool. The `/researching-documentation` skill and analysis rules depend on it.

### 3. Set up your voice profile

```bash
cp sa-persona.example.md sa-persona.md
```

Edit `sa-persona.md` with your name, voice patterns, and communication style. This single file controls the tone of every customer-facing output the sidekick generates.

### 4. Start using it

```bash
claude
```

Try: *"Review this query: SELECT * FROM events WHERE user_id = 123"*

## Skills (18)

### Research & Analysis

| Skill | What It Does |
|-------|-------------|
| `/researching-documentation` | Multi-pass doc search with parallel sub-queries and gap analysis |
| `/analyzing-call-transcript` | Extract structured info from call transcripts — decisions, action items, follow-ups |

### Intake & Prep

| Skill | What It Does |
|-------|-------------|
| `/analyzing-slack-thread` | Load Slack context → structured situation analysis |
| `/preparing-meeting` | Meeting prep — questions, agenda, red flags to listen for |

### Customer Deliverables

| Skill | What It Does |
|-------|-------------|
| `/drafting-technical-assessment` | Full technical assessment — root cause, rules check, recommendations, rollback |
| `/drafting-slack-response` | Concise Slack reply in SA voice with copy-paste SQL |
| `/drafting-email-response` | HTML email, Gmail copy-paste ready |
| `/reviewing-queries` | Lightweight query optimization — quick wins |
| `/drafting-benchmark-assessment` | MD + HTML optimization report from benchmark data |
| `/drafting-migration-guide` | Step-by-step migration with rollback strategy |
| `/reviewing-architecture` | Deployment review with Green/Yellow/Red scoring |
| `/reviewing-configuration` | ClickHouse configuration audit against best practices |
| `/drafting-poc-plan` | POC milestones, success criteria, timeline |
| `/converting-sql` | Convert SQL from Snowflake/Postgres/MySQL/BigQuery to ClickHouse |
| `/drafting-training-notes` | Workshop content by skill level |
| `/drafting-follow-up` | Post-call action items and follow-up draft |

### Operations

| Skill | What It Does |
|-------|-------------|
| `/generating-weekly-insights` | End-of-week activity report from Langfuse traces |
| `/generating-diagrams` | Architecture diagrams as native `.drawio` files |

## External Dependencies

These are **not included** in this repo and must be installed separately:

| Dependency | Install Command | Used By |
|-----------|----------------|---------|
| [clickhouse/agent-skills](https://github.com/clickhouse/agent-skills) | `npx skills add clickhouse/agent-skills` | `/reviewing-queries`, `/drafting-technical-assessment`, `/reviewing-configuration`, `/converting-sql`, `/reviewing-architecture`, `/drafting-benchmark-assessment`, analysis rules |
| [ClickHouse Docs MCP](https://knowledge.clickhouse.com/mcp/sse) | `claude mcp add --transport sse clickhouse-docs https://knowledge.clickhouse.com/mcp/sse` | `/researching-documentation`, analysis rules |

## Project Structure

```
my-sa-sidekick/
├── CLAUDE.md                        # AI operating manual
├── sa-persona.md                    # Your voice profile (create from .example)
├── sa-persona.example.md            # Voice profile template
├── .claude/
│   ├── rules/                       # Auto-loaded analysis workflow rules
│   └── skills/                      # 18 slash-command workflows
├── templates/
│   ├── benchmark-query-optimization.sh   # Manifest-driven query benchmark
│   ├── benchmark-assessment-email.html   # HTML email template
│   ├── weekly-insights-extract.sh        # Langfuse data extraction
│   └── ...
├── customers/                       # Per-customer folders (gitignored)
└── insights/                        # Weekly reports (gitignored)
```

## Workflows

### Query Optimization Benchmark
1. Create `benchmark.manifest` in the customer folder (see `templates/benchmark.manifest.example`)
2. Run `templates/benchmark-query-optimization.sh --manifest <manifest> --host <host> --password <pw>`
3. Run `/drafting-benchmark-assessment <customer-name>` to generate the report

### Weekly Insights
1. Run `templates/weekly-insights-extract.sh --days 7 --output-dir insights/`
2. Run `/generating-weekly-insights` to generate the narrative report


