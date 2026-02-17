# Ralph System Specification

## Problem Statement

Large Language Models (LLMs) and coding agents have limited context windows, which constrains their ability to work on large projects or maintain context over extended development sessions. As projects grow in complexity, the agent's context becomes saturated with information, leading to degraded performance, forgotten requirements, and inability to maintain coherent long-term development.

Additionally, many development workflow systems become overcomplicated by trying to integrate too many features into a single tool. This adds cognitive overhead and maintenance burden without providing clear benefits over using dedicated tools for each concern.

## Solution Overview

The Ralph Wiggum Loop is an iterative development system that addresses context limitations by:

1. **Fresh Context Per Iteration** - Each loop iteration starts the agent with a clean slate
2. **Persistent Memory** - Critical information persists in files between iterations
3. **Incremental Progress** - Agent completes one focused task per iteration
4. **Self-Documenting** - All decisions and progress tracked in version control
5. **Single Purpose** - Focuses solely on autonomous build loops, not specification writing

The system enables agents to work on projects of arbitrary size by breaking work into discrete, manageable chunks while maintaining coherence through persistent documentation.

**Design Philosophy:** Ralph handles autonomous build loops. Specifications are written manually or with any tool you prefer (cline CLI directly, ChatGPT, Claude, etc.). This separation keeps Ralph simple and focused.

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

---

## Architecture

### Directory Structure

```
project-root/
├── ralph                          # Entry point wrapper script
├── specs/                         # Requirements & specifications (human-authored)
│   ├── README.md                  # Index of specs with status tracking
│   ├── feature-1.md               # Individual feature specs
│   ├── feature-2.md
│   ├── ralph-system-implementation.md  # This document
│   └── archive/                   # Obsolete specs
├── IMPLEMENTATION_PLAN.md         # Remaining work (agent-maintained)
├── PROGRESS.md                    # Completed tasks log (agent-maintained)
├── .ralph/                        # Ralph tooling (hidden)
│   ├── loop.sh                    # Core loop implementation
│   ├── prompts/                   
│   │   └── PROMPT_build.md        # Build mode instructions
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
./ralph 20                 # Build mode, max 20 iterations
```

**Responsibilities:**
- Parse command-line arguments
- Delegate to `.ralph/loop.sh` with appropriate configuration
- Provide friendly error messages
- Run prerequisite checks

#### `.ralph/loop.sh` - Core Loop

**Purpose:** Orchestrate agent iterations

**Responsibilities:**
1. Load PROMPT_build.md
2. Run health checks before iteration
3. Invoke agent with prompt (with timeout)
4. Capture full output to log file with timestamp
5. Check for PROJECT_COMPLETE marker
6. Execute optional validation hook
7. Perform git commit with descriptive message
8. Push to remote branch (with retry logic)
9. Repeat until max iterations or PROJECT_COMPLETE

**Loop Control:**
- Exit conditions: Max iterations reached OR "PROJECT_COMPLETE" detected in IMPLEMENTATION_PLAN.md
- Iteration counter displayed between cycles
- Current git branch displayed at start
- Can be terminated via Ctrl-C at any time

**Health Checks:**
Before each iteration, run lightweight checks (isolated in functions):
```bash
check_health() {
    check_disk_space || warn "Low disk space (< 1GB available)"
    check_git_repo || fatal "Not a git repository"
    check_specs_readable || fatal "Cannot read specs/ directory"
    check_agent_available || fatal "Agent binary not found"
}
```
Warnings are logged but don't stop loop. Fatal errors exit immediately.

**Iteration Timeout:**
Each iteration has a maximum duration (default: 30 minutes):
```bash
# Kill agent if it exceeds timeout
timeout 30m $AGENT_COMMAND || {
    echo "FATAL: Agent exceeded iteration timeout"
    exit 1
}
```
Configuration can be adjusted based on project needs.

**Agent Invocation:**
```bash
# Example for cline agent
cat "$PROMPT_FILE" | cline --yolo
```

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

