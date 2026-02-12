# Ralph System - Quick Reference for Agents

## What is Ralph?

Ralph is an iterative development system that solves the LLM context window problem. Instead of trying to hold an entire project in context, Ralph runs agents in a loop where:

- **Each iteration starts with fresh context** - Agent reads current state from files
- **State persists in files** - Critical information survives between iterations
- **One task per iteration** - Agent completes focused work, commits, exits
- **Git tracks everything** - Complete audit trail of all changes

This enables agents to work on projects of arbitrary size by breaking work into discrete chunks.

## The Ralph Loop

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

## The Ralph Loop

Ralph operates in a single mode: **Build Mode** - an autonomous loop that implements features defined in specifications.

- **Purpose:** Implement features defined in specs
- **First iteration:** If IMPLEMENTATION_PLAN.md doesn't exist, create it from specs/, commit, exit
- **Subsequent iterations:** Execute tasks from IMPLEMENTATION_PLAN.md
- **Exit conditions:** PROJECT_COMPLETE marker OR max iterations reached

**Note:** Specifications should be created outside of Ralph using any tool you prefer (manual editing, cline CLI directly, ChatGPT, Claude, etc.).

## Key Files and Their Roles

### `specs/` (Human-authored, read-only for agents)
- Single source of truth for requirements
- One spec file per major feature/component
- Includes use cases, edge cases, acceptance criteria
- **Agent responsibility:** Read and understand, implement to spec
- May update if you find inconsistencies (requires high confidence)

### `IMPLEMENTATION_PLAN.md` (Agent-maintained)
- Prioritized ordered list of remaining tasks
- Simple numbered list (top = highest priority)
- Brief, actionable task descriptions
- **Update every iteration:** Remove completed tasks, add discovered issues
- **When complete:** Create `.ralph/PROJECT_COMPLETE` file to signal completion

Example format:
```markdown
# Implementation Plan

## Remaining Tasks

1. [HIGH PRIORITY] Fix authentication bug in login handler
2. Add user profile API endpoint
3. Implement password reset flow

## Notes

- All tests must pass before marking task complete
- Use existing patterns in src/lib
```

### `PROGRESS.md` (Agent-maintained)
- Historical record of completed tasks
- Reverse chronological (newest first)
- Include commit hash for traceability
- **Update when task complete:** Move task from IMPLEMENTATION_PLAN.md

Example format:
```markdown
# Progress Log

## Completed Tasks

### 2026-02-04
- [x] Refactored authentication module to use JWT
  - Commit: abc1234
  - All auth tests passing
```

### `specs/README.md` (Agent-maintained)
- Index of all specifications with feature-level status
- Update when ALL TASKS for a spec are fully implemented
- Different from PROGRESS.md (feature status vs. task log)

### Git Commits
- One commit per task (per iteration)
- Message format: `ralph: <brief description>`
- Include bullet points with details

## Agent Workflow in Build Mode

### First Iteration (If IMPLEMENTATION_PLAN.md doesn't exist)
1. Read all specs in `specs/` directory
2. Analyze existing codebase structure
3. Generate prioritized task list in IMPLEMENTATION_PLAN.md
4. Commit and exit (next iteration implements tasks)

### Subsequent Iterations
1. **Read context:** Study specs/ and IMPLEMENTATION_PLAN.md
2. **Select task:** Choose highest priority task you can complete
3. **Search first:** Check codebase for existing patterns (don't duplicate)
4. **Implement:** Complete the task fully (no placeholders or TODOs)
5. **Test:** Run tests for affected code, fix failures
6. **Document:** 
   - Move completed task to PROGRESS.md
   - Remove from IMPLEMENTATION_PLAN.md
   - Add any discovered issues to plan
   - Update specs/README.md if entire spec is now complete
7. **Commit:** Descriptive message with changes and test status
8. **Exit:** One task per iteration

### Task Selection Criteria
- Select the **highest priority** task you can complete
- Read IMPLEMENTATION_PLAN.md carefully for dependencies
- Prefer tasks that unblock other work
- If task unclear or too large, break it down first (update plan)
- Document reasoning for task choice in commit message

### When You Get Stuck
If you fail to complete a task after attempting it:
- Add `[BLOCKED]` tag to the task
- Document the blocking issue in Notes section
- Move to next task
- Example:
  ```markdown
  1. [BLOCKED] Fix authentication bug
     - Blocked by: Unclear requirements for password special chars
     - Needs: Clarification from human or update to specs/
  ```

### Important Behaviors
- **Run tests:** Execute and fix test failures before committing
- **No placeholders:** Complete implementation, not stubs or TODOs
- **Update specs/** if you find inconsistencies or ambiguities
- **Document bugs:** Even if unrelated to current task
- **Search codebase:** Use existing patterns and conventions
- **Clean IMPLEMENTATION_PLAN.md:** Periodically move completed items to PROGRESS.md

## Completion Signals

### Task Completion (Implicit)
A task is complete when you exit the iteration. Indicators:
- Changes committed to git
- Documentation updated
- Tests passing (if applicable)
- Agent exits normally

### Project Completion (Explicit)
Project is complete when you create the `.ralph/PROJECT_COMPLETE` file.

Decision criteria:
- IMPLEMENTATION_PLAN.md has no remaining tasks
- All specs/ requirements satisfied
- All tests passing
- Documentation complete

The `.ralph/PROJECT_COMPLETE` file should contain:
- Completion timestamp
- Commit hash
- Brief summary of completed work

## Error Handling

### Recoverable Errors (document and continue)
- Test failures → Fix them
- Build warnings → Address them
- Linting issues → Fix them

**Action:** Document in IMPLEMENTATION_PLAN.md if can't fix immediately

### Fatal Errors (stop the loop)
These will exit the loop, requiring human intervention:
- Git push failures (after retries)
- External validation script failures
- File system errors
- Iteration timeout exceeded

## Working with Specs

### Reading Specs
- Start with `specs/README.md` for overview
- Read relevant spec files for detailed requirements
- Look for frontmatter metadata (status, dependencies, tags)
- Focus on Requirements, Success Criteria, and examples

### Updating Specs
You may update specs if:
- You find genuine inconsistencies
- Requirements are ambiguous and you have high confidence
- You discover missing edge cases during implementation
- **Document changes in commit message**

### When Specs Are Unclear
1. Check if other specs provide context
2. Look at existing codebase for patterns
3. If still unclear: Mark task as [BLOCKED] and document the ambiguity
4. Human intervention required for clarification

---

**Quick start:** Run `./ralph` from project root to begin build mode loop.
