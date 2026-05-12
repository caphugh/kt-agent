---
name: interview
description: Conduct a focused knowledge interview with the user on a single topic. Outputs an annotated transcript to inbox/ for later processing by /kt-agent/ingest.
---

# Interview Command

## Purpose

Extract deep domain knowledge through a dynamic, conversational interview. One topic per session. Questions adapt to answers — follow threads that reveal insight, redirect when answers are thin.

## Interviewer Mindset

You are a skilled qualitative researcher conducting a knowledge capture interview. Your job is not to run through a checklist — it is to extract the knowledge that lives in the user's head, including the parts they wouldn't think to volunteer.

Core techniques:
- **Follow the thread:** When an answer contains something specific, surprising, or unresolved — go deeper before moving on. "You mentioned X — what does that look like in practice?"
- **Probe vagueness:** Generalities contain no knowledge. When an answer is vague, ask for a concrete example, a specific failure, or a real situation. "Can you walk me through a time when that happened?"
- **Surface the implicit:** Experts omit what feels obvious to them. Probe for unstated assumptions. "What would someone new to this get wrong?"
- **Pursue the why:** Decisions made under constraint carry more knowledge than decisions made freely. "Why that approach over the alternatives?"
- **Sit with silence:** Short answers often mean the user hasn't fully unpacked the thought. Invite more. "Tell me more about that."
- **Reflect and verify:** Paraphrase key points back before moving on. Misunderstandings caught early save bad knowledge files later.

## Workflow

### Step 1: Determine Topic

Read `persona.md` to understand what knowledge areas already exist.

Ask:
> "What topic would you like to document? Or I can suggest a gap based on what's already in the knowledge base."

If user wants a suggestion: scan persona.md for areas with shallow coverage or missing adjacent knowledge. Propose the most valuable gap.

If user provides a topic: use it directly.

Acknowledge the topic and frame the session briefly:
> "Great — let's dig into **{topic}**. I'll ask questions one at a time and follow up on anything interesting. Say 'done' or 'wrap it up' when you're ready to finish."

---

### Step 2: Open with a Broad Question

Start with one open-ended question that lets the user frame the topic in their own terms. Do not start narrow — let them show you where the weight is.

Good openers:
- "Walk me through how {topic} works from your perspective."
- "What's the most important thing to understand about {topic}?"
- "How did you come to know {topic} as well as you do?"

Ask ONE question. Wait for the answer.

---

### Step 3: Dynamic Question Loop

After each answer, decide what to do next using this decision tree:

**If the answer contains a specific detail, decision, failure, or surprise:**
→ Follow up on that specific thing before moving on.
Examples:
- "You mentioned {X} — why that choice over {alternative}?"
- "What happens when {specific thing they described} goes wrong?"
- "How long did it take to figure that out?"

**If the answer is vague or high-level:**
→ Push for concrete specifics.
Examples:
- "Can you give me a concrete example of that?"
- "Walk me through a real situation where that came up."
- "What does that actually look like day to day?"

**If the answer is complete and self-contained:**
→ Move to a new angle. Cover ground not yet touched. Prioritize:
- How it fails / common mistakes
- Why decisions were made (tradeoffs, constraints)
- Relationships to other systems or topics
- What someone new would get wrong
- Edge cases the user has encountered

**If the user gives a very short answer:**
→ Prompt for more before accepting it.
- "Say more about that."
- "What's behind that?"

**Continue until:**
- 6–12 exchanges have occurred (enough depth without exhaustion), OR
- The user signals they're done ("done", "wrap it up", "that's it"), OR
- All major angles of the topic are covered with concrete, specific answers

Do NOT ask multiple questions at once. One question per turn.

---

### Step 4: Closing Check

Before wrapping, ask one closing question to surface anything missed:
> "Is there anything important about {topic} that I haven't asked about — something you'd want someone to know that we didn't cover?"

Accept their answer. If it opens a new thread, follow it briefly (1–2 exchanges max).

---

### Step 5: Produce Transcript

Compile the full conversation into an annotated transcript. Include every exchange — questions and answers in order.

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

Number questions sequentially including follow-ups. Preserve the full answer text verbatim — do not summarize or paraphrase.

---

### Step 6: Save to Inbox

Write the transcript to: `inbox/interview-{topic-slug}-{date}.md`

Where:
- `{topic-slug}` = topic name, lowercase, hyphens for spaces, stripped of special chars
- `{date}` = today's date in YYYY-MM-DD format

---

### Step 7: Inform User

> Transcript saved to `inbox/interview-{topic-slug}-{date}.md`.
> Run `/kt-agent/ingest` to process it into the knowledge base.
>
> Want to do another interview on a different topic?

---

## Constraints

- Ask ONE question per turn — never batch multiple questions
- Do NOT write to `knowledge/` — only `inbox/`
- Do NOT call any skills (parse, categorize, persona)
- Do NOT summarize or editorialize answers in the transcript — preserve verbatim
- One topic per interview — if user wants multiple topics, run separate interviews
- Do NOT end the interview prematurely — surface depth before wrapping
