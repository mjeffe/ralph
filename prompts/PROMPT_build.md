# Ralph Build Mode Instructions

## Context Awareness

**IMPORTANT:** You start each iteration with FRESH CONTEXT.
- You do NOT remember previous iterations
- All state persists in: `specs/`, `IMPLEMENTATION_PLAN.md`, `PROGRESS.md`, and git history
- Re-read these files every iteration to understand current state

---

## Iteration Start

### 0. First Iteration Check

**If IMPLEMENTATION_PLAN.md does NOT exist:**
1. Read all specifications in `specs/` (start with `specs/README.md` for guidance)
2. Analyze existing codebase structure in `src/`
3. Generate a prioritized task list in `IMPLEMENTATION_PLAN.md`
4. Commit changes with message: "ralph: create implementation plan from specifications"
5. Push changes
6. **EXIT** - Next iteration will begin implementing tasks

**If IMPLEMENTATION_PLAN.md exists:** Continue to step 1 below.

### 1. Read Current State

a. Study `specs/*` with parallel Sonnet subagents to understand requirements
b. Study `IMPLEMENTATION_PLAN.md` to see remaining tasks and priorities
c. Study `PROGRESS.md` to understand what has been completed
d. Review application source code in `src/*` for context

---

## Task Selection

### 2. Choose Task from IMPLEMENTATION_PLAN.md

Select the task to work on using these criteria:
- Choose the **HIGHEST PRIORITY** task you can complete
- Read `IMPLEMENTATION_PLAN.md` carefully for dependencies and notes
- Prefer tasks that **unblock other work**
- If a task seems unclear or too large, **break it down first** (update the plan)
- Document your reasoning for task choice in the commit message

**Task Blocking Protocol:**
- If you fail to complete a task after multiple attempts:
  - Add `[BLOCKED]` tag to the task in `IMPLEMENTATION_PLAN.md`
  - Document the blocking issue in the Notes section
  - Move to the next unblocked task
  - Human intervention will be required to resolve the blockage

---

## Implementation

### 3. Search Before Implementing

**CRITICAL:** Before implementing ANY feature:
- Search the codebase thoroughly using parallel Sonnet subagents
- **Do NOT assume** something isn't already implemented
- Check for existing patterns and conventions to follow
- Avoid duplicating functionality

### 4. Implement the Task

- Use parallel Sonnet subagents for searches and reads (scale as needed)
- Use **ONE** Sonnet subagent for builds and tests (avoid parallel execution issues)
- Use Opus subagents when complex reasoning is needed (debugging, architectural decisions)
- **Implement functionality COMPLETELY** - no placeholders, no stubs, no TODOs
- Follow existing patterns and conventions in the codebase
- Use Ultrathink for complex decisions

### 5. Run Tests

- Run tests for the unit of code you modified or added
- If tests fail, fix them - this is part of your task
- If functionality is missing, add it per the specifications
- **All tests must pass** before proceeding

### 6. Handle Discovered Issues

**If you discover bugs or issues (even if unrelated to current task):**
- Document them in `IMPLEMENTATION_PLAN.md` using a subagent
- If you can resolve them as part of current work, do so
- Tests unrelated to your work that are failing MUST be fixed as part of this iteration

**If you find inconsistencies in specs/:**
- Use an Opus 4.5 subagent with 'ultrathink' to update the specs
- Document the change in your commit message

---

## Documentation

### 7. Update IMPLEMENTATION_PLAN.md

After completing your task:
- **Move the completed task** from `IMPLEMENTATION_PLAN.md` to `PROGRESS.md`
- Remove it from the Remaining Tasks section
- Add any newly discovered tasks or issues
- Update priorities if needed
- Use a subagent to keep this file current - future iterations depend on accuracy

**Periodic Cleanup:**
When `IMPLEMENTATION_PLAN.md` becomes large, clean out completed items (they should be in `PROGRESS.md`)

### 8. Update PROGRESS.md

Add the completed task to `PROGRESS.md` with:
- Current date as section header (YYYY-MM-DD)
- Task description with `[x]` checkbox
- Commit hash (you'll add this after committing)
- Brief implementation notes
- Keep in **reverse chronological order** (newest first)

**Format:**
```markdown
### YYYY-MM-DD
- [x] Task description
  - Commit: <hash>
  - Implementation notes
  - Test status
```

### 9. Update specs/README.md (When Applicable)

**Only when ALL tasks for a specific spec are fully implemented:**
- Verify all tests for that spec pass
- Update `specs/README.md` to mark the spec as "Implemented"
- Include completion date

### 10. Capture the Why

When authoring documentation:
- Capture the **why**, not just the what
- Explain the reasoning behind implementation decisions
- Document test importance and coverage

---

## Completion

### 11. Project Completion Check

**If ALL tasks in IMPLEMENTATION_PLAN.md are complete:**
1. Verify all `specs/` requirements are satisfied
2. Ensure all tests are passing
3. Confirm documentation is complete
4. Add `PROJECT_COMPLETE` marker to `IMPLEMENTATION_PLAN.md`
5. This marker will stop the Ralph loop

### 12. Git Commit and Push

**Commit message format:**
```
ralph: <brief description of task completed>

- Bullet points with implementation details
- Changes made
- Tests status
- Any important notes
```

**Example:**
```
ralph: implement user profile API endpoint

- Added GET /api/users/:id endpoint
- Added PUT /api/users/:id endpoint with validation
- Input validation: name required, bio max 500 chars
- Added integration tests
- All tests passing
```

**Commands:**
```bash
git add -A
git commit -m "<message>"
git push
```

### 13. Exit

**CRITICAL:** Complete ONE task per iteration and EXIT
- Do **not** attempt multiple tasks in a single iteration
- Exit after: implementing + testing + updating docs + committing + pushing
- The loop will restart you with fresh context for the next task

---

## Error Handling

**Recoverable Errors** (document in IMPLEMENTATION_PLAN.md):
- Test failures you can fix
- Linting issues
- Build warnings
- Performance problems discovered

**Fatal Errors** (exit immediately, human intervention required):
- Git push failures after retries
- File system errors
- Cannot read `specs/` directory
- External validation failures

---

## Subagent Strategy

- **Parallel Sonnet subagents:** For reading and searching files (scale as needed for efficiency)
- **Single Sonnet subagent:** For builds and tests (avoid parallel execution conflicts)
- **Opus subagents:** For complex reasoning tasks (debugging, architectural decisions, spec updates)
- **Background subagents:** Update `IMPLEMENTATION_PLAN.md` with a subagent to keep it current

---

## Key Principles

1. **Single sources of truth** - No migrations, no adapters
2. **Complete implementations** - No placeholders or stubs
3. **Search before building** - Don't duplicate existing functionality
4. **One task per iteration** - Complete it fully, then exit
5. **Keep plans current** - Future work depends on accurate documentation
6. **Fix what you find** - Don't ignore unrelated test failures
7. **Fresh context** - All state is in files, not your memory
