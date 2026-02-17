# Implementation Plan

## Overview

Implementing specs/logging-rework.md - Rework Ralph's logging system to produce single log per invocation, embed metrics in logs, remove PROGRESS.md updates, and add task/spec context to iteration headers.

Search findings:
- Current loop.sh creates one log file per iteration (line 115: `create_log_file()`)
- Metrics written to `.metrics` sidecar files (line 147: `metrics_file="${log_file}.metrics"`)
- No `extract_current_task()` function exists
- PROGRESS.md extensively referenced in PROMPT_build.md, PROMPT_documentation.md, PROMPT_plan.md
- No task/spec extraction in iteration headers
- Existing .ralph/PROGRESS.md file contains valuable history (will be preserved)

## Remaining Tasks

### Medium Priority - Documentation Updates

1. Remove PROGRESS.md references from specs/ralph-overview.md
   - Remove .ralph/PROGRESS.md from key files section
   - Update documentation workflow descriptions
   - Update file structure examples
   - Spec: specs/logging-rework.md - "Remove PROGRESS.md"

4. Update PROMPT_plan.md to remove PROGRESS.md reference
   - Remove PROGRESS.md from context awareness section
   - Spec: specs/logging-rework.md - "Remove PROGRESS.md"

### Testing & Completion

5. Test logging system with multiple iterations
   - Run `ralph 3` and verify single log file created
   - Verify all 3 iterations appended to same file
   - Verify no .metrics sidecar files created
   - Verify metrics embedded in log with clear headers
   - Verify task/spec appear in iteration headers
   - Run second invocation same day, verify _002.log created

6. Update specs/README.md to mark logging-rework.md as Implemented
   - Add completion date
   - Add verification details
   - Spec: specs/logging-rework.md

## Notes

### Implementation Strategy

**Phase 1 (Tasks 1-4):** Core logging and initial documentation
- Tasks 1-3 were already implemented in loop.sh (verified in this iteration)
- Task 4 completed: PROMPT_build.md updated to remove PROGRESS.md references

**Phase 2 (Tasks 1-3 remaining):** Documentation cleanup
- Can be done in any order (independent changes)
- Each task updates one prompt/doc file
- PROGRESS.md file itself is NOT deleted (preserves history)
- Task 1 completed: PROMPT_documentation.md updated to remove PROGRESS.md references

**Phase 3 (Tasks 9-10):** Validation and completion
- Task 9 validates all changes work together
- Task 10 marks spec as complete

### Dependencies

- Tasks 1-3 (documentation) are independent of each other
- Task 4 depends on Tasks 1-3 being complete (tests core functionality)
- Task 5 depends on Task 4 (can't mark complete until tested)

### Success Criteria

- Single log file created per ralph invocation containing all iterations
- Log file naming maintains daily sequence (001, 002, etc.)
- No .metrics sidecar files created
- Metrics embedded in main log with clear headers per iteration
- Iteration headers include Task and Spec fields
- Task/spec extracted correctly from IMPLEMENTATION_PLAN.md
- All prompt files updated to remove PROGRESS.md references
- specs/ralph-overview.md updated to remove PROGRESS.md
- Existing .ralph/PROGRESS.md file preserved (not deleted)
- Ralph stops writing to PROGRESS.md
- Test run with multiple iterations works correctly
- specs/README.md updated to mark spec as Implemented

### Important Notes

- **DO NOT delete .ralph/PROGRESS.md** - It contains valuable historical information
- Ralph will simply stop updating it going forward
- Git commit history becomes the primary historical record
- Log files provide detailed iteration-by-iteration context
