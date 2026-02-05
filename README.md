# Ralph Wiggum Loop

An iterative development system that enables LLM coding agents to work on large projects by breaking work into discrete, manageable chunks with fresh context per iteration.

## Overview

The Ralph Wiggum Loop addresses the context window limitations of Large Language Models by:

- **Fresh Context Per Iteration** - Each loop iteration starts the agent with a clean slate
- **Persistent Memory** - Critical information persists in files between iterations
- **Incremental Progress** - Agent completes one focused task per iteration
- **Self-Documenting** - All decisions and progress tracked in version control

This enables agents to work on projects of arbitrary size while maintaining coherence through persistent documentation.

## Quick Start

```bash
# First time: Create a specification
mkdir -p specs
echo "# My Feature" > specs/my-feature.md
# Edit specs/my-feature.md with your requirements

# Start the build loop
./ralph

# Or with a maximum iteration limit
./ralph 10
```

The first iteration will create `IMPLEMENTATION_PLAN.md` from your specifications, then subsequent iterations will implement the tasks.

## Usage

### Build Mode (Autonomous Loop)

Build mode runs autonomously, implementing tasks from `IMPLEMENTATION_PLAN.md`:

```bash
./ralph              # Run until PROJECT_COMPLETE
./ralph 20           # Run for max 20 iterations
```

**First Iteration Behavior:**
- If `IMPLEMENTATION_PLAN.md` doesn't exist, the agent creates it from `specs/`
- Analyzes existing codebase structure
- Generates prioritized task list
- Commits and exits
- Next iteration begins implementing tasks

**Subsequent Iterations:**
- Agent reads `specs/` and `IMPLEMENTATION_PLAN.md` with fresh context
- Selects highest priority task
- Implements the task completely (no placeholders)
- Runs tests for affected code
- Updates `IMPLEMENTATION_PLAN.md` and `PROGRESS.md`
- Commits changes with descriptive message
- Exits (context discarded, loop continues)

**Loop Stops When:**
- `PROJECT_COMPLETE` marker detected in `IMPLEMENTATION_PLAN.md`
- Maximum iterations reached
- Fatal error occurs (git push failure, validation failure, etc.)
- User presses Ctrl-C

### Plan Mode (Interactive Session)

Plan mode is a single interactive session for writing specifications:

```bash
./ralph plan              # Start planning session
./ralph plan auth         # Planning session with 'auth' hint
```