# Push with retry logic
push_with_retry || exit 1
```

#### `.ralph/prompts/PROMPT_build.md` - Build Instructions

**Purpose:** Guide agent in implementation activities

**Key Instructions:**
- **First iteration check:** If IMPLEMENTATION_PLAN.md doesn't exist:
  - Read all specs in specs/ (especially specs/README.md for guidance)
  - Analyze existing codebase
  - Generate prioritized task list in IMPLEMENTATION_PLAN.md
  - Commit and exit (next iteration will start implementing)
- **Subsequent iterations:**
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

**Task Selection Criteria:**
When choosing which task to work on from IMPLEMENTATION_PLAN.md:
- Select the highest priority task you can complete
- Read IMPLEMENTATION_PLAN.md carefully for dependencies and notes
- Prefer tasks that unblock other work
- If a task seems unclear or too large, break it down first (update plan)
- Document your reasoning for task choice in commit message
- If you fail to complete a task after multiple attempts, mark it [BLOCKED] and document the blocking issue, then move to next task

**Important Behaviors:**
- Keep AGENTS.md operational only (no status bloat)
- Clean IMPLEMENTATION_PLAN.md periodically (move completed items to PROGRESS.md)
- Document bugs even if unrelated to current task
- Update specs/ if inconsistencies found
- When all specs implemented, update specs/README.md to mark them as "Implemented"

#### `.ralph/validate.sh` - Optional Validation Hook

**Purpose:** Project-specific quality checks between iterations

**Behavior:**
- If file exists and is executable, run it after each iteration
- If file doesn't exist, skip validation
- Exit code 0 = validation passed, continue loop
- Exit code non-zero = FATAL, stop loop immediately
- Agent is responsible for running and fixing its own tests during implementation
- This validation is a final quality gate before continuing to next iteration

**Example validation checks:**
- Run test suite
- Run linters
- Check build success
- Verify documentation updated
- Custom project-specific checks

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

echo "✓ All validation passed!"
```

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
```

**Note:** The `PROJECT_COMPLETE` marker should only be added when all tasks are finished.

**Structure:**
- Simple ordered list (top = highest priority)
- Brief, actionable task descriptions
- Optional sections for notes, guidelines
- **PROJECT_COMPLETE marker** when all work done

**Maintenance:**
- Created by agents in build mode (first iteration if it doesn't exist)
- Agents remove completed items (move to PROGRESS.md)
- Agents add discovered issues/gaps
- Agents re-prioritize as needed
- Can be regenerated from specs/ by deleting it and starting build mode

**Handling Stuck Tasks:**
If agent repeatedly fails same task:
- Track attempt count implicitly via git history review
- After ~3 iterations on same task with no progress:
  - Agent should add [BLOCKED] tag to task
  - Document blocking issue in Notes section
  - Move to next task
- Human intervention required to unblock

**Example with blocked task:**
```markdown
## Remaining Tasks

1. [BLOCKED] Fix authentication bug in login handler
   - Blocked by: Unclear requirements for password special char handling
   - Needs: Clarification from human or update to specs/
   
2. [HIGH PRIORITY] Add user profile API endpoint
   (Agent should work on this next)
```

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

**Directory Structure:**
```
specs/
├── README.md              # Index of all specs with status tracking
├── feature-1.md           # Individual feature specifications
├── feature-2.md
├── ralph-system-implementation.md  # This document
└── archive/               # Obsolete specs
```

**Guidelines:**
- One spec file per major feature/component
- Capture the "why" not just the "what"
- Include examples, use cases, edge cases
- Update when requirements change or clarifications needed
- Agents may update specs if inconsistencies found (requires high confidence)
- Add metadata headers to each spec for machine-readability

**Spec Metadata Headers:**
Each spec should include frontmatter for tracking:
```markdown
---
status: active | implemented | obsolete | superseded-by
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [tag1, tag2]
dependencies: [other-spec.md]
supersedes: old-spec.md
---
```

**Example Spec Structure:**
```markdown
---
status: active
created: 2026-02-01
updated: 2026-02-04
tags: [authentication, security, backend]
---

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

