# kt-agent

**A lightweight knowledge transfer agent built on Claude Code primitives.**

Capture knowledge through interviews or file uploads. Query it through a grounded AI agent. No databases, no servers, no dependencies beyond `curl` and `bash`.

[![version](https://img.shields.io/github/v/tag/caphugh/kt-agent?label=version)](https://github.com/caphugh/kt-agent/releases)

---

## What is kt-agent?

kt-agent is a modular knowledge ingestion and retrieval system that lives entirely inside your Claude Code project. You feed it knowledge — through structured interviews or file drops — and it organizes that knowledge into a queryable base that a dedicated AI agent can answer questions from.

It works in two modes: as a **personal knowledge base** (your own second brain, notes, learnings, how-tos) or as **project documentation** installed alongside a codebase (architecture decisions, runbooks, troubleshooting guides). The same pipeline handles both without any configuration changes.

Everything runs as Claude Code slash commands and agents — no external services, no API keys beyond your existing Claude Code session.

---

## Quick Start

### Option A — Standalone knowledge base

Create a fresh folder and install kt-agent into it:

```bash
mkdir my-knowledge-base
cd my-knowledge-base
curl -sSL https://raw.githubusercontent.com/caphugh/kt-agent/main/install.sh | bash
```

Open `my-knowledge-base/` in Claude Code. Done.

### Option B — Add to an existing project

Run from your project root:

```bash
cd ~/my-project
curl -sSL https://raw.githubusercontent.com/caphugh/kt-agent/main/install.sh | bash
```

kt-agent installs under `.claude/commands/kt-agent/` and `.claude/skills/kt-agent/` — fully namespaced, no collision with existing commands or skills.

---

## Usage

### Capturing knowledge

**Via interview** — Claude asks you 5–8 focused questions on a topic you choose:

```
/kt-agent/interview
```

**Via file upload** — drop any `.md`, `.txt`, `.csv`, or code file into `inbox/`:

```
inbox/my-notes.md
inbox/architecture.txt
inbox/config-reference.yaml
```

### Processing into the knowledge base

```
/kt-agent/ingest
```

Picks up everything in `inbox/`, normalizes it, categorizes it, writes structured knowledge files, and updates the discovery index. Safe to re-run — already-processed files are moved to `inbox/processed/`.

### Querying

Invoke the agent by name in Claude Code:

```
kt-agent
```

The agent reads the discovery index, pulls relevant knowledge files, and answers questions grounded exclusively in what's been captured. It won't supplement with general knowledge or speculate beyond the knowledge base.

### Maintaining quality

```
/kt-agent/cleanse
```

Audits the knowledge base for redundancy, miscategorization, vague metadata, and files that have grown too broad. Outputs correction suggestions to `inbox/` as sidecar files — you review them, then run `/kt-agent/ingest` to apply.

---

## Commands Reference

| Command | Purpose |
|---------|---------|
| `/kt-agent/interview` | Conduct a structured knowledge interview on one topic. Saves transcript to `inbox/`. |
| `/kt-agent/ingest` | Process all files in `inbox/` into the knowledge base. Sole writer to `knowledge/`. |
| `/kt-agent/cleanse` | Audit knowledge base quality. Outputs correction sidecars to `inbox/`. |
| `kt-agent` | Query agent. Answers questions from the knowledge base only. |

---

## How It Works

```
/kt-agent/interview  ──►  inbox/  ──►  /kt-agent/ingest  ──►  knowledge/
     file drop        ──►                                           │
                                                                    ▼
                                                               kt-agent
                                                            (read-only query)
```

**Single writer:** Only `/kt-agent/ingest` writes to `knowledge/`. All corrections from `/kt-agent/cleanse` flow through `inbox/` as sidecars, applied by ingest. This gives you a clean audit trail and prevents conflicting writes.

**INDEX-first discovery:** The query agent reads `knowledge/INDEX.md` (a summary of every knowledge file) before pulling full files. This keeps context usage low and retrieval fast even as the knowledge base grows.

**Modular skills:** Ingest orchestrates three internal skills in sequence — `parse` (normalize raw files to markdown) → `categorize` (assign category, generate metadata, split if needed) → `persona` (update the agent's domain knowledge summary). Skills don't call each other; ingest coordinates them.

---

## Install Options

```bash
# Install to current directory (default)
curl -sSL https://raw.githubusercontent.com/caphugh/kt-agent/main/install.sh | bash

# Preview what would be installed without writing any files
curl -sSL https://raw.githubusercontent.com/caphugh/kt-agent/main/install.sh | bash -s -- --dry-run

# Pin to a specific release
curl -sSL https://raw.githubusercontent.com/caphugh/kt-agent/main/install.sh | bash -s -- --version v0.1.0

# Install to a specific directory
curl -sSL https://raw.githubusercontent.com/caphugh/kt-agent/main/install.sh | bash -s -- --target /path/to/project

# Overwrite user-data files (persona.md, knowledge/) on re-install
curl -sSL https://raw.githubusercontent.com/caphugh/kt-agent/main/install.sh | bash -s -- --force
```

| Flag | Description |
|------|-------------|
| `--version <tag>` | Install a specific release tag instead of `main` |
| `--dry-run` | Print what would change, write nothing |
| `--force` | Overwrite `persona.md` and `knowledge/` on re-install |
| `--target <dir>` | Install into a specific directory (default: `pwd`) |

**Re-running is safe.** Agent, command, and skill files are always overwritten (versioned assets). `persona.md`, `knowledge/`, and `inbox/` are never touched on re-run unless `--force` is passed.

---

## Knowledge Base Structure

All captured knowledge lives in `knowledge/` under four categories:

| Category | What goes here |
|----------|---------------|
| `projects/` | Architecture, design decisions, system context — *how is this built and why?* |
| `references/` | Lookups, glossary terms, links, API details — *what is this called and where do I find it?* |
| `troubleshooting/` | Problems encountered and their solutions — *what went wrong and how was it fixed?* |
| `workflows/` | Operational procedures and recurring tasks — *how do I do this?* |

Each file uses YAML frontmatter with a discovery-quality summary that lets the query agent determine relevance without reading the full file.

---

## Requirements

- [Claude Code](https://claude.ai/code) (CLI, desktop, or IDE extension)
- `curl` and `bash` (macOS and Linux)
- No other dependencies

---

## Roadmap

See [open issues](https://github.com/caphugh/kt-agent/issues) for planned features including multi-IDE support (Cursor, Windsurf, Copilot), full-text search, PDF/DOCX ingestion, scheduled cleanse runs, and automatic knowledge capture from merged PRs.
