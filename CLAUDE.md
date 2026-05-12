# KT-Agent

Knowledge Transfer Agent — a lightweight, modular knowledge ingestion and retrieval system built entirely with Claude Code primitives.

## Overview

Two personas interact with this project:
- **Users** add knowledge via interviews or file uploads
- **Consumers** query the kt-agent to retrieve and discuss stored knowledge

## Session Startup

On every session, read:
1. This file (CLAUDE.md)
2. `persona.md` — domain knowledge summary and communication style

## Directory Structure

```
.claude/agents/kt-agent.md             — Consumer-facing knowledge agent
.claude/commands/kt-agent/ingest.md    — Processes inbox → knowledge base (sole writer)
.claude/commands/kt-agent/interview.md — Conducts knowledge interviews → inbox
.claude/commands/kt-agent/cleanse.md   — Audits knowledge quality → correction sidecars
.claude/skills/kt-parse/               — Converts raw files to markdown
.claude/skills/kt-categorize/          — Assigns category, metadata, splits multi-topic
.claude/skills/kt-persona/             — Updates persona.md
inbox/                                 — Drop zone for files to be processed
inbox/processed/                       — Originals moved here after ingest
knowledge/                             — The knowledge base
knowledge/projects/                    — Architecture, design, system context
knowledge/references/                  — Lookups, glossary, links, API details
knowledge/troubleshooting/             — Problems and solutions
knowledge/workflows/                   — Operational procedures
knowledge/INDEX.md                     — Discovery index (summaries of all files)
persona.md                             — Agent personality and domain overview
```

## Commands

| Command | Purpose |
|---------|---------|
| `/kt-agent/interview` | Conduct a focused knowledge interview on one topic. Outputs transcript to inbox/. |
| `/kt-agent/ingest` | Process all inbox files into the knowledge base. Calls kt-parse → kt-categorize → kt-persona skills. |
| `/kt-agent/cleanse` | Audit knowledge base quality. Outputs correction sidecars to inbox/. |

## Agent

Invoke with: `kt-agent`

The kt-agent answers consumer questions using only the knowledge base. It reads INDEX.md for discovery and relevant knowledge files for answers. Read-only — never modifies files.

## Knowledge File Format

All files in `knowledge/` use YAML frontmatter:

```yaml
---
title: descriptive-slug-name
category: projects|references|troubleshooting|workflows
tags: [tag1, tag2, tag3]
source: interview|upload|cleanse-split
last_updated: YYYY-MM-DD
summary: |
  3-5 sentence paragraph capturing key concepts, context, and relationships.
  Must be specific enough for the kt-agent to determine relevance from INDEX
  alone without reading the full file.
---
```

## Design Principles

- **Single writer:** Only `/kt-agent/ingest` writes to `knowledge/`
- **Modular delegation:** Commands call skills; skills do one thing
- **Skills don't call skills:** Ingest orchestrates all skill invocations
- **Summary quality gate:** If a file can't be summarized in 3-5 sentences, it must be split
- **INDEX-first discovery:** kt-agent reads INDEX.md first, then only relevant full files
- **Cleanse via sidecars:** Corrections flow through inbox, applied by ingest

## Typical Workflows

**Adding knowledge via interview:**
`/kt-agent/interview` → answer questions → `/kt-agent/ingest` → `/kt-agent/cleanse`

**Adding knowledge via file upload:**
Drop file in `inbox/` → `/kt-agent/ingest` → `/kt-agent/cleanse`

**Querying knowledge:**
Invoke `kt-agent` → ask questions → agent retrieves from knowledge base

**Maintaining quality:**
`/kt-agent/cleanse full` → review sidecars → `/kt-agent/ingest` to apply corrections
