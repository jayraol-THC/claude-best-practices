# Auto-Merge Design for Monthly r/claude Review

> **Date:** 2026-03-08
> **Status:** Approved

## Overview

Automate the merging of monthly Reddit findings into `PARALLEL_CODING_BEST_PRACTICES.md` using a two-phase LLM approach.

## Requirements

- **Fully automatic** - no manual copy/paste of findings
- **Gemini API** - consistent with existing `auto_review.py`
- **Single step** - search Reddit AND merge directly into best practices doc

## Architecture

### Two-Phase LLM Approach

```
┌─────────────────────────────────────────────────────────────────┐
│                     auto_review.py                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Phase 1: Search (existing)                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Gemini + Google Search → JSON findings                   │   │
│  │ (cost tips, parallel agents, tools, etc.)                │   │
│  └─────────────────────────────────────────────────────────┘   │
│                           │                                     │
│                           ▼                                     │
│  Phase 2: Merge (new)                                           │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ Gemini receives:                                         │   │
│  │   • Current PARALLEL_CODING_BEST_PRACTICES.md            │   │
│  │   • JSON findings from Phase 1                           │   │
│  │                                                          │   │
│  │ Gemini outputs:                                          │   │
│  │   • Updated markdown with new insights integrated        │   │
│  │   • Deduplicates similar content                         │   │
│  │   • Adds new tools to tables                             │   │
│  │   • Updates "Last Updated" date                          │   │
│  └─────────────────────────────────────────────────────────┘   │
│                           │                                     │
│                           ▼                                     │
│  Output: Overwrites PARALLEL_CODING_BEST_PRACTICES.md           │
│  (MONTHLY_UPDATE.md no longer generated)                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Merge Prompt Strategy

Phase 2 Gemini call receives a structured prompt:

**System Context:**
- Updating a best practices document with new community findings
- Preserve existing structure and formatting exactly
- Only ADD new information, never remove existing content
- Deduplicate: skip findings that duplicate existing content

**Category Mapping:**
| Finding Category | Target Section |
|------------------|----------------|
| Cost Optimization | Cost-Efficient Model Routing |
| Parallel Agents | Parallel Agent Architecture |
| Context Management | Context Management |
| Configuration | CLAUDE.md Optimization |
| Tools | Add to relevant tools tables |
| New categories | New subsection in most relevant section |

**Formatting Rules:**
- New insights get a `**New (Month Year):**` prefix for visibility
- Update "Last Updated" date in header
- Add new sources to Sources section
- Maintain existing table formats

**Deduplication:** Gemini compares semantic meaning, not exact text.

## Error Handling & Safety

### Safety Measures

1. **Backup before merge** - Copy current doc to `.bak` file
2. **Validation checks:**
   - Merged output must be valid markdown
   - Merged output must be >= 80% of original length
   - Key sections must still exist
3. **Dry-run mode** - `--dry-run` flag prints diff without writing
4. **Git-friendly** - Changes visible in git diff

### Failure Recovery

| Failure | Recovery |
|---------|----------|
| Gemini API error in Phase 2 | Keep original doc unchanged |
| Output too short (truncated) | Restore from .bak, exit with error |
| Missing required sections | Restore from .bak, exit with error |
| JSON parse error in Phase 1 | Skip merge phase entirely |

## GitHub Actions Changes

Update `monthly-review-reminder.yml`:

- PR now contains direct changes to `PARALLEL_CODING_BEST_PRACTICES.md`
- No more `MONTHLY_UPDATE.md` intermediate file
- Simplified PR body - just review the diff
- Branch naming: `auto-update/` instead of `auto-review/`

## Files to Modify

1. `scripts/auto_review.py` - Add Phase 2 merge logic
2. `.github/workflows/monthly-review-reminder.yml` - Update PR behavior

## Cost Estimate

- Phase 1 (search): ~$0.01-0.05/run
- Phase 2 (merge): ~$0.01-0.05/run
- **Total:** ~$0.02-0.10/month