### specs/README.md - Specification Index

**Purpose:** Index of all specifications with status tracking (strategic overview)

**This is DIFFERENT from PROGRESS.md:**
- **specs/README.md** = Feature-level requirement status ("which features are done?")
- **PROGRESS.md** = Task-level work log ("what tasks were completed today?")

**Format:**
```markdown
# Specification Index

This document tracks the status of all feature specifications. Agents should consult this file to understand which specs are currently relevant.

## Active Specifications

### User Authentication (auth-system.md)
- **Status:** Active
- **Priority:** High
- **Dependencies:** database-schema.md
- **Last Updated:** 2026-02-04
- **Summary:** OAuth2 + JWT authentication with session management

### User Profiles (user-profiles.md)
- **Status:** Active
- **Priority:** Medium
- **Dependencies:** auth-system.md
- **Last Updated:** 2026-02-03
- **Summary:** User profile management with avatar upload

## Implemented Specifications

### Database Schema (database-schema.md)
- **Status:** Implemented
- **Completed:** 2026-02-01
- **Summary:** PostgreSQL schema for users, sessions, and profiles

## Archived Specifications

Obsolete or superseded specs moved to specs/archive/ for historical reference.
See specs/archive/ for the full list.
```

**Maintenance:**
- Agents update status when ALL TASKS for a spec are fully implemented
  - Check IMPLEMENTATION_PLAN.md - are all tasks for this spec completed?
  - Run tests - do they all pass?
  - If yes, mark spec as "Implemented" with completion date
- Agents add new specs to the index when created
- Agents mark specs as superseded when replaced
- Human reviews and approves major status changes

**Relationship to IMPLEMENTATION_PLAN.md:**
- specs/README.md = Feature-level status ("User Auth spec is implemented")
- IMPLEMENTATION_PLAN.md = Task-level work ("Fix auth bug, add endpoint X")
- A spec may have many tasks; spec is "Implemented" only when ALL tasks complete

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

The following examples illustrate fatal vs recoverable errors. This is not an exhaustive list, but provides guidance for categorization.

**Recoverable Errors** (document and continue)

Examples include:
- Test failures during implementation (agent should fix)
- Build warnings
- Linting issues
- Network timeouts (with retry logic)
- API rate limits (with backoff)
- Performance problems discovered

**Action:** Agent documents in IMPLEMENTATION_PLAN.md for current or future iteration

**Fatal Errors** (stop the loop)

Examples include:
- Git push failures (after retries)
- Agent process crashes
- External validation script (.ralph/validate.sh) failures
- File system full/permissions errors
- Unable to read specs/ directory
- Iteration timeout exceeded

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

### Log Retention and Cleanup

**Retention Policy:**
Ralph automatically cleans up old log files on startup to prevent disk space accumulation while preserving recent history.

**Policy Rules:**
- Keep at least **30 days** of logs OR **30 log files**, whichever is greater
- Cleanup runs at Ralph startup (before creating new log file)
- Only `.log` files in `.ralph/logs/` are affected
- No external dependencies (cron, logrotate, etc.) required

**Examples:**

*Example 1: File count protection*
- Have 50 log files, oldest is 29 days old
- **Result:** Keep all files (age rule protects all)

*Example 2: Age protection*  
- Have 20 log files, oldest is 31 days old
- **Result:** Keep all files (count rule protects all, need at least 30 files)

*Example 3: Cleanup triggered*
- Have 40 log files, last 5 are older than 30 days
- **Result:** Delete oldest 5 files (neither rule protects them)

**Implementation Details:**
- Files sorted by modification time (mtime)
- Protection set built from:
  - All files newer than 30 days (by mtime)
  - Most recent 30 files (regardless of age)
- Files not in protection set are deleted
- Cleanup status logged to terminal when files are removed

