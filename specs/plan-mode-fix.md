---
status: implemented
created: 2026-02-05
updated: 2026-02-05
tags: [plan-mode, loop.sh, cline, interactive, git]
dependencies: []
supersedes: 
---

# Plan Mode Interactive Session Fix

## Overview

The current Plan Mode implementation in `.ralph/loop.sh` has a critical bug that prevents interactive sessions from working correctly. The script pipes the prompt content to cline's stdin, causing cline to read the instructions and exit immediately instead of entering interactive mode. This specification defines the fix to enable proper interactive planning sessions.

## Problem Statement

### Current Behavior

When running `./ralph plan`, the loop.sh script executes:
```bash
cat "$PROMPT_FILE" | $AGENT_COMMAND $AGENT_FLAGS
```

This causes cline to:
1. Read PROMPT_plan.md from stdin
2. Process the instructions
3. Exit immediately without user interaction

**Result:** User never gets to interact with the agent to create specifications.

### Root Causes

1. **Wrong invocation method** - Piping to stdin instead of passing as argument
2. **Wrong flags** - Using `--yolo` (auto-approve) and `--json` (structured output) which are for autonomous build mode, not interactive planning
3. **No spec name hint integration** - Even when provided, it's not passed to the agent

## Requirements

### Functional Requirements

1. **Interactive Mode Launch**
   - Cline must enter interactive mode, not read-and-exit mode
   - User must be able to have a back-and-forth conversation with the agent
   - Session continues until user ends it (Ctrl-D or agent completes)

2. **Prompt Delivery**
   - Full PROMPT_plan.md content must be provided to the agent
   - Content must be passed as command argument, not via stdin
   - Prompt content must be properly escaped for shell

3. **Spec Name Hint**
   - If user provides spec name hint (`./ralph plan auth`), it should be included
   - Hint should be appended to prompt with clear formatting
   - Hint should guide agent's initial question/approach
   - If no hint provided, agent asks what user wants to specify

