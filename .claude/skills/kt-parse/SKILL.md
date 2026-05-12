---
name: parse
description: Convert raw files to clean markdown. Handles md, txt, code files, and CSV. Returns normalized markdown string or error signal for unsupported formats.
---

# Parse Skill

## Purpose

Convert a raw file from the inbox into clean, normalized markdown suitable for categorization and storage in the knowledge base.

## Inputs

You will receive:
1. **File content** — the raw content of the file to parse
2. **Filename** — original filename including extension (used for format detection)

## Supported Formats

### Markdown (`.md`)
- Passthrough with minimal cleanup
- Strip any non-standard formatting artifacts
- Preserve all headings, lists, links, code blocks

### Plain Text (`.txt`)
- Wrap content in markdown
- Infer title from first line if it looks like a heading, otherwise use filename
- Preserve paragraph breaks

### Code Files (`.py`, `.js`, `.ts`, `.sh`, `.go`, `.yaml`, `.json`, `.rb`, `.rs`, `.java`, `.c`, `.cpp`, `.sql`, etc.)
- Wrap entire content in a fenced code block with appropriate language tag
- Add a brief description header above the code block derived from:
  - File-level comments or docstrings (if present)
  - Filename and apparent purpose (if no comments)
- Format:
  ```markdown
  # {description derived from file}

  ```{language}
  {file content}
  ```
  ```

### CSV (`.csv`)
- Convert to markdown table
- First row becomes table headers
- Preserve all data rows
- If more than 100 rows, include first 50 and last 10 with a note about omitted rows

## Unsupported Formats

Any file extension not listed above (including `.xlsx`, `.docx`, `.pdf`, `.png`, `.jpg`, `.zip`, etc.)

**Behavior for unsupported formats:** Return the following error signal exactly:

```
PARSE_ERROR: Unsupported file format '{extension}'. Supported: .md, .txt, .csv, and common code file extensions.
```

## Output

Return a single markdown string containing the normalized content. No YAML frontmatter — that is added by the categorize skill and ingest command later.

## Constraints

- Do NOT write any files
- Do NOT categorize or assign metadata
- Do NOT call other skills
- Return ONLY the markdown string (or error signal)
