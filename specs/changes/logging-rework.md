# Logging System Rework

## Overview

Rework Ralph's logging system to produce a single log file per invocation (containing all iterations), embed metrics directly in the log, eliminate PROGRESS.md entirely, and include task/spec references in iteration headers.

## Problem Statement

The current logging system has several issues:

1. **One log per iteration** - Running `ralph 10` creates 10 separate log files, making it hard to view the complete run
2. **Separate metrics files** - `.metrics` sidecar files add clutter and duplicate information
3. **PROGRESS.md redundancy** - This file duplicates information already available in git commit history
4. **Missing context in logs** - Iteration headers don't show which task/spec is being worked on

## Requirements

### 1. Single Log Per Invocation

**Current behavior:**
- `ralph 10` creates logs: `2026-02-17_001.log`, `2026-02-17_002.log`, ..., `2026-02-17_010.log`

**New behavior:**
- `ralph 10` creates one log: `2026-02-17_001.log` containing all 10 iterations appended sequentially
- Each iteration's output is appended to the same log file
- Log file is opened once at start of run, written to for each iteration, closed at end

**Implementation:**
- Create log file in `.ralph/loop.sh` before entering the main loop
- Pass log file path to each iteration
- Append to same file for each iteration
- Maintain daily numbering: if `_001.log` exists for today, next run uses `_002.log`

### 2. Embed Metrics in Main Log

**Current behavior:**
- Metrics written to `2026-02-17_001.log.metrics` sidecar file
- Metrics also appended to main log file

**New behavior:**
- No `.metrics` sidecar files created
- Metrics embedded directly in main log after each iteration's output
- Metrics section clearly marked with headers

**Format:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Iteration 3 Metrics
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
API Requests: 15
Total Messages: 42
Model: cline/anthropic/claude-sonnet-4.5
Duration: 3m 45s
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Implementation:**
- Remove creation of `.metrics` file in `parse_metrics()`
- Keep metrics parsing logic
- Format metrics as shown above
- Append directly to main log file

### 3. Remove PROGRESS.md

**Files to remove from:**
- `.ralph/prompts/PROMPT_build.md` - Remove all references to reading/updating PROGRESS.md
- `.ralph/prompts/PROMPT_documentation.md` - Remove PROGRESS.md section entirely
- `.ralph/prompts/PROMPT_implementation_plan.md` - Remove any PROGRESS.md references
- `specs/ralph-overview.md` - Update to reflect PROGRESS.md removal
- Any other documentation referencing PROGRESS.md

**Context Awareness changes:**
Update PROMPT_build.md from:
```
All state persists in: `specs/`, `.ralph/IMPLEMENTATION_PLAN.md`, `.ralph/PROGRESS.md`, and git history
```

To:
```
All state persists in: `specs/`, `.ralph/IMPLEMENTATION_PLAN.md`, and git history
```

**Documentation workflow changes:**
- Remove step 8 "Update .ralph/PROGRESS.md" from PROMPT_build.md
- Update PROMPT_documentation.md to remove PROGRESS.md section
- Git commit messages become the historical record (already capturing what was done)

**IMPORTANT:** Do NOT delete the existing `.ralph/PROGRESS.md` file - it contains valuable history. Leave it in place but stop updating it.

### 4. Iteration Headers with Task/Spec Context

**Current header:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Iteration: 3
Branch: main
Started: 2026-02-17 08:32:00
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**New header:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Iteration: 3
Task: Add output filter script
Spec: agent-output-filtering.md
Branch: main
Started: 2026-02-17 08:32:00
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Task/Spec extraction:**
1. Read `.ralph/IMPLEMENTATION_PLAN.md` at start of each iteration
2. Find first remaining task (first numbered item under "## Remaining Tasks")
3. Parse task description for the "Task:" field
4. Parse "Spec: specs/xxx.md" line (if present) for the "Spec:" field
5. If no spec line, show "Spec: (not specified)"

**Task format examples:**
```markdown
1. Add output filter script
   - Create .ralph/lib/filter-output.sh
   - Spec: specs/agent-output-filtering.md - "Filter Script"
```
Extracts to:
- Task: Add output filter script
- Spec: agent-output-filtering.md

**Implementation:**
- Add function `extract_current_task()` in `.ralph/loop.sh`
- Call before each iteration's header
- Parse markdown numbered list format
- Handle missing spec reference gracefully

### 5. Update PROMPT_implementation_plan.md

Ensure task format includes spec references:

**Add to format template:**
```markdown
1. [Task description]
   - [Optional details]
   - Spec: specs/file-name.md - "Section Name"
```

