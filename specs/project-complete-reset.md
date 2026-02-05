---
status: active
created: 2026-02-05
tags: [loop.sh, implementation-plan, project-complete, build-mode]
dependencies: []
---

# Fix PROJECT_COMPLETE Loop Exit Bug

## Problem Statement

When a Ralph build cycle completes, the agent adds `PROJECT_COMPLETE` to IMPLEMENTATION_PLAN.md. However, this marker prevents starting new build cycles because:

1. Loop checks for PROJECT_COMPLETE marker at iteration start (line ~253)
2. Immediately exits with "PROJECT COMPLETE! All tasks finished."
3. User must manually edit IMPLEMENTATION_PLAN.md to start new work

This breaks the workflow for multi-spec projects where you want to complete one feature and immediately start another.

## Solution Overview

When PROJECT_COMPLETE is detected, automatically reset IMPLEMENTATION_PLAN.md to a minimal template, commit the change, and exit. The next build cycle will regenerate the plan from current specs/.

## Requirements

### Functional Requirements

1. **Detect PROJECT_COMPLETE:** Use existing `check_project_complete()` function
2. **Reset Implementation Plan:** Truncate IMPLEMENTATION_PLAN.md to minimal template
3. **Commit and Push:** Commit the reset file and push to remote
4. **Exit Cleanly:** Break loop as before, but with clean state for next cycle

### Implementation Location

`.ralph/loop.sh` around line 253, where PROJECT_COMPLETE is currently checked:

```bash
# Check for project completion (build mode only)
if [ "$MODE" = "build" ] && check_project_complete; then
```

### Template Content

Reset IMPLEMENTATION_PLAN.md to:

```markdown
# Implementation Plan

## Remaining Tasks

(This file will be regenerated from specs/ on next build cycle)
```

### Git Integration

- Stage the reset file: `git add IMPLEMENTATION_PLAN.md`
- Commit with clear message: `ralph: reset implementation plan after project completion`
- Push using existing `push_with_retry()` function

## Technical Specification

### Modified Code Block

Replace the current PROJECT_COMPLETE check (around line 253) with:

```bash
# Check for project completion (build mode only)
if [ "$MODE" = "build" ] && check_project_complete; then
    info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    info "PROJECT COMPLETE! All tasks finished."
    info "Resetting implementation plan for next cycle..."
    info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Reset implementation plan to minimal template
    cat > IMPLEMENTATION_PLAN.md << 'EOF'
# Implementation Plan

## Remaining Tasks

(This file will be regenerated from specs/ on next build cycle)
EOF
    
    # Commit the reset
    git add IMPLEMENTATION_PLAN.md
    git commit -m "ralph: reset implementation plan after project completion"
    
    # Push with retry logic
    push_with_retry
    
    break
fi
```

### Behavior Details

1. **Informative output:** Display clear messages about what's happening
2. **Use heredoc:** Clean way to write multi-line template
3. **Use push_with_retry:** Leverages existing retry logic (3 attempts, 5s delays)
4. **Fatal on push failure:** push_with_retry calls `fatal()` after exhausting retries

## Success Criteria

- [x] PROJECT_COMPLETE detection still works correctly
- [x] IMPLEMENTATION_PLAN.md reset to minimal template
- [x] Reset file committed with clear message
- [x] Changes pushed to remote using push_with_retry
- [x] Next `./ralph` execution regenerates plan from specs/
- [x] PROGRESS.md preserved from previous cycle
- [x] No manual cleanup required between build cycles
- [x] Git history shows clear reset commit

## Edge Cases

### What if push fails?

**Behavior:** `push_with_retry()` function attempts 3 times with 5s delays, then calls `fatal()` to exit the loop.

**Result:** Loop exits with error, user must manually push and restart.

**Rationale:** Consistent with existing build mode behavior for push failures.

### What if IMPLEMENTATION_PLAN.md is empty but no PROJECT_COMPLETE marker?

**Behavior:** No change - this fix only triggers when marker is present.

**Next cycle:** First iteration logic handles missing/empty plan by regenerating from specs/.

### What if user manually adds tasks after PROJECT_COMPLETE?

**Behavior:** Marker still present, so tasks are lost when reset occurs.

**Mitigation:** This is expected behavior - PROJECT_COMPLETE means "done, ready for next cycle."

## Testing Approach

### Manual Test Scenario

1. Complete a build cycle (wait for PROJECT_COMPLETE)
2. Verify loop exits with reset messages
3. Check git log shows reset commit
4. Verify remote has the commit
5. Run `./ralph` again
6. Verify IMPLEMENTATION_PLAN.md regenerated from specs/
7. Verify previous PROGRESS.md still intact

### Expected Output

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
PROJECT COMPLETE! All tasks finished.
Resetting implementation plan for next cycle...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✓ Push successful
Loop finished
```

## What This Fixes

- ✅ Can start new build cycles without manual cleanup
- ✅ Clean git history with explicit reset commit  
- ✅ No uncommitted files left in working directory
- ✅ PROGRESS.md preserved across cycles
- ✅ Clear intent in git log and file content

## What's NOT Included

- No archiving of completed plans (PROGRESS.md is sufficient)
- No detection of whether specs/ have changed
- No special handling for empty task lists
- No changes to first iteration logic (already handles missing plans)
- No changes to PROGRESS.md (already working correctly)

## Notes

- IMPLEMENTATION_PLAN.md is tracked in git, so truncation (not deletion) is required
- Template message explains file will be regenerated
- Commit happens as final act of completed build cycle
- Next cycle starts completely fresh with new agent context
