# Ralph System Specification

## Problem Statement

Large Language Models (LLMs) and coding agents have limited context windows, which constrains their ability to work on large projects or maintain context over extended development sessions. As projects grow in complexity, the agent's context becomes saturated with information, leading to degraded performance, forgotten requirements, and inability to maintain coherent long-term development.

## Solution Overview

The Ralph Wiggum Loop is an iterative development system that addresses context limitations by:

1. **Fresh Context Per Iteration** - Each loop iteration starts the agent with a clean slate
2. **Persistent Memory** - Critical information persists in files between iterations
3. **Incremental Progress** - Agent completes one focused task per iteration
4. **Self-Documenting** - All decisions and progress tracked in version control

The system enables agents to work on projects of arbitrary size by breaking work into discrete, manageable chunks while maintaining coherence through persistent documentation.

---

## Core Concepts

### The Ralph Loop

```
while not PROJECT_COMPLETE and not max_iterations:
    1. Agent reads specs/ and IMPLEMENTATION_PLAN.md (fresh context)
    2. Agent picks highest priority task
    3. Agent implements the task
    4. Agent updates IMPLEMENTATION_PLAN.md and/or PROGRESS.md
    5. Agent commits changes to git
    6. Agent exits (context discarded)
    → Loop continues with fresh agent instance
```

### Persistent Memory

The system maintains state through files that are read fresh each iteration:

- **`specs/`** - Single source of truth for requirements (written by humans)
- **`IMPLEMENTATION_PLAN.md`** - Prioritized list of remaining work (maintained by agents)
- **`PROGRESS.md`** - Historical record of completed tasks (maintained by agents)
- **Git history** - Complete audit trail of all changes
- **Logs** - Detailed execution trace for debugging

### Two Operating Modes

**Plan Mode**
- Analyzes specifications
- Reviews existing code
- Creates or updates IMPLEMENTATION_PLAN.md
- Does NOT implement functionality
- Can be run repeatedly to refine plans

**Build Mode**
- Executes tasks from IMPLEMENTATION_PLAN.md
- Implements functionality
- Runs tests and validation
- Updates documentation
- Makes git commits
- Loops until completion or max iterations

---

## Architecture

### Directory Structure

```
project-root/
├── ralph                          # Entry point wrapper script
├── specs/                         # Requirements & specifications (human-authored)
│   ├── feature-1.md
│   ├── feature-2.md
│   └── ralph-system.md           # This document
├── IMPLEMENTATION_PLAN.md         # Remaining work (agent-maintained)
├── PROGRESS.md                    # Completed work (agent-maintained)
├── .ralph/                        # Ralph tooling (hidden)
│   ├── loop.sh                    # Core loop implementation
│   ├── prompts/                   
│   │   ├── PROMPT_build.md        # Build mode instructions
│   │   └── PROMPT_plan.md         # Plan mode instructions
│   ├── logs/                      # Execution logs
│   │   └── YYYY-MM-DD_NNN.log
│   └── validate.sh                # Optional project-specific validation
├── src/                           # Project source code
└── .git/                          # Version control
```

### Component Specifications

#### `ralph` - Entry Point Script

**Purpose:** Clean CLI interface to the Ralph system

**Usage:**
```bash
./ralph                    # Build mode, unlimited iterations
./ralph 20                 # Build mode, max 20 tasks
./ralph plan               # Plan mode, unlimited iterations  
./ralph plan 5             # Plan mode, max 5 planning cycles
```

**Responsibilities:**
- Parse command-line arguments
- Delegate to `.ralph/loop.sh` with appropriate configuration
- Provide friendly error messages

#### `.ralph/loop.sh` - Core Loop

**Purpose:** Orchestrate agent iterations

**Responsibilities:**
1. Load appropriate prompt (plan or build mode)
2. Invoke agent with prompt
3. Capture full output to log file with timestamp
4. Check for PROJECT_COMPLETE marker
5. Execute optional validation hook
6. Perform git commit with descriptive message
7. Push to remote branch
8. Repeat until max iterations or PROJECT_COMPLETE

**Loop Control:**
- Exit conditions: Max iterations reached OR "PROJECT_COMPLETE" detected in IMPLEMENTATION_PLAN.md
- Iteration counter displayed between cycles
- Current git branch displayed at start
- Can be terminated via Ctrl-C at any time

