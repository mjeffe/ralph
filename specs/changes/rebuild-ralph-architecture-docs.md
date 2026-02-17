---
status: planned
priority: medium
created: 2026-02-17
updated: 2026-02-17
tags: [documentation, architecture, refactoring]
dependencies: []
supersedes: []
---

# Rebuild Ralph System Architecture Documentation

## Overview

The current `specs/ralph-system-implementation.md` was used to build the original Ralph system, but the codebase has drifted significantly since then (e.g., no PROGRESS.md, PROJECT_COMPLETE is now a file, etc.). This spec directs Ralph to study the current codebase comprehensively and produce accurate, well-organized architecture and feature specifications that reflect the actual implementation.

## Problem Statement

Current documentation issues:
- `specs/ralph-system-implementation.md` is outdated and doesn't match current code
- Some specs in `specs/features/` and `specs/changes/` are misclassified or overlap
- No clear architectural documentation that reflects actual system design
- Future agents need accurate specs to understand and extend Ralph

**Goal:** Create comprehensive, accurate architecture documentation by studying the actual codebase, then reorganizing specs to eliminate overlap and provide clear system understanding.

## Requirements

### 1. Codebase Study with Subagents

To avoid context overload, use subagents to divide code analysis:

**Required Coverage - Baseline Files/Directories:**
- `ralph` - Entry point wrapper script
- `.ralph/loop.sh` - Core loop implementation
- `.ralph/prompts/` - All prompt files (PROMPT_build.md, PROMPT_plan.md, PROMPT_documentation.md, PROMPT_implementation_plan.md)
- `.ralph/logs/` - Log structure and retention logic
- `specs/` - All existing spec files (for reorganization context)
- `AGENTS.md` - Agent guidance and integration points
- `.ralph/AGENTS.md.template` - Template for AGENTS.md
- `.ralph/validate.sh` - Validation hook (if exists)
- `install.sh` - Installation and setup

**Exclude from Coverage:**
- Docker files (`docker-compose.yml`, `Dockerfile`) - Experimental setup, not part of core Ralph system

**Subagent Partitioning:**
- Agent may organize subagents by directory, subsystem, or logical grouping
- Document which files each subagent analyzed (for verification)
- Focus on understanding current implementation, not theoretical design

### 2. Architecture Specs to Create

Create the following specs under `specs/architecture/`:

#### `ralph-core-loop.md`
- **Scope:** Loop lifecycle, iteration flow, stop conditions (PROJECT_COMPLETE file), exit behavior
- **Include:** Logging strategy, log retention policy, validation hooks, iteration timeout
- **Include:** Git integration (commits, push with retry, rollback strategy)

#### `ralph-state-and-artifacts.md`
- **Scope:** All persistent state files and their roles
- **Include:** `specs/` directory (human-authored, mostly read-only), `.ralph/IMPLEMENTATION_PLAN.md` (agent-maintained, task tracking), `.ralph/PROJECT_COMPLETE` marker file (completion signal)
- **Include:** Git history as audit trail, log files structure
- **Include:** Rules for updating each file, ownership model

#### `ralph-prompting-and-agents.md`
- **Scope:** How prompts guide agent behavior in different modes
- **Include:** PROMPT_build.md (build mode instructions), PROMPT_plan.md (plan mode instructions), PROMPT_documentation.md (documentation update guidelines), PROMPT_implementation_plan.md (plan creation guidelines)
- **Include:** Agent requirements and interface, multi-agent support considerations
- **Include:** Subagent usage patterns for code analysis

#### `ralph-cli-and-entrypoints.md`
- **Scope:** User-facing CLI and internal entry points
- **Include:** `ralph` wrapper script (CLI interface, argument parsing), `.ralph/loop.sh` responsibilities (orchestration, health checks)
- **Include:** Environment configuration, prerequisite checks
- **Include:** Installation and setup process

### 3. Feature Specs (if needed)

Review existing `specs/features/` and `specs/changes/` specs:
- Identify specs that should be reclassified as changes vs. features
- Move or consolidate specs that overlap with new architecture docs
- Create simple feature specs for concrete behaviors not covered in architecture (e.g., branch safety checks, agent output filtering)
- Document which specs were moved/consolidated and why

### 4. Maintain specs/ralph-overview.md

**Critical:** `specs/ralph-overview.md` must remain intact and current. This is the quick reference guide that agents read before each iteration.

**Requirements:**
- **Keep it succinct:** Maximum ~200 lines
- **Update if needed:** Reflect any significant changes discovered during code study (e.g., if new key files/behaviors are found)
- **Do NOT supersede or archive:** This file is permanent and serves a different role than detailed architecture specs
- **Role clarity:** Quick reference for agents vs. detailed architecture in specs/architecture/

### 5. Reorganization Tasks

- **Archive:** Move `specs/ralph-system-implementation.md` to `specs/archive/` and update frontmatter with `status: superseded-by` pointing to new architecture specs
- **Update:** Modify existing specs that overlap with new documentation (consolidate, don't duplicate)
- **Clean:** Remove redundant or obsolete content from existing specs
- **Index:** Update `specs/README.md` with all new specs, mark old spec as archived

### 5. Documentation Standards

All new specs must:
- Include frontmatter metadata per PROMPT_documentation.md guidance (status, priority, created/updated dates, tags, dependencies)
- Reference actual file paths and code locations
- Include examples from current codebase
- Capture the "why" behind design decisions (discovered during code study)
- Be concise and practical (avoid bloat, focus on clarity)
- Use clear, specific language for agent understanding

## Success Criteria

- [ ] All required baseline files/directories studied (documented which subagent covered what)
- [ ] Four architecture specs created under `specs/architecture/` as specified above
- [ ] Existing specs reviewed and reorganized (no overlap with new architecture docs)
- [ ] `specs/ralph-overview.md` maintained at ~200 lines and updated if needed
- [ ] `specs/ralph-system-implementation.md` moved to `specs/archive/` with updated metadata
- [ ] `specs/README.md` updated with all new specs and reorganization notes
- [ ] All new specs include accurate frontmatter metadata
- [ ] All new specs reference actual current code (not outdated examples)
- [ ] Documentation is concise, clear, and eliminates redundancy
- [ ] Future agents can understand Ralph system architecture from these specs

## Out of Scope

- Implementing new features or changing code behavior
- Creating user-facing tutorials or getting-started guides
- Documenting every line of code (focus on architecture and key behaviors)
- Creating specs for external dependencies or tools

## Notes

- **Do not assume** existing specs are accurate; verify against actual code
- **Prioritize current implementation** over historical design documents
- Use subagents to manage context; document your coverage strategy
- When reorganizing specs, preserve useful content (don't delete without reviewing)
- If code behavior is ambiguous, document what the code actually does (not what it should do)
- **Ignore Docker setup:** The current Docker configuration is experimental and will likely be removed. Do not include Docker-related files or functionality in the architecture documentation
