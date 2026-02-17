# Ralph Build Mode Instructions

## Context Awareness

**IMPORTANT:** You start each iteration with FRESH CONTEXT.
- You do NOT remember previous iterations
- All state persists in: `specs/`, `.ralph/IMPLEMENTATION_PLAN.md`, and git history
- Re-read these files every iteration to understand current state

---

## Iteration Start

### 0. First Iteration Check

**If .ralph/IMPLEMENTATION_PLAN.md does NOT exist OR has no remaining tasks:**
1. Read all specifications in `specs/` (start with `specs/README.md` for guidance)
2. Analyze existing codebase structure
3. **SEARCH the codebase for each spec** to determine what's already implemented:
   - Use search_files to look for feature-related code, functions, and patterns
   - Check files and locations explicitly mentioned in specs (e.g., line numbers, file paths)
   - Search for key terms, feature names, and functionality described in specs
   - Don't rely on assumptions - verify implementation status with actual code
4. **Read detailed planning instructions:** `.ralph/prompts/PROMPT_implementation_plan.md`
5. Generate a prioritized task list in `.ralph/IMPLEMENTATION_PLAN.md` with ONLY unimplemented features
   - Follow the format template, granularity guidelines, and prioritization criteria
   - **IMPORTANT:** Do NOT create the `.ralph/PROJECT_COMPLETE` file when first creating the plan
   - The completion file should only be created when ALL tasks are finished (see step 11)
6. Commit changes with message: "ralph: create implementation plan from specifications"
7. Push changes
8. **EXIT** - Next iteration will begin implementing tasks

**If .ralph/IMPLEMENTATION_PLAN.md exists AND has remaining tasks:** Continue to step 1 below.

### 1. Read Current State

a. Study `specs/*` with parallel subagents to understand requirements
b. Study `.ralph/IMPLEMENTATION_PLAN.md` to see remaining tasks and priorities
c. Review application source code for context

---

## Task Selection

### 2. Choose Task from .ralph/IMPLEMENTATION_PLAN.md

Select the task to work on using these criteria:
- Choose the **HIGHEST PRIORITY** task you can complete
- Read `.ralph/IMPLEMENTATION_PLAN.md` carefully for dependencies and notes
- Prefer tasks that **unblock other work**
- If a task seems unclear or too large, **break it down first** (update the plan)
- Document your reasoning for task choice in the commit message

**Task Blocking Protocol:**
- If you fail to complete a task after multiple attempts:
  - Add `[BLOCKED]` tag to the task in `.ralph/IMPLEMENTATION_PLAN.md`
  - Document the blocking issue in the Notes section
  - Move to the next unblocked task
  - Human intervention will be required to resolve the blockage

---

## Implementation

### 3. Search Before Implementing

**CRITICAL:** Before implementing ANY feature:
- Search the codebase thoroughly using parallel subagents
- **Do NOT assume** something isn't already implemented
- Check for existing patterns and conventions to follow
- Avoid duplicating functionality

### 4. Implement the Task

- Use parallel subagents for searches and reads (scale as needed)
- Use **ONE** subagent for builds and tests (avoid parallel execution issues)
- Use subagents when complex reasoning is needed (debugging, architectural decisions)
- **Implement functionality COMPLETELY** - no placeholders, no stubs, no TODOs
- Follow existing patterns and conventions in the codebase
- Think very hard (use ultrathink) for complex decisions

### 5. Run Tests

- Run tests for the unit of code you modified or added
- If tests fail, fix them - this is part of your task
- If functionality is missing, add it per the specifications
- **All tests must pass** before proceeding

### 6. Handle Discovered Issues

**If you discover bugs or issues (even if unrelated to current task):**
- Document them in `.ralph/IMPLEMENTATION_PLAN.md` using a subagent
- If you can resolve them as part of current work, do so
- Tests unrelated to your work that are failing MUST be fixed as part of this iteration

**If you find inconsistencies in specs/:**
- Use an subagent (with 'ultrathink') to update the specs
- Document the change in your commit message

---

## Documentation

**Read detailed documentation instructions:** `.ralph/prompts/PROMPT_documentation.md`

### 7. Update .ralph/IMPLEMENTATION_PLAN.md

After completing your task:
- Remove the completed task from Remaining Tasks section
- Add any newly discovered tasks or issues
- Update priorities if needed
- Document blockers with `[BLOCKED]` tag if needed

### 8. Update specs/README.md (When Applicable)

**Only when ALL tasks for a specific spec are fully implemented:**
- Verify all tests for that spec pass
- Update `specs/README.md` to mark the spec as "Implemented"
- Include completion date

### 9. Capture the Why

When authoring documentation:
- Capture the **why**, not just the what
- Explain reasoning behind implementation decisions
- Document important context for future iterations

**See `.ralph/prompts/PROMPT_documentation.md` for detailed examples and patterns.**

---

## Completion

### 10. Project Completion Check

**If ALL tasks in .ralph/IMPLEMENTATION_PLAN.md are complete:**
1. Verify all `specs/` requirements are satisfied
2. Ensure all tests are passing
3. Confirm documentation is complete
4. **EMPTY `.ralph/IMPLEMENTATION_PLAN.md` completely** - remove all remaining content to leave the file empty
5. Create `.ralph/PROJECT_COMPLETE` file with completion summary
6. Commit with message: "ralph: mark project complete"
7. Push changes
8. The presence of this file will stop the Ralph loop

**CRITICAL:** When completing the last task, you MUST:
- Empty `.ralph/IMPLEMENTATION_PLAN.md` completely (clear all notes, sections, and content)
- Create `.ralph/PROJECT_COMPLETE` file
- Both must happen in the same commit

**Format for `.ralph/PROJECT_COMPLETE`:**
```
Completed: YYYY-MM-DD HH:MM:SS
Commit: <hash>

Summary:
All specifications implemented and tested.
[Add any relevant completion notes]
```

### 11. Git Commit and Push

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

### 12. Exit

**CRITICAL:** Complete ONE task per iteration and EXIT
- Do **not** attempt multiple tasks in a single iteration
- Exit after: implementing + testing + updating docs + committing + pushing
- The loop will restart you with fresh context for the next task

---

## Error Handling

**Recoverable Errors** (document in .ralph/IMPLEMENTATION_PLAN.md):
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

- **Parallel subagents:** For reading and searching files (scale as needed for efficiency)
- **Single subagent:** For builds and tests (avoid parallel execution conflicts)
- **Subagents:** For complex reasoning tasks (debugging, architectural decisions, spec updates)
- **Background subagents:** Update `.ralph/IMPLEMENTATION_PLAN.md` with a subagent to keep it current

---

## Key Principles

1. **Single sources of truth** - No migrations, no adapters
2. **Complete implementations** - No placeholders or stubs
3. **Search before building** - Don't duplicate existing functionality
4. **One task per iteration** - Complete it fully, then exit
5. **Keep plans current** - Future work depends on accurate documentation
6. **Fix what you find** - Don't ignore unrelated test failures
7. **Fresh context** - All state is in files, not your memory
