---
name: drafting-post-meeting-followup
description: End-to-end post-meeting workflow - find transcript, extract action items, research docs, draft and send follow-up email. Use after any customer call, when you need to send meeting notes, when extracting action items from a call, or when the full post-meeting pipeline needs to run (transcript to email).
arguments: customer-name [meeting-date]
allowed-tools: Bash, Read, Write
model: opus
---

# Post-Meeting Follow-Up

Automated post-meeting workflow for: **$ARGUMENTS**

## Voice

The call analysis artifact is an **internal deliverable** (sidekick -> SA). The follow-up email is a **customer-facing deliverable**. Follow `@sa-persona.md` - deliverable voice, **email channel**.

## Prerequisites

Before starting, check these integrations in order:

1. **Customer folder**: Ensure `customers/{customer-name}/` exists. Create it if missing.
2. **Transcript source**: At least one must be available - Notion MCP, `gws` CLI, or a transcript file already in the customer folder.
3. **ClickHouse Docs MCP**: Checked later in Step 4 only if needed (standard connectivity check).

## Instructions

### Parse Arguments

Extract from `$ARGUMENTS`:
- `customer-name` (required) - first argument
- `meeting-date` (optional) - second argument, defaults to today (YYYY-MM-DD). Accept natural language ("yesterday", "last tuesday") and resolve to YYYY-MM-DD.

---

### Step 1: Find the Meeting and Attendees

**Goal:** Get the meeting title, date, time, and attendee list (names + emails).

**Try in order:**

1. **Google Calendar MCP** (if `gcal.mcp.claude.com` is configured):
   - Search for calendar events matching the customer name on the meeting date
   - Extract: event title, attendee names and emails, start/end time
   - This is the most reliable source for the attendee list

2. **Notion meeting notes** (if Calendar MCP is unavailable):
   - Use `mcp__plugin_Notion_notion__notion-query-meeting-notes` filtered by date and customer name
   - Extract attendees from the notes content if listed

3. **Fallback**: Ask the user:
   > Could not find a calendar event for {customer-name} on {date}. Please provide:
   > - Meeting title
   > - Attendee names and emails (comma-separated)

---

### Step 2: Find and Load the Transcript

**Goal:** Get the full meeting transcript/notes content.

**Search in this order:**

1. **Local files first** - Check `customers/{customer-name}/call-transcripts/` and `customers/{customer-name}/` for files matching the date with "transcript", "call", "meeting", or "notes" in the name.

2. **Notion MCP** - Use `mcp__plugin_Notion_notion__notion-query-meeting-notes` filtered by date and customer name in title. If found, use `mcp__plugin_Notion_notion__notion-fetch` to get full content.

3. **Notion broader search** - Use `mcp__plugin_Notion_notion__notion-search` with query `"{customer-name} meeting"` or `"{customer-name} notes"`.

4. **Google Drive via `gws` CLI** (if installed) - Search for docs matching `"Notes by Gemini"` with the customer name or meeting title:
   ```bash
   gws drive files list --q "name contains 'Notes by Gemini' and name contains '{customer-name}'" --order-by "modifiedTime desc" --page-size 5
   ```
   Then fetch the doc content:
   ```bash
   gws docs get {document-id} --format text
   ```

5. **Fallback**: Ask the user:
   > Could not find a transcript for {customer-name} on {date} in Notion or Google Drive.
   > Options:
   > - Paste the transcript content here
   > - Provide a file path to the transcript
   > - Download the Gemini notes from Drive and save to `customers/{customer-name}/call-transcripts/`

**If transcript is found in multiple sources**, prefer the most complete version (usually the Gemini notes from Drive have the full transcript, while Notion may have a summary).

---

### Step 3: Analyze the Transcript

**Goal:** Extract structured information from the transcript.

Apply the `analyzing-call-transcript` methodology:

