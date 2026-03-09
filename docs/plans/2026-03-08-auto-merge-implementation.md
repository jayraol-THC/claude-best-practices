# Auto-Merge Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Automate merging of monthly Reddit findings into `PARALLEL_CODING_BEST_PRACTICES.md` using a two-phase Gemini LLM approach.

**Architecture:** Phase 1 searches Reddit via Gemini + Google Search (existing). Phase 2 sends current best practices doc + findings JSON to Gemini, which returns the merged document. Safety checks validate output before overwriting.

**Tech Stack:** Python 3.11, google-genai SDK, Gemini 2.5 Flash

---

## Task 1: Add Merge Function Skeleton

**Files:**
- Modify: `scripts/auto_review.py:17-19` (add constants)
- Modify: `scripts/auto_review.py:108` (add new function)

**Step 1: Add required sections constant**

Add after line 19 in `scripts/auto_review.py`:

```python
REQUIRED_SECTIONS = [
    "Cost-Efficient Model Routing",
    "Parallel Agent Architecture",
    "Git Worktree Isolation",
    "CLAUDE.md Optimization",
    "Context Management",
]
```

**Step 2: Add merge function skeleton**

Add after the `generate_update_markdown` function (around line 185):

```python
def merge_findings_into_document(findings: dict, current_doc: str) -> str:
    """Use Gemini to intelligently merge findings into the best practices document."""
    raise NotImplementedError("Merge logic not yet implemented")
```

**Step 3: Run script to verify no syntax errors**