4. **Readable Output**
   - No JSON formatting in plan mode (it's for logging/parsing, not human interaction)
   - Clean, styled terminal output for conversation
   - User can read and respond to agent naturally

5. **Git Integration**
   - After session ends, loop.sh automatically commits any changes to specs/
   - Commit message format: `ralph plan: Add <spec-name> specification` or `ralph plan: Update specifications`
   - Only commit if changes detected in specs/ directory
   - Push changes to remote after committing

6. **No Logging**
   - Plan mode sessions are interactive and ephemeral
   - No log files created in `.ralph/logs/`
   - No metrics parsing needed
   - The spec file itself is the durable artifact

### Non-Functional Requirements

1. **Simplicity** - Plan mode should be simpler than build mode (no timeout, no health checks, no validation hooks)
2. **User Control** - User controls when session ends
3. **Reliability** - Git commit should always happen if changes were made
4. **Consistency** - Git commit format matches Ralph conventions

## Technical Specification

### Correct Cline Invocation

Replace the current piped invocation with:

```bash
# Read prompt file content
PROMPT_CONTENT="$(cat "$PROMPT_FILE")"

# If spec name hint provided, append it to the prompt
if [ -n "$SPEC_NAME" ]; then
    PROMPT_CONTENT="${PROMPT_CONTENT}

---

## Initial Task

The user wants to create a specification for: **${SPEC_NAME}**

Please engage with the user to understand their requirements and help them create this specification."
fi

# Invoke cline in interactive plan mode
cline --plan "$PROMPT_CONTENT"
```

### Flag Changes

**Remove:**
- `--yolo` - This auto-approves actions, defeating the purpose of interactive planning
- `--json` - This outputs structured JSON for parsing, not human-readable conversation

**Use:**
- `--plan` (or `-p`) - This activates cline's plan mode for interactive specification writing

### Git Commit Logic

After cline exits in plan mode:

```bash
if [ "$MODE" = "plan" ]; then
    info "Plan mode session complete"
    
    # Check if any changes were made to specs/
    if git diff --quiet specs/ 2>/dev/null && \
       git diff --cached --quiet specs/ 2>/dev/null; then
        debug "No changes detected in specs/"
    else
        # Stage changes in specs/
        git add specs/
        
        # Generate appropriate commit message
        if [ -n "$SPEC_NAME" ]; then
            COMMIT_MSG="ralph plan: Add ${SPEC_NAME} specification"
        else
            COMMIT_MSG="ralph plan: Update specifications"
        fi
        
        git commit -m "$COMMIT_MSG"
        info "✓ Changes committed"
        
        # Push to remote
        CURRENT_BRANCH=$(git branch --show-current)
        if git push origin "$CURRENT_BRANCH" 2>&1; then
            info "✓ Push successful"
        else
            warn "Push failed - you may need to push manually"
        fi
    fi
    
    # Exit (plan mode is single session, not a loop)
    exit 0
fi
```

### Simplified Plan Mode Logic

Plan mode should bypass build mode features:

**Skip in Plan Mode:**
- Health checks (user is present, can handle issues)
- Iteration timeout
- Validation hooks
- Metrics parsing
- Log file creation
- PROJECT_COMPLETE detection
- Max iterations checking
- Retry logic (just simple push, warn on failure)

**Keep:**
- Basic startup display
- Git commit after session
- Single execution (not a loop)

## Examples

### Example 1: Plan Mode Without Hint

**User runs:**
```bash
./ralph plan
```

**Behavior:**
1. Script reads PROMPT_plan.md
2. Launches: `cline --plan "<full prompt content>"`
3. Agent says: "What feature or component would you like to specify?"
4. User and agent collaborate interactively
5. Agent saves spec to `specs/feature-name.md`
6. User ends session (Ctrl-D)
7. Script commits: `ralph plan: Update specifications`

### Example 2: Plan Mode With Hint

**User runs:**
```bash
./ralph plan authentication
```

**Behavior:**
1. Script reads PROMPT_plan.md
2. Appends: "The user wants to create a specification for: **authentication**"
3. Launches: `cline --plan "<combined prompt>"`
4. Agent says: "I see you want to specify authentication. Let's discuss the requirements..."
5. Collaboration proceeds with context
6. Agent saves spec to `specs/authentication.md`
7. User ends session
8. Script commits: `ralph plan: Add authentication specification`

### Example 3: No Changes Made

**User runs:**
```bash
./ralph plan
```

**Behavior:**
1. Session starts
2. User and agent discuss but decide not to create anything
3. User ends session
4. Script detects no changes in specs/
5. No git commit made
6. Script displays: "No changes detected in specs/"

## Edge Cases and Special Scenarios

### Shell Escaping

**Issue:** PROMPT_plan.md contains backticks, quotes, and special characters

**Solution:** Use proper quoting when reading file:
```bash
PROMPT_CONTENT="$(cat "$PROMPT_FILE")"
```

The double quotes preserve whitespace and most special characters. Passing to cline as `"$PROMPT_CONTENT"` ensures proper shell escaping.

### Multi-line Prompt Content

**Issue:** PROMPT_plan.md is ~300 lines with complex formatting

**Solution:** The command substitution `$(cat ...)` preserves all newlines and formatting. Passing as argument to cline works correctly for multi-line strings.

### User Interrupts Session (Ctrl-C)

**Issue:** What happens if user presses Ctrl-C during planning?

**Solution:** 
- Cline exits with non-zero code
- Script detects and runs git commit logic anyway
- Any partial work in specs/ is committed
- User can continue or rollback with `git reset --hard HEAD~1`

### Git Push Failures

**Issue:** Remote push fails (network, auth, conflicts)

**Solution:**
- Display warning, don't fail fatally
- Changes are committed locally
- User can push manually later
- Less critical than build mode (user is present to handle it)

### Empty Spec Name Hint

**Issue:** User runs `./ralph plan ""` with empty string

**Solution:**
- Script checks `if [ -n "$SPEC_NAME" ]` which is false for empty strings
- Falls back to no-hint behavior
- Agent asks what to specify

## Success Criteria

- [ ] Running `./ralph plan` launches interactive cline session
- [ ] User can have back-and-forth conversation with agent
- [ ] Agent follows PROMPT_plan.md instructions
- [ ] Agent creates spec file in specs/ directory
- [ ] Spec name hint (if provided) is incorporated into initial prompt
- [ ] Output is human-readable (no JSON formatting)
- [ ] No log files created in `.ralph/logs/`
- [ ] Changes to specs/ are automatically committed after session
- [ ] Commit message includes spec name if hint was provided
- [ ] Changes are pushed to remote (or warning shown if push fails)
- [ ] Session exits cleanly after user ends interaction
- [ ] Multiple plan sessions can be run sequentially without issues

## Out of Scope

- **PROMPT_plan.md content changes** - This spec focuses on invocation, not prompt content
- **Build mode changes** - Only plan mode is being fixed
- **New cline features** - Using existing `--plan` flag, not requesting new functionality
- **Advanced git workflows** - Simple add/commit/push, no branch management or conflict resolution
- **Session recording** - Explicitly out of scope (no logging)
- **Spec validation** - Agent validates specs per PROMPT_plan.md, script doesn't validate content

## Open Questions

- [x] Should we log plan mode sessions? **Decision: No, keep it simple and interactive**
- [x] Should agent or script commit changes? **Decision: Script commits for consistency**
- [ ] Should script update specs/README.md automatically? **Suggestion: Let agent do it per PROMPT_plan.md instructions**
- [ ] Should script validate that a spec file was created? **Suggestion: No, trust the agent and user**

## Dependencies

None - this is a standalone fix to existing functionality.

## References

- cline CLI documentation: `cline --help`
- Ralph system spec: `specs/ralph-system-initial-implementation.md`
- Current plan prompt: `.ralph/prompts/PROMPT_plan.md`
- Current implementation: `.ralph/loop.sh`