**Plan Mode Behavior:**
- Agent engages in conversation to understand requirements
- Asks clarifying questions about use cases and edge cases
- Reviews existing `specs/` for context
- Helps structure and write a specification document
- Output: A well-structured spec file in `specs/`
- Does NOT create `IMPLEMENTATION_PLAN.md` (that's for build mode)
- Does NOT implement functionality
- Session ends when you're satisfied with the spec

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
│   │   ├── PROMPT_build.md        # Build mode instructions
│   │   └── PROMPT_plan.md         # Plan mode instructions
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
- See `specs/ralph-system-initial-implementation.md` for the Ralph system specification

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

## Workflow Example

### 1. Write Specification

Create `specs/user-auth.md`:

```markdown
# User Authentication

## Requirements
- JWT-based authentication
- Login endpoint: POST /api/auth/login
- Logout endpoint: POST /api/auth/logout
- Password validation: min 8 chars, special char required

## Success Criteria
- All endpoints return proper status codes
- Tests cover happy path and error cases
- Passwords are hashed with bcrypt
```

### 2. Start Build Loop

```bash
./ralph 10
```

**Iteration 1:** Agent creates `IMPLEMENTATION_PLAN.md`:
```markdown
# Implementation Plan

## Remaining Tasks

1. Create User model with password hashing
2. Add login endpoint with JWT generation
3. Add logout endpoint
4. Add password validation
5. Add authentication tests
```

**Iteration 2:** Agent implements User model, updates docs, commits

**Iteration 3:** Agent implements login endpoint, updates docs, commits

**Iterations 4-5:** Agent completes remaining tasks

**Final Iteration:** Agent adds `PROJECT_COMPLETE` marker, loop stops

### 3. Review Results

```bash
# View progress
cat PROGRESS.md

# View logs
ls -la .ralph/logs/

# Review commits
git log --oneline
```

## Monitoring Progress

### View Logs

Logs are stored in `.ralph/logs/YYYY-MM-DD_NNN.log`:

```bash
# View latest log
ls -t .ralph/logs/*.log | head -1 | xargs cat

# Tail current iteration
ls -t .ralph/logs/*.log | head -1 | xargs tail -f
```

Each log includes:
- Iteration number and timestamps
- Full agent output
- Duration and commit hash
- Exit code

### Check Status

```bash
# View remaining tasks
cat IMPLEMENTATION_PLAN.md

# View completed tasks
cat PROGRESS.md

# View recent commits
git log --oneline -10
```

## Validation Hooks

Create `.ralph/validate.sh` for custom quality checks:

```bash
#!/bin/bash
set -e

echo "Running tests..."
npm test

echo "Running linter..."
npm run lint

echo "✓ All validation passed!"
```

Make it executable:
```bash
chmod +x .ralph/validate.sh
```

**Behavior:**
- Runs after each iteration (if file exists and is executable)
- Exit code 0 = validation passed, continue loop
- Exit code non-zero = FATAL, stop loop immediately
- Agent runs its own tests during implementation
- This is a final quality gate before continuing

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

## Configuration

### Environment Variables

```bash
# Iteration timeout (default: 1800 seconds = 30 minutes)
export RALPH_ITERATION_TIMEOUT=3600

# Agent command (default: cline)
export RALPH_AGENT=cline
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

## Advanced Usage

### Rollback Iterations

Each iteration creates a commit, making rollback straightforward:

```bash
# Undo last iteration
git reset --hard HEAD~1

# Undo last N iterations
git reset --hard HEAD~N

# Return to specific commit
git reset --hard <commit-hash>

# Update remote (requires force push)
git push --force origin $(git branch --show-current)
```

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

## Example: Calculator Module

The project includes a simple calculator module as a test implementation to validate the Ralph system functionality.

### Running Calculator Tests

```bash
node src/lib/calculator.test.js
```

Expected output:
```
✓ add: positive numbers
✓ add: negative numbers
✓ add: with zero
✓ subtract: positive numbers
✓ subtract: negative numbers
✓ subtract: with zero
✓ multiply: positive numbers
✓ multiply: negative numbers
✓ multiply: by zero
✓ multiply: by one
✓ divide: positive numbers
✓ divide: negative numbers
✓ divide: by one
✓ divide: by zero throws error
✓ add: invalid input throws TypeError
✓ subtract: invalid input throws TypeError
✓ multiply: invalid input throws TypeError
✓ divide: invalid input throws TypeError

All tests passed! (18/18)
```

### Calculator Usage

```javascript
const { add, subtract, multiply, divide } = require('./src/lib/calculator');

// Basic operations
console.log(add(5, 3));        // 8
console.log(subtract(10, 4));  // 6
console.log(multiply(3, 7));   // 21
console.log(divide(15, 3));    // 5

// Error handling
try {
    divide(10, 0);  // Throws: "Cannot divide by zero"
} catch (e) {
    console.error(e.message);
}

try {
    add('5', 3);  // Throws TypeError: "Both arguments must be numbers"
} catch (e) {
    console.error(e.message);
}
```

### Calculator Features

- **Basic Operations:** add, subtract, multiply, divide
- **Input Validation:** All functions validate that inputs are numbers
- **Error Handling:** 
  - Division by zero throws Error
  - Non-numeric inputs throw TypeError
- **Test Coverage:** 18 comprehensive tests covering all operations and edge cases

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
- [Ralph Playbook](https://github.com/ClaytonFarr/ralph-playbook)
- [Accountability project](https://github.com/mikearnaldi/accountability)
- [The Real Ralph Wiggum Loop](https://thetrav.substack.com/p/the-real-ralph-wiggum-loop-what-everyone)

## Full Documentation

For complete system specification, architecture details, and implementation notes, see `specs/ralph-system-initial-implementation.md`.

## License

See LICENSE file for details.