**Manual Cleanup:**
If needed, logs can be manually removed:
```bash
# Remove logs older than 60 days
find .ralph/logs -name "*.log" -type f -mtime +60 -delete

# Remove all but most recent 10 logs
ls -t .ralph/logs/*.log | tail -n +11 | xargs rm -f
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
        cat $PROMPT_FILE | $RALPH_AGENT --yolo
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

#### When to Rollback

Consider rolling back iterations when:
- Tests that were passing now fail
- Agent introduced obvious bugs or security issues
- Agent misunderstood requirements (check against specs/)
- Unnecessary refactoring or scope creep
- Agent got stuck in an unproductive direction

```bash
# After rollback, force push to update remote
git push --force origin $(git branch --show-current)
```

⚠️ **Warning:** Force push required after rollback. Ensure coordination if multiple people are working on the branch.

### Git Push with Retry Logic

```bash
push_with_retry() {
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if git push origin $(git branch --show-current); then
            echo "✓ Push successful"
            return 0
        fi
        echo "Push failed (attempt $attempt/$max_attempts), retrying in 5s..."
        sleep 5
        attempt=$((attempt + 1))
    done
    
    echo "FATAL: Git push failed after $max_attempts attempts"
    return 1
}
```

If push fails after retries:
- Check network connectivity
- Verify remote branch permissions
- Check for remote conflicts
- Review `.git/config` for correct remote URL

---

## Bootstrap and Setup

### Prerequisites

- Git repository initialized (`git init`)
- Agent (cline) installed and available in PATH
- At least one specification document in specs/

### Setting Up Ralph in a New Project

**Step 1: Create Directory Structure**

```bash
# Create Ralph directories
mkdir -p .ralph/{prompts,logs}

# Create specs directory if it doesn't exist
mkdir -p specs
```

**Step 2: Add Entry Point Script**

Create `ralph` in project root:
```bash
#!/bin/bash
# Delegates to .ralph/loop.sh with appropriate arguments
exec .ralph/loop.sh "$@"
```

Make it executable:
```bash
chmod +x ralph
```

**Step 3: Create loop.sh**

Create `.ralph/loop.sh` (see Component Specifications section for implementation details).

Make it executable:
```bash
chmod +x .ralph/loop.sh
```

**Step 4: Write Initial Specification**

Create spec files manually or with any tool you prefer:

```bash
# Option 1: Manual creation
touch specs/my-feature.md
# Edit with your requirements

# Option 2: Use cline CLI directly
cline --plan "Help me write a specification for my-feature"

# Option 3: Use any other AI assistant
# Use ChatGPT, Claude, or other tool to draft your spec
```

**Step 5: Create Prompt File**

Create `.ralph/prompts/PROMPT_build.md` with build instructions for the agent.

**Step 6: Optional Validation**

Create `.ralph/validate.sh` if you want automated validation:
```bash
#!/bin/bash
set -e
npm test
npm run lint
```

Make it executable:
```bash
chmod +x .ralph/validate.sh
```

**Step 7: Start Building**

```bash
# First iteration will create IMPLEMENTATION_PLAN.md
./ralph

