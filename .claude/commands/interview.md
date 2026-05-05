---
name: interview
description: Conduct a focused knowledge interview with the user on a single topic. Outputs an annotated transcript to inbox/ for later processing by /ingest.
---

# Interview Command

## Purpose

Extract domain knowledge from the user through a structured interview. Each interview focuses on one topic with 5-8 questions to get good coverage without overwhelming the user.

## Workflow

### Step 1: Determine Topic

Read `persona.md` to understand what knowledge areas already exist.

Ask the user:
> "What topic would you like to document? Or I can suggest a gap area."

If user wants a suggestion: identify knowledge areas mentioned in persona.md that lack depth, or entirely undocumented areas the user might know about based on their expertise list.

If user provides a topic: use it directly.

### Step 2: Generate Questions

Create 5-8 focused questions about the topic. Questions should:
- Progress from general to specific
- Cover: what it is, how it works, why decisions were made, common issues, relationships to other systems
- Avoid yes/no questions — ask for explanations, examples, and reasoning
- Be specific enough to elicit actionable knowledge (not "tell me about X" but "what happens when X fails?")

Present ALL questions at once in a numbered list:
> Here are my questions about **{topic}**:
>
> 1. {question}
> 2. {question}
> ...
>
> Answer as many as you'd like. You can send multiple messages — just say "done" when finished.

### Step 3: Collect Answers

Wait for user responses. User may:
- Answer all in one message
- Send multiple messages over time
- Signal completion with "done" or an empty response

Concatenate all answers, preserving which question each answer maps to.

### Step 4: Produce Transcript

Create an annotated transcript markdown file:

```markdown
---
type: interview-transcript
topic: "{topic name}"
date: {YYYY-MM-DD}
tags: [interview]
---

# Interview: {Topic Name}

## Questions and Responses

### Q1: {question text}

{user's answer}

### Q2: {question text}

{user's answer}

...
```

### Step 5: Save to Inbox

Write the transcript to: `inbox/interview-{topic-slug}-{date}.md`

Where:
- `{topic-slug}` = topic name, lowercase, hyphens for spaces, stripped of special chars
- `{date}` = today's date in YYYY-MM-DD format

### Step 6: Inform User

> Transcript saved to `inbox/interview-{topic-slug}-{date}.md`.
> Run `/ingest` to process it into the knowledge base.
>
> Want to do another interview on a different topic?

## Constraints

- Do NOT write to `knowledge/` — only `inbox/`
- Do NOT call any skills (parse, categorize, persona)
- Do NOT process or categorize the transcript content
- One topic per interview — if user wants multiple topics, run multiple interviews
- Keep questions focused and specific to the stated topic