1. Extract all structured information per the call analysis template:
   - Call metadata (date, duration, attendees, topic, source)
   - Key decisions made
   - Technical requirements with confidence levels
   - Open questions with deferral reasons
   - Action items with owners and deadlines
   - Customer concerns/objections with attribution
   - Opportunities for expansion
   - Raw verbatim quotes worth referencing

2. **Save output** to `customers/{customer-name}/YYYY-MM-DD-call-analysis.md`

3. **Identify ClickHouse-specific topics** that need documentation backing for the follow-up email. Examples:
   - Customer asked about a specific feature or configuration
   - A recommendation was made that should link to official docs
   - A migration or schema change was discussed

---

### Step 4: Research Documentation (Conditional)

**Skip this step** if no ClickHouse-specific topics were identified in Step 3.

**If topics need doc backing:**

1. **MCP connectivity check** (mandatory) - Test with `mcp__clickhouse-docs__search_clickhouse_knowledge_sources` query `"ClickHouse MergeTree"`.
   - If it fails: warn the user per standard protocol. Do NOT silently fall back to web search.

2. **For each topic**, apply the `researching-documentation` methodology:
   - Decompose into sub-questions
   - Execute parallel MCP searches
   - Collect official doc URLs and key findings
   - Tag every finding with source (MCP / Web / General) and URL

3. **Compile a doc links table** for use in the email:
   | Topic | URL | Brief Description |
   |-------|-----|-------------------|
   | {topic} | {url} | {one-line summary} |

---

### Step 5: Draft the Follow-Up Email

**Goal:** Generate a Gmail-ready HTML follow-up email.

Apply the `drafting-email-response` methodology with these specific requirements:

**Recipients:** Use the attendee list from Step 1. Address the primary customer contact by first name.

**Content structure:**
1. **Opener**: "Hi {Name}," then "Following up on our call today - here's a summary of what we covered and next steps."
2. **Meeting summary**: 2-3 sentences covering the key topics discussed and decisions made
3. **Action items table**: From Step 3, formatted as an HTML table with columns: #, Action, Owner, Deadline
4. **Documentation links**: From Step 4 (if any), formatted as a section with linked topic names and brief descriptions
5. **Next steps**: Specific next actions with owners
6. **Closer**: Offer to dig deeper or hop on another call
7. **Sign-off**: "Best,\nDoneyli"

**Style rules:**
- Follow the full HTML template from `drafting-email-response` (inline CSS, ClickHouse yellow accents, dark SQL blocks)
- No em dashes - use regular dashes, colons, or reword
- Paragraphs over bullets for email readability
- Tables for structured data
- No bot-speak anti-patterns (see `@sa-persona.md`)

**Save output** to `customers/{customer-name}/YYYY-MM-DD-followup-email.html`

---

### Step 6: Save Master Follow-Up Document

**Save** the master tracking document to `customers/{customer-name}/YYYY-MM-DD-post-meeting-followup.md` using the template below.

---

### Step 7: Review and Send

1. **Present the email** to the user for review:
   > Follow-up email drafted for {customer-name} ({date}).
   >
   > **To:** {attendee emails}
   > **Subject:** Following up - {meeting topic}
   >
   > Artifacts saved:
   > - `customers/{customer-name}/YYYY-MM-DD-call-analysis.md`
   > - `customers/{customer-name}/YYYY-MM-DD-followup-email.html`
   > - `customers/{customer-name}/YYYY-MM-DD-post-meeting-followup.md`
   >
   > Review the email HTML in your browser, then let me know:
   > - **Send** - I'll send via Gmail (if Gmail MCP is configured)
   > - **Edit** - Tell me what to change
   > - **Manual** - You'll copy-paste into Gmail yourself

2. **If Gmail MCP is configured** (`gmail.mcp.claude.com`) and user says "send":
   - Send the email via Gmail MCP to the attendee list
   - Update the master document status to "Sent"

3. **If Gmail MCP is NOT configured**:
   - Tell the user: "Open the HTML file in a browser, select all, and paste into Gmail compose."

4. **Optional Slack summary** - If the user requests it, post a condensed summary to the customer's Slack channel via Slack MCP.