# Or with max iterations
./ralph 10
```

### Operational Constraints

While the loop is running:
- **DO NOT** manually edit IMPLEMENTATION_PLAN.md or PROGRESS.md
- **DO NOT** make git commits manually
- **DO NOT** delete or move files the agent might access
- **YOU CAN:** View files, tail logs, prepare next spec in specs/

To make manual changes: Press Ctrl-C to stop the loop, make your changes, then restart the loop.

---

## Creating Specifications

Ralph focuses on autonomous build loops. Specifications should be created outside of Ralph using any method you prefer:

### Option 1: Manual Specification Writing

```bash
touch specs/my-feature.md
# Edit the file with your requirements
```

### Option 2: Using Cline CLI Directly

```bash
cline --plan "Help me write a specification for my-feature in specs/my-feature.md"
```

### Option 3: Using Any AI Assistant

Use ChatGPT, Claude, or any other AI tool to help draft your specification document, then save it to `specs/`.

### Option 4: Pair Programming

Discuss requirements with a colleague and document them together in a spec file.

**The key principle:** Ralph doesn't prescribe how you create specs. Use whatever process works best for you.

---

## Troubleshooting

### Common Issues

**Loop exits immediately after starting**
- **Check:** Is `PROJECT_COMPLETE` marker in IMPLEMENTATION_PLAN.md?
  - Solution: Remove marker if work remains
- **Check:** Did validation script fail?
  - Solution: Review latest log in `.ralph/logs/`, fix validation issues
- **Check:** Did health checks fail?
  - Solution: Review error messages, fix prerequisites

**Agent not following IMPLEMENTATION_PLAN.md tasks**
- **Check:** Are tasks well-defined and actionable?
  - Solution: Break down vague tasks into specific steps
- **Check:** Is PROMPT_build.md clear about task selection?
  - Solution: Review and enhance prompt instructions
- **Try:** Delete IMPLEMENTATION_PLAN.md and let agent regenerate it

**Git push failures**
- **Check:** Network connectivity to git remote
  - Solution: Verify with `git remote -v` and test network
- **Check:** Branch exists on remote and you have push permissions
  - Solution: Manually push once to create branch
- **Check:** Conflicts with remote branch
  - Solution: Resolve conflicts manually, restart loop

**High costs per iteration**
- **Review:** Are tasks too large or vague?
  - Solution: Break large tasks into smaller, focused chunks
- **Check:** Is agent reading too many files?
  - Solution: Review specs/ to ensure clear scope boundaries
- **Consider:** Add more specific guidance in PROMPT_build.md

**Agent modifying unrelated files**
- **Review:** Are specs/ clear about scope and boundaries?
  - Solution: Add explicit "out of scope" section to specs
- **Check:** Is AGENTS.md too broad in its guidance?
  - Solution: Make AGENTS.md more specific to project conventions

**Agent keeps failing same task**
- **Check:** Has agent marked task as [BLOCKED]?
  - Solution: Review blocking issue, update specs/ or provide clarification
- **Check:** Are requirements clear in specs/?
  - Solution: Enhance spec with examples and edge cases
- **Try:** Manually implement part of the task to unblock agent

**Tests keep failing across iterations**
- **Check:** Are tests overly strict or flaky?
  - Solution: Review test quality, fix flaky tests
- **Check:** Did agent misunderstand requirements?
  - Solution: Clarify specs/, possibly rollback and restart
- **Check:** Is validation script misconfigured?
  - Solution: Test validation script manually

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

1. **Configuration file** - `.ralph/config` for iteration timeout, cost limits, validation behavior
2. **File locking** - Prevent concurrent modifications if multiple agents supported
3. **PROGRESS.md archiving** - Auto-archive old entries after N days to separate files
4. **Cost tracking** - Per-iteration and cumulative cost limits with warnings
5. **Parallel execution** - Run multiple agents on different tasks simultaneously (requires file locking)
6. **Cost optimization** - Use cheaper models for simple tasks
7. **Smart validation** - Learn which validations to run based on changed files
8. **Progress dashboard** - Web UI showing current status, metrics, history
9. **Agent learning** - Share successful patterns across projects
10. **Dependency tracking** - Understand task dependencies, optimize order
11. **Rollback automation** - Automatic rollback on validation failure
12. **Multi-repository** - Coordinate changes across multiple repos
13. **Human review points** - Optional gates requiring approval
14. **Template projects** - Starter templates for common project types

---

## References

- [Original Ralph post](https://ghuntley.com/ralph/)
- [Ralph Playbook](https://github.com/ClaytonFarr/ralph-playbook)
- [Accountability project](https://github.com/mikearnaldi/accountability)
- [The Real Ralph Wiggum Loop](https://thetrav.substack.com/p/the-real-ralph-wiggum-loop-what-everyone)
