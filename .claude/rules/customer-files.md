---
paths:
  - "customers/**"
---

# Customer File Conventions

## File Naming

Pattern: `YYYY-MM-DD-{description}.{ext}`

Examples:
- `2026-01-21-assessment.md`
- `2026-02-16-msk-connectivity-assessment.md`
- `2026-02-16-msk-email-response.html`

## Required Document Header (all .md files)

```
# {Title}

**Date:** YYYY-MM-DD
**Status:** Active | Resolved | Superseded by {link}
**Issue:** One-line summary
```

## Status Updates

When updating an existing file, add a dated status update section below the header (newest first):

```
## Status Updates
- **YYYY-MM-DD** — Description of update
- **YYYY-MM-DD** — Original creation
```