---

## Master Follow-Up Document Template

```markdown
# Post-Meeting Follow-Up: {customer-name}

**Date:** YYYY-MM-DD
**Status:** Active
**Issue:** Post-meeting follow-up - {meeting topic}

## Status Updates
- **YYYY-MM-DD** - Original creation

---

## Meeting Metadata

| Field | Value |
|-------|-------|
| Meeting Date | {date} |
| Duration | {if known} |
| Meeting Title | {title} |
| Attendees (ClickHouse) | {names} |
| Attendees (Customer) | {names and emails} |
| Transcript Source | {Notion / Google Drive / Manual} |

---

## Meeting Summary

{2-3 sentence summary of what was discussed and decided}

---

## Action Items

| # | Action | Owner | Deadline | Status |
|---|--------|-------|----------|--------|
| 1 | {action} | {name} | {date or TBD} | Open |

---

## Documentation Links Shared

| Topic | URL | Source |
|-------|-----|--------|
| {topic} | {url} | {MCP / Web} |

*If no documentation research was needed, state "No ClickHouse-specific topics required doc backing."*

---

## Follow-Up Email

| Field | Value |
|-------|-------|
| Subject | {subject line} |
| Recipients | {email list} |
| Status | Drafted / Sent / Pending review |
| File | `YYYY-MM-DD-followup-email.html` |

---

## Artifacts Generated

| File | Description |
|------|-------------|
| `YYYY-MM-DD-call-analysis.md` | Structured transcript analysis |
| `YYYY-MM-DD-post-meeting-followup.md` | This file |
| `YYYY-MM-DD-followup-email.html` | Gmail-ready follow-up email |
```

## Error Handling

| Failure | Detection | Recovery |
|---------|-----------|----------|
| Customer folder missing | `ls` fails | Create it automatically, continue |
| Calendar MCP unavailable | Tool not available or returns error | Ask user for meeting details |
| No transcript found (any source) | All search strategies return empty | Ask user to paste or provide file path. Do NOT proceed without content. |
| Notion MCP down | Search/query call fails | Warn user, try Google Drive, then ask for manual transcript |
| ClickHouse Docs MCP down | Connectivity check fails | Warn user per standard protocol. Draft email without doc links or get explicit approval for web search. |
| Gmail MCP not configured | Tool not available | Save HTML file, instruct user to copy-paste into Gmail |
| `gws` CLI not installed | `which gws` fails | Skip Drive search, rely on Notion and local files |

## Setup Requirements (One-Time)

These integrations enable full automation. The skill works with degraded functionality without them:

| Integration | Purpose | How to Enable |
|-------------|---------|---------------|
| **Google Calendar MCP** | Auto-discover meetings and attendees | Add `gcal.mcp.claude.com` via `claude mcp add` |
| **Gmail MCP** | Send follow-up email directly | Add `gmail.mcp.claude.com` via `claude mcp add` |
| **Google Workspace CLI** | Read Gemini notes from Drive | Install from `github.com/googleworkspace/cli`, authenticate with OAuth |
| **Notion MCP** | Read meeting notes from Notion | Already configured |
| **ClickHouse Docs MCP** | Research documentation links | Already configured |
| **Slack MCP** | Post optional Slack summary | Already configured |

## Checklist

- [ ] Meeting attendees identified with names and emails
- [ ] Transcript found and loaded from at least one source
- [ ] Call analysis saved to customer folder
- [ ] All action items have owners assigned
- [ ] Documentation research completed for ClickHouse-specific topics (if any)
- [ ] Every doc link has a source tag and URL
- [ ] Follow-up email HTML uses inline CSS only
- [ ] Email opens correctly in browser preview
- [ ] No em dashes in any output
- [ ] Voice matches `@sa-persona.md` deliverable voice (email channel)
- [ ] Sign-off present ("Best,\nDoneyli")
- [ ] All three artifacts saved to customer folder
- [ ] User reviewed and approved email before sending
