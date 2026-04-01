---
name: drafting-email-response
description: Generate an HTML email response for a customer (Gmail copy-paste ready). Use when replying to a customer email, sending assessment results via email, composing a follow-up email, or when any customer communication needs to go via email rather than Slack.
arguments: customer-name or topic
model: sonnet
---

# Email Response

Generate an HTML email response for: **$ARGUMENTS**

## Voice

This is a **customer-facing deliverable**. Follow `@sa-persona.md` - deliverable voice, **email channel**. Slightly more formal than Slack. Still direct, still concise, still ClickHouse-native.

## Instructions

1. If a full assessment or prior context exists in `customers/$ARGUMENTS/`, read it first
2. Lead with the answer or key result  - no throat-clearing
3. Use tables for any structured data (benchmarks, action items, comparisons)
4. Include copy-paste ready SQL in `<pre>` blocks when relevant
5. End with clear next steps and action items (table format if >2 items)
6. Write the output as a single `.html` file in the customer folder

## Output

Write to: `customers/$ARGUMENTS/YYYY-MM-DD-email-response.html`

The HTML must be:
- **Gmail-safe**  - inline CSS only, no external resources, no `<head>` stylesheet
- **Self-contained**  - opens correctly in any browser for preview
- **Copy-paste ready**  - select all in browser, paste into Gmail compose, formatting preserved

## HTML Template

Read `references/email-template.html` for the full HTML template with inline CSS, ClickHouse yellow accents, dark SQL blocks, tables, callout boxes, and footnotes. Use it as the structural foundation for every email.

## Color Palette (ClickHouse brand-aligned)

| Element | Color | Usage |
|---------|-------|-------|
| **Yellow accent** | `#FADB14` | Section header underlines, TL;DR callout border |
| **TL;DR background** | `#FFFBE6` | Cream background for TL;DR callout |
| **Positive results** | `#0d7c3d` | Green text for good metrics, improvements |
| **Code background** | `#1e1e1e` | Dark theme for SQL `<pre>` blocks |
| **Code text** | `#d4d4d4` | Light text on dark code blocks |
| **SQL keywords** | `#569cd6` | Blue for SELECT, FROM, WHERE, etc. |
| **SQL comments** | `#6a9955` | Green for `-- comments` |
| **Inline code** | `#f0f0f0` bg | Light gray for `<code>` in prose |
| **Table headers** | `#f5f5f5` bg | Light gray for `<th>` rows |
| **Alternating rows** | `#fafafa` bg | Subtle zebra striping |
| **Body text** | `#1a1a1a` | Near-black for readability |
| **Secondary text** | `#666` | Footnotes, metadata, caveats |
| **Callout box** | `#f8f8f8` bg, `#e0e0e0` border | Grouped info, cleanup SQL, notes |

## Formatting Rules

- **Headers**: `<h3>` with `border-bottom: 1px solid #FADB14`  - ClickHouse yellow underline
- **Tables**: Inline styles on every element (Gmail strips `<style>` blocks). Alternating rows with `background: #fafafa`
- **SQL blocks**: Dark theme (`#1e1e1e`) with syntax highlighting via inline `<span>` styles. Keywords blue (`#569cd6`), comments green (`#6a9955`)
- **Inline code**: `<code>` with `background: #f0f0f0` for column names, settings, functions in prose
- **Emphasis**: `<strong>` for key numbers. Green (`#0d7c3d`) for positive results in table cells
- **Callout boxes**: `background: #f8f8f8` with border  - use for cleanup SQL, grouped caveats, notes
- **Footnotes**: `font-size: 12px; color: #666` for methodology notes, benchmark conditions
- **No images, no external CSS, no JavaScript**

## Email-Specific Tone

- **Opener**: "Hi [Name]," or "Hi Team," - not "Hey"
- **Sign-off**: "Best,\n[Your Name]" - always include
- **Paragraphs over bullets** - email reads better with short paragraphs than raw bullet lists
- **Tables for data** - never dump raw numbers in prose; always tabulate
- **Reference prior context**: "Following up on...", "As discussed..."
- **Still direct** - no fluff, no preamble, lead with the result
- **Still ClickHouse-native** - jargon is fine, no dumbing down
- **No em dashes** - use regular dashes (-), colons, or reword. Never use the " -" character.

## Checklist

- [ ] HTML uses inline CSS only (no `<style>` block in `<head>`)
- [ ] Opens correctly in browser (preview before delivering)
- [ ] SQL examples are copy-paste ready
- [ ] Tables used for any structured data
- [ ] Clear next steps / action items included
- [ ] Sign-off present ("Best,\n[Your Name]")
- [ ] Voice matches `@sa-persona.md` deliverable voice (email channel)
- [ ] File saved to customer folder with date prefix
