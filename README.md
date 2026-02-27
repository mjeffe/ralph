# Ralph Wiggum Loop

**THIS PROJECT HAS BEEN ARCHIVED.** It was my early exploration of [Geoffrey Huntley's Ralph Wiggum Loop](https://ghuntley.com/ralph/).

> [!CAUTION]
> **This is my sandbox for learning the Ralph Wiggum approach to using an LLM coding agent. It is a research project. DO NOT USE.**
>
> This software is experimental, unstable, and under active development. There is no support, no documentation guarantees, and no warranty of any kind. Use at your own risk.

## Overview

The Ralph Wiggum Loop is an iterative development system that enables LLM coding
agents to work on large projects by breaking work into discrete, manageable
chunks with fresh context per iteration.

The Ralph Wiggum Loop addresses the context window limitations of Large Language Models by:

- **Fresh Context Per Iteration** - Each loop iteration starts the agent with a clean slate
- **Persistent Memory** - Critical information persists in files between iterations
- **Incremental Progress** - Agent completes one focused task per iteration
- **Self-Documenting** - All decisions and progress tracked in version control

This enables agents to work on projects of arbitrary size while maintaining coherence through persistent documentation.

## Coding Agents

I have invested several months in working with Cline in VSCode and I'd like to stick with it if possible.
However, I have done a bit of searching and found this list of possible free/OSS alternatives to Claude Code.
- [Cline](https://docs.cline.bot/introduction/welcome)
- [Roo](https://github.com/RooCodeInc/Roo-Code?ref=ghuntley.com) - a fork of Cline
- [Crush](https://github.com/charmbracelet/crush)
- [Qwen Code](https://github.com/QwenLM/qwen-code)
- []()

I should probably just pay the price and go with the 800lb Gorilla
- [Claude Code](https://claude.com/product/claude-code)

---

## Quick Start

```bash
# Create a specification (choose any method you prefer)

# Option 1: Manual editing
mkdir -p specs
echo "# My Feature" > specs/my-feature.md
# Edit specs/my-feature.md with your requirements

# Option 2: Use cline CLI directly for spec writing
cline --plan "Help me write a specification for my-feature"

# Option 3: Use any AI assistant (ChatGPT, Claude, etc.)
# Draft your spec and save to specs/my-feature.md

# Start the build loop
./ralph

# Or with a maximum iteration limit
./ralph 10
```

The first iteration will create `IMPLEMENTATION_PLAN.md` from your specifications, then subsequent iterations will implement the tasks.

## File Structure

```
project-root/
├── ralph                          # Entry point script
├── specs/                         # Requirements (human-authored)
│   ├── README.md                  # Index of specs with status
│   └── feature-name.md            # Individual feature specs
├── IMPLEMENTATION_PLAN.md         # Remaining work (agent-maintained)
├── PROGRESS.md                    # Completed tasks (agent-maintained)
├── .ralph/                        # Ralph tooling (hidden)
│   ├── loop.sh                    # Core loop implementation
│   ├── prompts/                   
│   │   └── PROMPT_build.md        # Build instructions for agents
│   ├── logs/                      # Execution logs
│   │   └── YYYY-MM-DD_NNN.log
│   └── validate.sh                # Optional validation hook
├── src/                           # Your project source code
│   └── lib/
│       ├── calculator.js          # Example: Simple calculator module
│       └── calculator.test.js     # Example: Calculator tests
└── .git/                          # Version control
```

## Key Files

### specs/ - Requirements Documentation

Human-authored specifications that define what to build:

- One spec file per major feature/component
- Capture the "why" not just the "what"
- Include examples, use cases, edge cases
- Update when requirements change
- Create specs manually or with any tool you prefer (cline CLI, ChatGPT, Claude, etc.)
- See `specs/ralph-system-implementation.md` for the Ralph system specification

### IMPLEMENTATION_PLAN.md - Remaining Work

Agent-maintained prioritized list of tasks:

- Created by agent in first build mode iteration
- Simple ordered list (top = highest priority)
- Agent removes completed items (moves to PROGRESS.md)
- Agent adds discovered issues/gaps
- Contains `PROJECT_COMPLETE` marker when all work done

### PROGRESS.md - Completed Tasks

Historical record of completed work:

- Reverse chronological order (newest first)
- Grouped by date
- Includes commit hash for traceability
- Brief notes on implementation details

## Troubleshooting

### Loop exits immediately

**Check for PROJECT_COMPLETE marker:**
```bash
grep PROJECT_COMPLETE IMPLEMENTATION_PLAN.md
```
Remove marker if work remains.

**Check validation script:**
```bash
.ralph/validate.sh
```
Fix any validation failures.

**Check logs:**
```bash
ls -t .ralph/logs/*.log | head -1 | xargs cat
```

### Agent not following tasks

**Break down vague tasks:**
Edit `IMPLEMENTATION_PLAN.md` to make tasks more specific and actionable.

**Regenerate plan:**
```bash
rm IMPLEMENTATION_PLAN.md
./ralph 1  # Agent will recreate it
```

### Git push failures

**Check network:**
```bash
git remote -v
git fetch
```

**Manual push:**
```bash
git push origin $(git branch --show-current)
```

### High costs per iteration

**Break tasks into smaller chunks:**
Edit `IMPLEMENTATION_PLAN.md` to split large tasks.

**Add scope boundaries:**
Update `specs/` to be more specific about what's in/out of scope.

### Tests keep failing

**Review test quality:**
Check if tests are flaky or overly strict.

**Clarify requirements:**
Update `specs/` with more examples and edge cases.

**Consider rollback:**
```bash
git reset --hard HEAD~1  # Undo last iteration
git push --force origin $(git branch --show-current)
```

### Stopping the Loop

Press `Ctrl-C` at any time to stop the loop gracefully.

**Safe to stop:**
- Between iterations (after commit)
- During agent execution (may leave uncommitted changes)

**After stopping:**
- Review uncommitted changes: `git status`
- Commit manually if needed: `git add -A && git commit -m "..."`
- Or discard: `git reset --hard HEAD`

### Blocked Tasks

If agent repeatedly fails the same task, it will mark it as `[BLOCKED]`:

```markdown
## Remaining Tasks

1. [BLOCKED] Fix authentication bug
   - Blocked by: Unclear password requirements
   - Needs: Clarification in specs/
   
2. [HIGH PRIORITY] Add user profile endpoint
   (Agent will work on this next)
```

**Resolution:**
1. Review blocking issue
2. Update `specs/` with clarification
3. Remove `[BLOCKED]` tag from `IMPLEMENTATION_PLAN.md`
4. Restart loop

### Multiple Specifications

Track multiple features in `specs/README.md`:

```markdown
# Specification Index

## Active Specifications

### User Authentication (auth-system.md)
- **Status:** Active
- **Priority:** High
- **Last Updated:** 2026-02-04

### User Profiles (user-profiles.md)
- **Status:** Active
- **Priority:** Medium
- **Last Updated:** 2026-02-03

## Implemented Specifications

### Database Schema (database-schema.md)
- **Status:** Implemented
- **Completed:** 2026-02-01
```

## Docker Environment Setup

This project supports automatic .env file configuration for cline CLI in Docker containers.

### How it works:
1. Copy `.env.example` to `.env`
2. Edit `.env` with your API credentials
3. Run `docker compose up`
4. Container automatically reads .env, injects vars, configures cline
5. No manual `cline auth` command needed

### Benefits:
- Eliminates manual cline configuration steps
- Automatic environment variable injection
- Pre-configured cline ready for use

## Prerequisites

- Git repository initialized (`git init`)
- Cline CLI installed and available in PATH
- At least one specification document in `specs/`

## References

- [Original Ralph post](https://ghuntley.com/ralph/)
- [Geoffrey Huntley's Loom project](https://github.com/ghuntley/loom/)
- [Ralph Playbook](https://github.com/ClaytonFarr/ralph-playbook)
- [Accountability project](https://github.com/mikearnaldi/accountability)
- [The Real Ralph Wiggum Loop](https://thetrav.substack.com/p/the-real-ralph-wiggum-loop-what-everyone)

## Full Documentation

For complete system specification, architecture details, and implementation notes, see `specs/ralph-system-implementation.md`.

## License

See LICENSE file for details.
