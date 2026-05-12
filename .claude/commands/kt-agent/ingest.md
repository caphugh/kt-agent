---
name: ingest
description: Process all files in inbox/, normalize, categorize, and write to the knowledge base. Sole writer to knowledge/. Orchestrates kt-parse, kt-categorize, and kt-persona skills.
---

# Ingest Command

## Purpose

Process all files waiting in `inbox/`, transform them into structured knowledge files, and write them to the appropriate location in `knowledge/`. This is the ONLY command that writes to the knowledge base.

## Workflow

### Step 1: Scan Inbox

List all files in `inbox/` (exclude the `processed/` subdirectory).

Group files:
- **Standalone files** — no matching sidecar
- **Sidecar pairs** — `{filename}` + `{filename}.sidecar.md`
- **Orphan sidecars** — `*.sidecar.md` with no matching raw file in inbox (these target existing knowledge files)

If no files found:
> No files in inbox/. Add files to `inbox/` or run `/kt-agent/interview` to generate content.

Exit.

### Step 2: Process Each File

For each file (or pair), execute Steps A through E:

---

#### Step A — Determine Input Source

- **Standalone file:** Input = file content from inbox
- **Sidecar pair (raw + sidecar in inbox):** Input = raw file content
- **Orphan sidecar:** Input = read the `target` path from sidecar frontmatter, load that file from `knowledge/` as input

Read sidecar frontmatter if present to determine `action` type:
- `merge` — will need to read `merge_with` file from knowledge/ as well
- `recategorize` — will delete original after re-processing
- `update-metadata` — will modify metadata only
- `split` — will split existing file into multiple

---

#### Step B — Parse

Call the **kt-parse skill** with:
- File content (the input determined in Step A)
- Original filename

**If parse returns error signal** (`PARSE_ERROR: ...`):
- Warn user: "Skipping `{filename}` — unsupported format. Leaving in inbox."
- Do NOT move to processed
- Continue to next file

Receive: normalized markdown string

---

#### Step C — Apply Sidecar Modifications

If a sidecar exists, apply its instructions to the parsed content:

- **`merge` action:** Read the `merge_with` file from `knowledge/`. Combine its content with the parsed content from Step B. Delete BOTH the `target` and `merge_with` files from `knowledge/`.
- **`recategorize` action:** Content stays as-is from parse. Delete the original `target` file from `knowledge/`.
- **`update-metadata` action:** Content stays as-is. Metadata changes will be applied in Step D (pass sidecar suggestions to categorize).
- **`split` action:** Content stays as-is. Categorize will handle the split in Step D.

---

#### Step D — Categorize

Call the **kt-categorize skill** with:
- Parsed (and potentially merged) markdown content
- Original filename
- Source type: determine from file frontmatter or context:
  - Has `tags: [interview]` in frontmatter → `interview`
  - Is a sidecar-driven operation → `cleanse`
  - Otherwise → `upload`

Receive: array of `{content, metadata, filename}` objects (1 or more if split)

Note: Categorize may prompt the user for input if category is ambiguous. Allow this interaction to complete before proceeding.

---

#### Step E — Write Knowledge Files

For each item in the categorize output:

1. Assemble the complete file:
   ```markdown
   ---
   title: {metadata.title}
   category: {metadata.category}
   tags: {metadata.tags}
   source: {metadata.source}
   last_updated: {today's date YYYY-MM-DD}
   summary: |
     {metadata.summary}
   ---

   {content}
   ```

2. Write to `knowledge/{metadata.category}/{metadata.filename}`

3. Track the written path for the ingest log

---

### Step 3: Persona Update

After ALL files are processed:

- Collect ALL outputs from Step E across all files
- Determine aggregate source type:
  - If ANY file had source `interview` → source type = `interview`
  - Otherwise → source type = `upload`
- Call the **kt-persona skill** with the collected outputs + source type

---

### Step 4: Cleanup

For each successfully processed file:
- Move original file to `inbox/processed/`
- Move sidecar file (if any) to `inbox/processed/`

Do NOT move files that were skipped due to parse errors.

---

### Step 5: Regenerate INDEX

Rebuild `knowledge/INDEX.md` from scratch:

1. Scan all `.md` files in `knowledge/projects/`, `knowledge/references/`, `knowledge/troubleshooting/`, `knowledge/workflows/`
2. Read YAML frontmatter from each file
3. Rebuild INDEX.md in this format:

```markdown
# Knowledge Base Index

## projects/
- **{filename}** — {summary paragraph from frontmatter}

## references/
- **{filename}** — {summary paragraph from frontmatter}

## troubleshooting/
- **{filename}** — {summary paragraph from frontmatter}

## workflows/
- **{filename}** — {summary paragraph from frontmatter}
```

---

### Step 6: Write Ingest Log

Write `knowledge/.last-ingest.log` with the list of all files created or modified in this run:
```
# Last ingest: {YYYY-MM-DD}
knowledge/projects/new-file.md
knowledge/workflows/another-file.md
```

This file is used by `/kt-agent/cleanse` default mode to scope its audit.

---

### Step 7: Report

Output summary to user:
> **Ingest complete.**
> - Processed: {N} files
> - Created: {M} knowledge entries
> - Categories: {list of categories used}
> - Splits: {number of files that were split, if any}
> - Skipped: {files skipped due to unsupported format, if any}
>
> Run `/kt-agent/cleanse` to audit the new additions for quality.

## Constraints

- This command is the SOLE WRITER to `knowledge/`
- Skills are called in order: kt-parse → kt-categorize → kt-persona
- Never skip the INDEX regeneration step
- Never move unsupported-format files to processed
- Persona is called ONCE at the end with ALL outputs, not per-file