**Add to "Common Patterns" section:**
```markdown
### Task with Spec Reference

Always include spec reference when task implements a specification:

✅ **Good:**
1. Implement user registration endpoint
   - POST /api/users with validation
   - Spec: specs/user-management.md - "Registration"

❌ **Missing spec reference:**
1. Implement user registration endpoint
   - POST /api/users with validation
```

## Implementation Details

### Files to Modify

1. **`.ralph/loop.sh`**
   - Create log file once before main loop (not per iteration)
   - Add `extract_current_task()` function
   - Update iteration header to include task/spec
   - Remove `.metrics` file creation in `parse_metrics()`
   - Embed metrics in main log with clear formatting

2. **`.ralph/prompts/PROMPT_build.md`**
   - Remove PROGRESS.md from "Context Awareness"
   - Remove step 8 "Update .ralph/PROGRESS.md"
   - Remove PROGRESS.md from "Read Current State" section
   - Update documentation workflow accordingly

3. **`.ralph/prompts/PROMPT_documentation.md`**
   - Remove "2. Update PROGRESS.md" section entirely
   - Update numbering for remaining sections
   - Remove PROGRESS.md from examples
   - Update validation checklist

4. **`.ralph/prompts/PROMPT_implementation_plan.md`**
   - Add spec reference to format template
   - Add examples showing spec references
   - Add to "Common Patterns" section

5. **`specs/ralph-overview.md`**
   - Remove `.ralph/PROGRESS.md` from key files section
   - Update documentation workflow descriptions
   - Update examples showing file structure

### Log File Behavior

**Run 1:** `ralph 5`
- Creates: `.ralph/logs/2026-02-17_001.log`
- Contains: 5 iterations appended

**Run 2 (same day):** `ralph 3`  
- Creates: `.ralph/logs/2026-02-17_002.log`
- Contains: 3 iterations appended

**Run 3 (next day):** `ralph 10`
- Creates: `.ralph/logs/2026-02-18_001.log`
- Contains: 10 iterations appended

### Task Extraction Algorithm

```bash
extract_current_task() {
    local plan_file=".ralph/IMPLEMENTATION_PLAN.md"
    
    # Find first numbered task under "## Remaining Tasks"
    local task_line=$(sed -n '/## Remaining Tasks/,/^## /p' "$plan_file" | grep -m 1 '^[0-9]\+\.')
    
    # Extract task description (text after number and period)
    local task_desc=$(echo "$task_line" | sed 's/^[0-9]\+\. *//')
    
    # Look for "Spec:" line following this task
    local spec_line=$(sed -n '/## Remaining Tasks/,/^## /p' "$plan_file" | grep -A 5 "^[0-9]\+\." | grep -m 1 'Spec:')
    local spec_file=$(echo "$spec_line" | sed 's/.*specs\/\([^ ]*\.md\).*/\1/')
    
    # Output
    echo "TASK=${task_desc}"
    [ -n "$spec_file" ] && echo "SPEC=${spec_file}" || echo "SPEC=(not specified)"
}
```

### Metrics Format

**Per iteration, append to main log:**
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Iteration 3 Metrics
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
API Requests: 15
Total Messages: 42
Model: cline/anthropic/claude-sonnet-4.5
Duration: 3m 45s
Commit: abc1234
Exit Code: 0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

No separate `.metrics` file is created.

## Success Criteria

- [ ] Single log file created per invocation containing all iterations
- [ ] Log file naming maintains daily sequence (001, 002, etc.)
- [ ] No `.metrics` sidecar files created
- [ ] Metrics embedded in main log with clear headers per iteration
- [ ] Iteration headers include Task and Spec fields
- [ ] Task/spec extracted from IMPLEMENTATION_PLAN.md correctly
- [ ] PROMPT_build.md updated to remove PROGRESS.md references
- [ ] PROMPT_documentation.md updated to remove PROGRESS.md section
- [ ] PROMPT_implementation_plan.md updated with spec reference guidance
- [ ] specs/ralph-overview.md updated to remove PROGRESS.md
- [ ] Existing `.ralph/PROGRESS.md` file preserved (not deleted)
- [ ] Ralph stops writing to PROGRESS.md
- [ ] All tests pass (if applicable)
- [ ] Documentation updated

## Out of Scope

- Changing agent output filtering behavior
- Creating a log viewer or dashboard
- Modifying git commit message format
- Changing validation hook behavior
- Archiving or rotating old logs
- Deleting existing PROGRESS.md file (preserve history)

## Migration Notes

**For existing projects:**
- Existing `.ralph/PROGRESS.md` is preserved but no longer updated
- Historical PROGRESS.md entries remain valuable reference
- Git history provides complete record of completed work
- Existing log files remain unchanged
- New logging behavior applies to all new runs

**Backward compatibility:**
- No breaking changes to external interfaces
- Same command-line usage
- Same environment variables
- Log format is additive (more context, not less)
