---
name: categorize
description: Analyze parsed markdown content to assign knowledge category, generate metadata, and split multi-topic files. May ask user for input when category is ambiguous.
---

# Categorize Skill

## Purpose

Analyze parsed markdown content and determine where it belongs in the knowledge base. Generate complete metadata including a discovery-quality summary. Split files that span multiple knowledge domains.

## Inputs

You will receive:
1. **Parsed markdown content** — clean markdown from the parse skill
2. **Original filename** — for context on source/intent
3. **Source type** — one of: `interview`, `upload`, `cleanse`

## Output Format

Return an array of one or more entries. Each entry:

```
{
  content: "the markdown body for this knowledge file",
  metadata: {
    title: "descriptive-slug-name",
    category: "projects|references|troubleshooting|workflows",
    tags: ["tag1", "tag2", "tag3"],
    summary: "3-5 sentence paragraph...",
    source: "interview|upload|cleanse-split"
  },
  filename: "descriptive-slug-name.md"
}
```

## Category Definitions

- **projects** — Architecture, design decisions, system context for specific applications or systems. "How is this built and why?"
- **references** — Lookup material: glossary terms, links, API references, configuration details. "What is this called and where do I find it?"
- **troubleshooting** — Problems encountered and their solutions. "What went wrong and how was it fixed?"
- **workflows** — Operational procedures, daily tasks, recurring processes. "How do I do this?"

## Logic

### Step 1: Analyze Content
Read the full content. Identify the primary knowledge domain(s) it covers.

### Step 2: Confidence Check
Evaluate category fit:
- **High confidence** (content clearly fits ONE category): Assign silently. Proceed.
- **Low confidence** (content could plausibly fit 2+ categories): Ask the user:
  > "This content could fit **[category A]** or **[category B]**. Which category works better? Any specific tags to add?"
  
  Wait for user response. Accept their choice. User may also override with a different category or provide custom reasoning.

### Step 3: Summary Quality Gate
Write a 3-5 sentence summary paragraph for the content. This summary must:
- Capture the key concepts, context, and relationships
- Be specific enough that the kt-agent can determine relevance WITHOUT reading the full file
- Cover what the file is about, why it matters, and how it relates to the domain

**If you cannot write an adequate summary in 3-5 sentences, the file MUST be split.** This is a hard gate — do not proceed with a vague summary.

### Step 4: Split Check
If the content spans 2+ distinct knowledge areas with separable sections:
1. Identify natural split points (section breaks, topic transitions)
2. Split into separate entries, each getting its own metadata
3. Each split piece must pass the summary quality gate independently
4. Set `source` to `cleanse-split` for split outputs (unless original source was `interview`)

**Do NOT split** if:
- Content merely references another domain in passing
- Sections are too interdependent to stand alone
- The file is already focused (single topic, passes summary gate)

### Step 5: Generate Filename
Create slugified filename from title:
- Lowercase
- Hyphens for spaces
- Strip non-alphanumeric characters (except hyphens)
- Maximum 60 characters
- If collision with existing file in target category: append `-2` (or `-3`, etc.)

### Step 6: Generate Tags
Assign 2-5 tags that describe the content. Tags should be:
- Lowercase, hyphenated for multi-word
- Specific enough to aid discovery
- Drawn from consistent vocabulary when possible

## Constraints

- Do NOT write any files
- Do NOT parse raw file formats (input is already parsed markdown)
- Do NOT update persona.md
- Do NOT call other skills
- MAY ask user questions (confidence check only)
- Return structured array as output
