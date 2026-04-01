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

Style reference: see the HTML template below (based on real engagement deliverables)

```html
<!-- Date: YYYY-MM-DD | Status: Active | Issue: One-line summary -->
<!DOCTYPE html>
<html>
<body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; font-size: 14px; line-height: 1.6; color: #1a1a1a; max-width: 780px; margin: 0 auto; padding: 24px;">

<p>Hi [Name],</p>

<p>[1-2 sentence TL;DR  - the answer, the key result, or the update. Lead with impact.]</p>

<!-- TL;DR callout for major findings (optional  - use when leading with a headline metric) -->
<div style="background: #FFFBE6; border-left: 4px solid #FADB14; padding: 12px 16px; margin: 16px 0; border-radius: 0 4px 4px 0;">
  <strong>TL;DR</strong>  - [Headline result in one sentence.]
</div>

<!-- Section headers: ClickHouse yellow underline -->
<h3 style="font-size: 14px; color: #444; margin-top: 20px; margin-bottom: 8px; border-bottom: 1px solid #FADB14; padding-bottom: 4px;">[Section Header]</h3>

<p>[Explanation  - direct, concise. ClickHouse jargon is fine.]</p>

<!-- Tables for structured data -->
<table style="border-collapse: collapse; width: auto; margin: 12px 0; font-size: 13px;">
  <tr style="background-color: #f5f5f5;">
    <th style="padding: 8px 10px; text-align: left; border: 1px solid #ddd; font-weight: 600;">[Header]</th>
    <th style="padding: 8px 10px; text-align: left; border: 1px solid #ddd; font-weight: 600;">[Header]</th>
  </tr>
  <tr>
    <td style="padding: 8px 10px; border: 1px solid #ddd;">[Data]</td>
    <!-- Highlight positive results in green -->
    <td style="padding: 8px 10px; border: 1px solid #ddd; font-weight: 600; color: #0d7c3d;">[Good result]</td>
  </tr>
  <tr>
    <td style="padding: 8px 10px; border: 1px solid #ddd; background: #fafafa;">[Data]</td>
    <td style="padding: 8px 10px; border: 1px solid #ddd; background: #fafafa;">[Data]</td>
  </tr>
</table>

<!-- Dark-themed SQL blocks with syntax highlighting -->
<pre style="background: #1e1e1e; color: #d4d4d4; padding: 14px 16px; border-radius: 6px; overflow-x: auto; font-size: 12.5px; line-height: 1.5; font-family: 'SF Mono', Menlo, Consolas, monospace;">
<span style="color: #6a9955;">-- Comment</span>
<span style="color: #569cd6;">SELECT</span> * <span style="color: #569cd6;">FROM</span> table_name;</pre>

<!-- Inline code references -->
<p>Use <code style="background: #f0f0f0; padding: 1px 5px; border-radius: 3px; font-family: 'SF Mono', Menlo, Consolas, monospace; font-size: 12.5px;">inline_code</code> for column names, settings, functions in prose.</p>

<!-- Callout box for grouped info (cleanup SQL, caveats, notes) -->
<div style="background: #f8f8f8; border: 1px solid #e0e0e0; border-radius: 6px; padding: 12px 16px; margin: 12px 0;">
  <div style="font-weight: 600; margin-bottom: 4px;">[Callout Title]</div>
  [Content]
</div>

<!-- Footnotes for methodology / caveats -->
<p style="font-size: 12px; color: #666; margin-top: -8px;">[Methodology note, benchmark conditions, caveats]</p>

<h3 style="font-size: 14px; color: #444; margin-top: 20px; margin-bottom: 8px; border-bottom: 1px solid #FADB14; padding-bottom: 4px;">Next Steps</h3>

<!-- Action items table when >2 items -->
<table style="border-collapse: collapse; width: auto; margin: 12px 0; font-size: 13px;">
  <tr style="background-color: #f5f5f5;">
    <th style="padding: 8px 10px; text-align: left; border: 1px solid #ddd; font-weight: 600;">#</th>
    <th style="padding: 8px 10px; text-align: left; border: 1px solid #ddd; font-weight: 600;">Action</th>
    <th style="padding: 8px 10px; text-align: left; border: 1px solid #ddd; font-weight: 600;">Owner</th>
  </tr>
</table>

<!-- Or simple paragraph for 1-2 items -->
<p>[Closing line  - offer to dig deeper, hop on a call, or walk through the approach.]</p>

<p>Best,<br>
[Your Name]</p>

</body>
</html>
```

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