Run: `python3 scripts/auto_review.py --help 2>&1 || python3 -c "import scripts.auto_review"`
Expected: No syntax errors (will fail on missing API key, that's fine)

**Step 4: Commit**

```bash
git add scripts/auto_review.py
git commit -m "feat: add merge function skeleton and required sections constant"
```

---

## Task 2: Implement Merge Prompt

**Files:**
- Modify: `scripts/auto_review.py` (implement `merge_findings_into_document`)

**Step 1: Implement the merge function**

Replace the skeleton with:

```python
def merge_findings_into_document(findings: dict, current_doc: str) -> str:
    """Use Gemini to intelligently merge findings into the best practices document."""

    client = genai.Client(api_key=GEMINI_API_KEY)

    current_date = datetime.now().strftime("%B %Y")
    findings_json = json.dumps(findings, indent=2)

    prompt = f"""You are updating a best practices document with new community findings.

RULES:
1. Preserve the existing structure and formatting EXACTLY
2. Only ADD new information, never remove existing content
3. Skip findings that duplicate or closely match existing content
4. New insights should be added as bullet points or paragraphs in the relevant section

CATEGORY MAPPING:
- "Cost Optimization" findings → "Cost-Efficient Model Routing" section
- "Parallel Agents" findings → "Parallel Agent Architecture" section
- "Context Management" findings → "Context Management" section
- "Configuration" findings → "CLAUDE.md Optimization" section
- "Tools" findings → Add to the relevant tools table in "Git Worktree Isolation" or create inline mention

FORMATTING:
- Prefix new insights with **New ({current_date}):** for visibility
- Update the "Last Updated" date in the header to {datetime.now().strftime("%Y-%m-%d")}
- Add any new sources to the Sources section at the bottom
- For new tools, add a row to the existing tools table if one exists in that section

CURRENT DOCUMENT:
```markdown
{current_doc}
```

NEW FINDINGS TO MERGE:
```json
{findings_json}
```

OUTPUT:
Return ONLY the complete updated markdown document. No explanations, no code blocks around it.
"""

    config = types.GenerateContentConfig(
        temperature=0.3,  # Lower temperature for more consistent output
    )

    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=prompt,
        config=config,
    )

    return response.text.strip()
```

**Step 2: Verify syntax**

Run: `python3 -c "from scripts.auto_review import merge_findings_into_document; print('OK')"`
Expected: `OK`

**Step 3: Commit**

```bash
git add scripts/auto_review.py
git commit -m "feat: implement merge prompt for Phase 2 Gemini call"
```

---

## Task 3: Add Validation Function

**Files:**
- Modify: `scripts/auto_review.py` (add validation function)

**Step 1: Add validation function after merge function**

```python
def validate_merged_document(original: str, merged: str) -> tuple[bool, str]:
    """Validate the merged document meets safety requirements.

    Returns (is_valid, error_message).
    """
    # Check minimum length (80% of original)
    if len(merged) < len(original) * 0.8:
        return False, f"Merged doc too short: {len(merged)} chars vs {len(original)} original (min 80%)"

    # Check required sections exist
    for section in REQUIRED_SECTIONS:
        if section not in merged:
            return False, f"Missing required section: {section}"

    # Check it starts with expected header
    if not merged.startswith("# Parallel Autonomous Coding"):
        return False, "Document doesn't start with expected title"

    return True, ""
```

**Step 2: Verify syntax**

Run: `python3 -c "from scripts.auto_review import validate_merged_document; print('OK')"`
Expected: `OK`

**Step 3: Commit**

```bash
git add scripts/auto_review.py
git commit -m "feat: add validation for merged document safety checks"
```

---

## Task 4: Add Backup and Restore Functions

**Files:**
- Modify: `scripts/auto_review.py` (add backup utilities)

**Step 1: Add backup/restore functions**

Add after the imports section:

```python
def create_backup(file_path: Path) -> Path:
    """Create a backup of the file before modifying."""
    backup_path = file_path.with_suffix(file_path.suffix + ".bak")
    backup_path.write_text(file_path.read_text())
    return backup_path


def restore_from_backup(file_path: Path, backup_path: Path) -> None:
    """Restore file from backup."""
    file_path.write_text(backup_path.read_text())
    backup_path.unlink()  # Remove backup after restore
```

**Step 2: Verify syntax**

Run: `python3 -c "from scripts.auto_review import create_backup, restore_from_backup; print('OK')"`
Expected: `OK`

**Step 3: Commit**

```bash
git add scripts/auto_review.py
git commit -m "feat: add backup and restore utilities for safe document updates"
```

---

## Task 5: Add CLI Arguments

**Files:**
- Modify: `scripts/auto_review.py` (add argparse)

**Step 1: Add argparse import and argument parsing**

Add to imports at top:

```python
import argparse
```

Add new function before `main()`:

```python
def parse_args():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(
        description="Auto-review r/claude and merge findings into best practices doc"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print diff without writing changes"
    )
    parser.add_argument(
        "--skip-merge",
        action="store_true",
        help="Only generate MONTHLY_UPDATE.md without merging (legacy behavior)"
    )
    return parser.parse_args()
```

**Step 2: Verify help works**

Run: `python3 scripts/auto_review.py --help`
Expected: Help text showing `--dry-run` and `--skip-merge` options

**Step 3: Commit**

```bash
git add scripts/auto_review.py
git commit -m "feat: add CLI arguments for dry-run and skip-merge modes"
```

---

## Task 6: Update Main Function

**Files:**
- Modify: `scripts/auto_review.py` (rewrite main function)

**Step 1: Replace the main function**

```python
def main():
    args = parse_args()

    if not GEMINI_API_KEY:
        print("Error: GEMINI_API_KEY environment variable not set")
        exit(1)

    # Phase 1: Search Reddit
    print("Phase 1: Searching r/claude with Gemini 2.5 Flash + Google Search...")
    findings = search_and_summarize()

    if findings.get("parse_error"):
        print("Error: Failed to parse search results")
        print(findings.get("raw_response", "No response"))
        exit(1)

    print(f"  Found {len(findings.get('findings', []))} insights")
    print(f"  Found {len(findings.get('new_tools_mentioned', []))} new tools")

    # Legacy mode: just generate MONTHLY_UPDATE.md
    if args.skip_merge:
        print("\nGenerating MONTHLY_UPDATE.md (skip-merge mode)...")
        update_md = generate_update_markdown(findings)
        OUTPUT_FILE.write_text(update_md)
        print(f"Written to {OUTPUT_FILE}")
        return

    # Phase 2: Merge into best practices doc
    print("\nPhase 2: Merging findings into best practices document...")

    if not BEST_PRACTICES_FILE.exists():
        print(f"Error: Best practices file not found: {BEST_PRACTICES_FILE}")
        exit(1)

    current_doc = BEST_PRACTICES_FILE.read_text()

    # Create backup
    backup_path = create_backup(BEST_PRACTICES_FILE)
    print(f"  Backup created: {backup_path}")

    try:
        merged_doc = merge_findings_into_document(findings, current_doc)

        # Validate
        is_valid, error = validate_merged_document(current_doc, merged_doc)
        if not is_valid:
            print(f"  Validation failed: {error}")
            restore_from_backup(BEST_PRACTICES_FILE, backup_path)
            print("  Restored from backup")
            exit(1)

        if args.dry_run:
            print("\n--- DRY RUN: Would write the following changes ---")
            print(f"Document length: {len(current_doc)} -> {len(merged_doc)} chars")
            print("\nFirst 500 chars of merged doc:")
            print(merged_doc[:500])
            print("\n--- End dry run ---")
            backup_path.unlink()  # Clean up backup
            return

        # Write merged document
        BEST_PRACTICES_FILE.write_text(merged_doc)
        print(f"  Updated: {BEST_PRACTICES_FILE}")

        # Clean up backup on success
        backup_path.unlink()
        print("  Backup removed (success)")

    except Exception as e:
        print(f"  Error during merge: {e}")
        restore_from_backup(BEST_PRACTICES_FILE, backup_path)
        print("  Restored from backup")
        exit(1)

    print("\nDone!")
```

**Step 2: Test dry-run mode**

Run: `python3 scripts/auto_review.py --dry-run`
Expected: Shows "Phase 1: Searching...", then "Phase 2: Merging...", then "DRY RUN" output

**Step 3: Commit**

```bash
git add scripts/auto_review.py
git commit -m "feat: update main function with two-phase merge workflow"
```

---

## Task 7: Update GitHub Actions Workflow

**Files:**
- Modify: `.github/workflows/monthly-review-reminder.yml`

**Step 1: Update the workflow file**

Replace the entire file with:

```yaml
# Monthly Auto-Review for Claude Best Practices
# Uses Gemini 2.5 Flash with Google Search to find and merge r/claude insights

name: Monthly r/claude Auto-Review

on:
  schedule:
    # Run on the 1st of every month at 9 AM UTC
    - cron: '0 9 1 * *'
  workflow_dispatch: # Allow manual trigger

jobs:
  auto-review:
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install google-genai

      - name: Run auto-review with merge
        env:
          GEMINI_API_KEY: ${{ secrets.GEMINI_API_KEY }}
        run: |
          python scripts/auto_review.py

      - name: Get current date
        id: date
        run: echo "date=$(date +'%Y-%m')" >> $GITHUB_OUTPUT

      - name: Create Pull Request
        uses: peter-evans/create-pull-request@v6
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          commit-message: "docs: monthly best practices update - ${{ steps.date.outputs.date }}"
          title: "[Auto] Monthly Best Practices Update - ${{ steps.date.outputs.date }}"
          body: |
            ## Automated Monthly Update

            This PR was automatically generated by the monthly review workflow.

            ### What Changed

            New insights from r/claude and r/claudeai have been merged directly into `PARALLEL_CODING_BEST_PRACTICES.md`.

            ### Review Checklist

            - [ ] Review the diff to see what was added
            - [ ] Verify new content fits the document structure
            - [ ] Check that no existing content was accidentally removed

            ---
            *Auto-generated with Gemini 2.5 Flash + Google Search*
          branch: auto-update/${{ steps.date.outputs.date }}
          labels: |
            documentation
            automated
          delete-branch: true
```

**Step 2: Validate YAML syntax**

Run: `python3 -c "import yaml; yaml.safe_load(open('.github/workflows/monthly-review-reminder.yml')); print('Valid YAML')"`
Expected: `Valid YAML`

**Step 3: Commit**

```bash
git add .github/workflows/monthly-review-reminder.yml
git commit -m "feat: update GitHub Actions to use new merge workflow"
```

---

## Task 8: Clean Up MONTHLY_UPDATE.md

**Files:**
- Delete: `MONTHLY_UPDATE.md` (if exists, it's now legacy)

**Step 1: Add MONTHLY_UPDATE.md to .gitignore**

Run: `echo "MONTHLY_UPDATE.md" >> .gitignore`

**Step 2: Remove existing file if present**

Run: `trash MONTHLY_UPDATE.md 2>/dev/null || true`

**Step 3: Commit**

```bash
git add .gitignore
git commit -m "chore: ignore legacy MONTHLY_UPDATE.md file"
```

---

## Task 9: Full Integration Test

**Files:**
- None (testing only)

**Step 1: Run full script in dry-run mode**

Run: `python3 scripts/auto_review.py --dry-run`
Expected:
- Phase 1 completes with findings
- Phase 2 shows merged document preview
- No files modified

**Step 2: Run full script for real**

Run: `python3 scripts/auto_review.py`
Expected:
- Best practices doc is updated
- Backup is created and removed
- No errors

**Step 3: Verify changes**

Run: `git diff PARALLEL_CODING_BEST_PRACTICES.md | head -50`
Expected: Shows additions with "New (March 2026):" prefix

**Step 4: Commit the updated doc**

```bash
git add PARALLEL_CODING_BEST_PRACTICES.md
git commit -m "docs: integrate March 2026 r/claude findings via auto-merge"
```

---

## Summary

| Task | Description | Files |
|------|-------------|-------|
| 1 | Add merge function skeleton | `auto_review.py` |
| 2 | Implement merge prompt | `auto_review.py` |
| 3 | Add validation function | `auto_review.py` |
| 4 | Add backup/restore utilities | `auto_review.py` |
| 5 | Add CLI arguments | `auto_review.py` |
| 6 | Update main function | `auto_review.py` |
| 7 | Update GitHub Actions | `monthly-review-reminder.yml` |
| 8 | Clean up legacy file | `.gitignore` |
| 9 | Integration test | (testing only) |
