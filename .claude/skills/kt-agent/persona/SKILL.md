---
name: persona
description: Update persona.md with domain knowledge summary and communication style based on processed knowledge content. Only skill with write permission (writes persona.md only).
---

# Persona Skill

## Purpose

Maintain an accurate, up-to-date persona.md that reflects the user's domain knowledge and communication style. This file is read by the kt-agent on every invocation to establish tone and understand the scope of available knowledge.

## Inputs

You will receive:
1. **Content array** — all knowledge file content + metadata from the current ingest run (post-categorize, post-split)
2. **Source type** — either `interview` or `upload`

## Logic

### Step 1: Read Current State
Read `persona.md` in its current form.

### Step 2: Update Domain Knowledge Summary
Based on ALL content in the input array:
- Identify new knowledge areas/topics introduced
- Add them to the Domain Knowledge Summary section
- Keep entries concise (1-2 sentences each)
- Group related topics
- Remove entries that have been superseded by more detailed knowledge
- This section should read as a catalog of "what this knowledge base knows about"

### Step 3: Update Communication Style (Interview Source Only)
If source type is `interview`:
- Analyze the user's responses in the transcript for communication patterns:
  - Vocabulary complexity and technical depth
  - Sentence structure (terse vs. elaborate)
  - Use of analogies, examples, or specific frameworks
  - Tone (formal, casual, mixed)
- Update the Communication Style section to reflect observed patterns
- Do NOT overwrite with each interview — blend new observations with existing style notes
- If style hasn't meaningfully changed, leave this section as-is

If source type is `upload`: skip this step entirely.

### Step 4: Update Areas of Expertise
Based on content topics and depth:
- Add or update expertise areas
- Indicate relative depth (mentioned vs. demonstrated detailed knowledge)
- Keep as a scannable list

### Step 5: Write
Write the updated persona.md. Preserve the file's section structure:
```markdown
# KT-Agent Persona

## Domain Knowledge Summary
{updated content}

## Communication Style
{updated or unchanged}

## Areas of Expertise
{updated content}
```

## Output

Write the updated `persona.md` file. This is the ONLY file this skill writes.

## Constraints

- ONLY write to `persona.md` — no other files
- Do NOT write to knowledge/
- Do NOT call other skills
- Do NOT categorize or parse content
- Prioritize Domain Knowledge Summary accuracy over Communication Style updates
- Blend observations over time — do not fully replace style notes from a single data point
