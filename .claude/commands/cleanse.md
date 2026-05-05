---
name: cleanse
description: Audit the knowledge base for quality issues (redundancy, miscategorization, vague metadata, oversized files). Outputs correction sidecars to inbox/ for processing by /ingest.
---

# Cleanse Command

## Purpose

Audit the knowledge base for quality and consistency issues. Does NOT modify knowledge files directly — instead, outputs sidecar files to `inbox/` with suggested corrections. User then runs `/ingest` to apply them. This preserves the single-writer principle.

## Modes

### Default Mode (no arguments)

Scope: Read `knowledge/.last-ingest.log` to identify recently ingested files. Scan those files PLUS all other files in the same categories (for redundancy comparison).

If `.last-ingest.log` doesn't exist or is empty: inform user and suggest running with `full` flag.

### Full Mode (user passes "full" argument)

Scope: Scan the entire knowledge base — all files in all categories.

## Quality Checks

Run these checks on every file in scope:

### 1. Redundancy Detection

Compare file content against other files in the same category:
- If two files share >60% topical overlap (covering the same concepts, solutions, or procedures): flag for merge
- Identify which file is more comprehensive (it becomes the merge target)
- The less comprehensive file becomes `merge_with` (will be deleted)

### 2. Miscategorization

Evaluate whether each file's content matches its category definition:
- **projects** = architecture, design, system context
- **references** = lookups, glossary, links, API details
- **troubleshooting** = problems + solutions
- **workflows** = operational procedures

If content clearly belongs in a different category: flag for recategorization.

### 3. Metadata Quality

Check each file's frontmatter:
- **Summary too vague:** Summary doesn't capture specific concepts (e.g., "This file is about Kubernetes" — needs more detail about WHAT about Kubernetes)
- **Missing tags:** Fewer than 2 tags
- **Stale dates:** `last_updated` more than 6 months old (flag for review, not auto-fix)
- **Summary too short:** Less than 2 sentences

### 4. File Scope

Evaluate whether any file is too broad:
- Could the content be split into 2+ standalone topics?
- Does the summary struggle to capture all value in 3-5 sentences?
- Are there distinct sections that serve different purposes?

If yes: flag for split.

### 5. INDEX Sync

Compare `knowledge/INDEX.md` entries against actual files:
- Files that exist but aren't in INDEX
- INDEX entries for files that don't exist
- Summaries in INDEX that don't match file frontmatter

Note: INDEX sync issues are auto-fixed by ingest's INDEX regeneration. Flag them as informational only.

## Sidecar Output Format

For each issue found, create a sidecar file in `inbox/`:

**Filename:** `cleanse-{action}-{target-slug}.sidecar.md`

### Merge Sidecar
```yaml
---
type: cleanse-correction
target: knowledge/{category}/{filename}.md
action: merge
merge_with: knowledge/{category}/{other-filename}.md
date: {YYYY-MM-DD}
---
## Problem
These two files have significant content overlap covering {shared topics}.

## Suggested Changes
Merge content from {merge_with filename} into {target filename}. The target file is more comprehensive and should absorb the unique portions of the merge source.

## Affected Files
- {target path} (primary — content merged INTO this file)
- {merge_with path} (merge source — will be deleted after merge)
```

### Recategorize Sidecar
```yaml
---
type: cleanse-correction
target: knowledge/{current-category}/{filename}.md
action: recategorize
new_category: {correct-category}
date: {YYYY-MM-DD}
---
## Problem
This file is in {current category} but its content is about {description} which fits {correct category} better.

## Suggested Changes
Move to knowledge/{correct-category}/{filename}.md. No content changes needed.

## Affected Files
- {target path} (will be removed from current location and re-written to new category)
```

### Update-Metadata Sidecar
```yaml
---
type: cleanse-correction
target: knowledge/{category}/{filename}.md
action: update-metadata
date: {YYYY-MM-DD}
---
## Problem
{specific metadata issue: vague summary, missing tags, etc.}

## Suggested Changes
Updated metadata:
- summary: "{new 3-5 sentence summary}"
- tags: [{suggested tags}]
```

### Split Sidecar
```yaml
---
type: cleanse-correction
target: knowledge/{category}/{filename}.md
action: split
date: {YYYY-MM-DD}
---
## Problem
This file covers multiple distinct topics that would be better served as separate knowledge entries: {topic list}.

## Suggested Changes
Split into:
1. {first topic} — content from sections {X}
2. {second topic} — content from sections {Y}

Each split should stand alone with its own summary and category.
```

## Report

After generating all sidecars, output:

> **Cleanse audit complete.**
> - Files scanned: {N}
> - Issues found: {M}
>   - Redundancy (merge): {count}
>   - Miscategorization: {count}
>   - Metadata quality: {count}
>   - Scope (split): {count}
>   - INDEX sync: {count} (informational)
>
> Sidecar files written to `inbox/`. Run `/ingest` to apply corrections.

If no issues found:
> **Cleanse audit complete.** No issues found. Knowledge base is clean.

## Constraints

- Do NOT write to `knowledge/` — only `inbox/`
- Do NOT call any skills
- Do NOT modify or delete knowledge files directly
- One sidecar per issue (a file may generate multiple sidecars if it has multiple problems)
- Be specific in suggested changes — vague sidecars are useless to ingest