**Logging:**
- All output tee'd to `.ralph/logs/YYYY-MM-DD_NNN.log`
- Log file includes:
  - Iteration number
  - Timestamps (start, end, duration)
  - Full agent output
  - Agent metrics (context usage, tokens, cost) if available via JSON output
  - Git commit hash

**Git Integration:**
```bash
# After each successful iteration
git add -A
git commit -m "ralph: <description of completed task>"
git push origin <current-branch>
```

#### `.ralph/prompts/PROMPT_plan.md` - Plan Mode Instructions

**Purpose:** Guide agent in analysis and planning activities

**Key Instructions:**
- Study specs/ to understand requirements
- Review existing IMPLEMENTATION_PLAN.md (if present)
- Analyze source code in src/
- Search for TODOs, placeholders, incomplete implementations
- Create or update IMPLEMENTATION_PLAN.md with prioritized task list
- **Do NOT implement functionality** - planning only
- If IMPLEMENTATION_PLAN.md doesn't exist, create it as first task

#### `.ralph/prompts/PROMPT_build.md` - Build Mode Instructions

**Purpose:** Guide agent in implementation activities

**Key Instructions:**
- Study specs/ to understand requirements
- Follow IMPLEMENTATION_PLAN.md - choose highest priority task
- Search codebase before implementing (don't duplicate)
- Implement the task completely (no placeholders)
- Run tests for affected code
- Update IMPLEMENTATION_PLAN.md:
  - Move completed task to PROGRESS.md
  - Document any discovered issues
  - Add new tasks if gaps found
- Commit changes with descriptive message
- Exit when task complete

**Important Behaviors:**
- Use subagents for parallel reads/searches
- Keep AGENTS.md operational only (no status bloat)
- Clean IMPLEMENTATION_PLAN.md periodically (move completed items to PROGRESS.md)
- Document bugs even if unrelated to current task
- Update specs/ if inconsistencies found

#### `.ralph/validate.sh` - Optional Validation Hook

**Purpose:** Project-specific quality checks between iterations

**Behavior:**
- If file exists and is executable, run it after each iteration
- If file doesn't exist, skip validation
- Exit code 0 = success, continue loop
- Exit code non-zero = failure (implementation TBD: stop or log and continue?)

**Example validation checks:**
- Run test suite
- Run linters
- Check build success
- Verify documentation updated
- Custom project-specific checks

---

## Document Specifications

### IMPLEMENTATION_PLAN.md

**Purpose:** Prioritized list of remaining work

**Format:**
```markdown
# Implementation Plan

## Remaining Tasks

1. [HIGH PRIORITY] Fix authentication bug in login handler
2. Add user profile API endpoint
3. Implement password reset flow
4. Add input validation to registration form
5. Optimize database queries in user service

## Notes

- All tests must pass before moving task to PROGRESS.md
- Use existing patterns in src/lib for shared utilities

PROJECT_COMPLETE
```

**Structure:**
- Simple ordered list (top = highest priority)
- Brief, actionable task descriptions
- Optional sections for notes, guidelines
- **PROJECT_COMPLETE marker** when all work done

**Maintenance:**
- Agents remove completed items (move to PROGRESS.md)
- Agents add discovered issues/gaps
- Agents re-prioritize as needed
- Plan mode can rebuild from specs/

### PROGRESS.md

**Purpose:** Audit trail of completed tasks

**Format:**
```markdown
# Progress Log

## Completed Tasks

### 2026-02-04
- [x] Refactored authentication module to use JWT
  - Commit: abc1234
  - All auth tests passing
  
- [x] Added user profile API endpoint
  - Commit: def5678
  - Includes GET and PUT methods
  - Added integration tests

### 2026-02-03
- [x] Set up initial project structure
  - Commit: xyz9012
```

**Structure:**
- Reverse chronological order (newest first)
- Grouped by date
- Include commit hash for traceability
- Brief notes on implementation details

**Maintenance:**
- Agents append completed tasks from IMPLEMENTATION_PLAN.md
- Keep as historical record (don't prune)
- Git history provides detailed changes

### specs/ - Requirements Documentation

**Purpose:** Human-authored source of truth for what to build

**Guidelines:**
- One spec file per major feature/component
- Capture the "why" not just the "what"
- Include examples, use cases, edge cases
- Update when requirements change or clarifications needed
- Agents may update specs if inconsistencies found (requires Opus-level reasoning)

**Example structure:**
```markdown
# Feature: User Authentication

## Overview
Description of feature and its purpose

## Requirements
- Functional requirements
- Non-functional requirements
- Security considerations

## API Specification
Endpoints, request/response formats

## Success Criteria
How to know it's done

## Open Questions
Things to resolve
```

---

## Completion Signals

### Task Completion (Implicit)

A task is complete when the agent exits. No explicit marker needed.

**Indicators:**
- Agent has committed changes
- Agent has updated documentation
- Agent has run tests (if applicable)
- Agent exits normally

### Project Completion (Explicit)

The entire project is complete when the agent adds "PROJECT_COMPLETE" to IMPLEMENTATION_PLAN.md.

**Detection:**
```bash
# In loop.sh after each iteration
if grep -q "PROJECT_COMPLETE" IMPLEMENTATION_PLAN.md; then
    echo "Project complete! All tasks finished."
    exit 0
fi
```

**Agent Decision Criteria:**
- IMPLEMENTATION_PLAN.md has no remaining tasks
- All specs/ requirements satisfied
- All tests passing
- Documentation complete

---

## Error Handling

### Error Categories

**Recoverable Errors** (document and continue)
- Test failures
- Build warnings
- Incomplete implementations discovered
- Integration issues
- Performance problems

**Action:** Agent documents in IMPLEMENTATION_PLAN.md for next iteration

**Fatal Errors** (stop the loop)
- Git push failures (after retries)
- Agent crashes
- Validation script failures (TBD)
- File system errors

**Action:** Loop exits with error message, human intervention required

### Error Documentation Format

Agents should add discovered issues to IMPLEMENTATION_PLAN.md:

```markdown
## Issues Discovered

- [BUG] Login fails with special characters in password
  - Discovered during: User profile implementation
  - Severity: High
  - Error: Invalid character escaping in auth module
```

---

## Logging and Metrics

### Log File Format

**Location:** `.ralph/logs/YYYY-MM-DD_NNN.log`

**Contents:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Iteration: 42
Mode: build
Branch: feature/user-auth
Started: 2026-02-04 16:30:15
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Full agent output here...]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Completed: 2026-02-04 16:32:47
Duration: 2m 32s
Commit: abc1234
Context: 45000/200000 tokens (22.5%)
Cost: $0.15
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Metrics Tracking

**If agent provides JSON output:**
- Parse context usage (current/max tokens)
- Parse token counts (input/output)
- Parse cost information
- Append to log file

**Aggregate metrics** (future enhancement):
- Total iterations
- Total time
- Total cost
- Average task duration
- Success/failure rates

---

## Multi-Agent Support

### Design Principles

**Primary:** Optimize for cline CLI
**Secondary:** Allow other agents without major complexity

### Agent Interface Requirements

Any agent must support:
1. **Prompt from file** - Accept prompt via file or stdin
2. **Exit on completion** - Finish task and terminate
3. **File I/O** - Read specs/, modify IMPLEMENTATION_PLAN.md
4. **Git operations** - Commit changes via git commands
5. **Optional JSON output** - For metrics extraction

### Agent Configuration

Use environment variable or config file:

```bash
# In loop.sh or ralph wrapper
RALPH_AGENT=${RALPH_AGENT:-cline}

case "$RALPH_AGENT" in
    cline)
        $RALPH_AGENT --yolo --output-format=json "$(cat $PROMPT_FILE)"
        ;;
    other-agent)
        $RALPH_AGENT --auto-approve --prompt-file="$PROMPT_FILE"
        ;;
esac
```

---

## Git Strategy

### Branch Management

- Loop operates on current branch
- Display branch name at loop start
- Create remote branch if doesn't exist
- Human decides when to merge to main

### Commit Strategy

**Frequency:** One commit per task (per iteration)

**Message Format:**
```
ralph: <brief description of task completed>

- Bullet points with details
- Changes made
- Tests status

<optional metadata>
```

**Example:**
```
ralph: implement user profile API endpoint

- Added GET /api/users/:id endpoint
- Added PUT /api/users/:id endpoint  
- Includes input validation
- Added integration tests
- All tests passing
```

### Rollback Strategy

Since each iteration creates a commit, rollback is straightforward:

```bash
# Undo last iteration
git reset --hard HEAD~1

# Undo last N iterations  
git reset --hard HEAD~N

# Return to specific commit
git reset --hard <commit-hash>
```

---

## Validation Hooks

### Purpose

Allow projects to define custom quality checks without modifying Ralph core.

### Implementation

**Location:** `.ralph/validate.sh`

**Behavior:**
```bash
# In loop.sh after agent exits
if [ -x ".ralph/validate.sh" ]; then
    echo "Running project validation..."
    if .ralph/validate.sh; then
        echo "✓ Validation passed"
    else
        echo "✗ Validation failed"
        # TBD: Stop loop or continue?
    fi
fi
```

**Example validation script:**
```bash
#!/bin/bash
# .ralph/validate.sh

set -e

echo "Running tests..."
npm test

echo "Running linter..."
npm run lint

echo "Checking build..."
npm run build

echo "All validation passed!"
```

---

## Success Criteria

### System is successful when:

1. **Enables Large Projects**
   - Can work on projects too large for single context window
   - Maintains coherence across hundreds of iterations
   - No degradation in quality over time

2. **Minimal Human Intervention**
   - Human writes specs, reviews progress periodically
   - Loop runs autonomously for extended periods
   - Clear stopping conditions

3. **Audit Trail**
   - Every change tracked in git
   - Every decision documented
   - Can understand project history

4. **Flexible and Extensible**
   - Works with different coding agents
   - Supports different project types
   - Easy to customize with validation hooks

5. **Developer Experience**
   - Simple to set up (`./ralph` just works)
   - Clear documentation
   - Helpful error messages
   - Observable progress

### Metrics for Success

- **Context efficiency:** Project completed within agent context limits
- **Iteration success rate:** % of iterations that complete cleanly
- **Human intervention rate:** How often human must intervene
- **Documentation quality:** Specs and plans remain accurate
- **Code quality:** Tests pass, linting passes, code reviews positive

---

## Future Enhancements

### Potential improvements (not in initial scope):

1. **Parallel execution** - Run multiple agents on different tasks simultaneously
2. **Cost optimization** - Use cheaper models for simple tasks
3. **Smart validation** - Learn which validations to run based on changed files
4. **Progress dashboard** - Web UI showing current status, metrics, history
5. **Agent learning** - Share successful patterns across projects
6. **Dependency tracking** - Understand task dependencies, optimize order
7. **Rollback automation** - Automatic rollback on validation failure
8. **Multi-repository** - Coordinate changes across multiple repos
9. **Human review points** - Optional gates requiring approval
10. **Template projects** - Starter templates for common project types

---

## Open Questions

1. **Validation failure handling:** Should loop stop or continue after validation failure?
   - Option A: Stop immediately (safe, may be annoying)
   - Option B: Log and continue (efficient, may accumulate problems)
   - Option C: Configurable via `.ralph/config`

2. **Error categorization:** Need concrete list of fatal vs recoverable errors

3. **PROGRESS.md growth:** Should there be automatic archiving after N entries?

4. **Multiple agents:** If supporting multiple agents, how to handle agent-specific features?

5. **Cost tracking:** Should there be cost limits/warnings?

---

## Implementation Notes

### Bootstrap Process

To build Ralph itself using Ralph:

1. Create `specs/ralph-system.md` (this document)
2. Run initial plan mode manually or with basic loop
3. Agent creates IMPLEMENTATION_PLAN.md
4. Iterate in build mode to implement components
5. Test with simple project
6. Refine based on learnings

### Testing Strategy

- **Unit tests:** Individual components (if complex logic)
- **Integration tests:** Full loop cycles on test projects
- **Real-world validation:** Use Ralph to build itself (dogfooding)

### Documentation

- README.md: Quick start guide
- This spec: Comprehensive reference
- Inline comments: Implementation details
- PROGRESS.md: Historical record of development

---

## References

- [Original Ralph post](https://ghuntley.com/ralph/)
- [Ralph Playbook](https://github.com/ClaytonFarr/ralph-playbook)
- [Accountability project](https://github.com/mikearnaldi/accountability)
- [The Real Ralph Wiggum Loop](https://thetrav.substack.com/p/the-real-ralph-wiggum-loop-what-everyone)
