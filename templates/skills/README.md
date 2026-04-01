# SA Sidekick Skills - Team Distribution

Setup instructions for new SAs adopting the ch-sa-sidekick skill set.

## Quick Setup

1. **Copy all skills** from the main repo's `.claude/skills/` into your project's `.claude/skills/`
2. **Personalize** the one identity-specific skill (see below)
3. **Copy `sa-persona.md`** to your repo root and customize the voice/name
4. **Copy `.claude/rules/`** for the ClickHouse analysis workflow and customer file conventions

## Identity-Specific Skills

Only **1 skill** references the SA by name and needs personalization:

| Skill | What to change |
|-------|---------------|
| `drafting-post-meeting-followup` | Replace `"Best,\nDoneyli"` with your name on lines containing sign-off instructions |

All other 19 skills use `[Your Name]` or are identity-agnostic.

## Personalization Script

```bash
# Replace SA name in the one skill that needs it
SA_NAME="Your Name Here"
sed -i '' "s/Doneyli/$SA_NAME/g" .claude/skills/drafting-post-meeting-followup/SKILL.md
```

## Required MCP Servers

For full functionality, configure these MCP servers:

| MCP Server | Used By | How to Enable |
|------------|---------|---------------|
| **ClickHouse Docs** | `researching-documentation`, `drafting-technical-assessment`, `reviewing-architecture` | `claude mcp add clickhouse-docs` |
| **Slack** | `analyzing-slack-thread`, `drafting-slack-response` | Add via Claude Code MCP settings |
| **Notion** | `drafting-post-meeting-followup`, meeting notes | Add via Claude Code MCP settings |
| **Google Calendar** | `drafting-post-meeting-followup` | `claude mcp add gcal` |
| **Gmail** | `drafting-post-meeting-followup` | `claude mcp add gmail` |

Skills degrade gracefully without MCPs - they'll fall back to local files or ask you for input.

## Skills That Work Standalone (No MCP Required)

These skills only need local files in `customers/` folders:

- `analyzing-call-transcript`
- `converting-sql`
- `drafting-benchmark-assessment`
- `drafting-email-response`
- `drafting-migration-guide`
- `drafting-poc-plan`
- `drafting-slack-response`
- `drafting-training-notes`
- `executing-benchmark`
- `generating-diagrams`
- `generating-weekly-insights`
- `preparing-meeting`
- `reviewing-architecture`
- `reviewing-configuration`
- `reviewing-queries`
- `tracking-follow-up-items`
