# Implementation Plan

## Overview

Implementing two high-priority specifications for Ralph system improvements:
- ralph-path-resilient.md: Fix symlink path resolution bug in .ralph/ralph entry point
- agent-output-filtering.md: Terminal output filter for human-readable agent activity

Search findings:
- .ralph/ralph does not use BASH_SOURCE or resolve project root
- No .ralph/lib/filter-output.sh exists
- .ralph/loop.sh does not pipe output through filter
- Documentation does not reflect reliable symlink support

## Remaining Tasks

### High Priority - Output Filtering

3. Create output filter script
   - Create .ralph/lib/ directory
   - Create .ralph/lib/filter-output.sh with jq dependency check
   - Implement filtering rules per spec (task/text/tool/api_req_started/etc)
   - Make script executable
   - Handle invalid JSON gracefully
   - Spec: specs/agent-output-filtering.md - "Filter Script Location" and "Implementation Details"

4. Integrate filter into loop.sh
   - Update agent invocation in .ralph/loop.sh to pipe through filter
   - Ensure full logs still preserved via tee
   - Terminal gets filtered output only
   - Spec: specs/agent-output-filtering.md - "Integration Point"

### Medium Priority - Testing & Verification

5. Test path-resilient implementation
   - Test direct execution: .ralph/ralph
   - Test symlink from root: ln -s .ralph/ralph ralph && ./ralph
   - Test from subdirectory invocation
   - Verify all prerequisite checks work after path resolution
   - Spec: specs/ralph-path-resilient.md - "Use Cases" and "Success Criteria"

6. Test output filter with real agent output
   - Run build loop with JSON output enabled
   - Verify terminal shows filtered output
   - Verify log files contain complete raw output
   - Test with missing jq (should fail gracefully)
   - Spec: specs/agent-output-filtering.md - "Testing Approach"

## Notes

### Implementation Strategy
- Tasks 1 and 2 are independent and can be done first
- Tasks 3 and 4 are dependent (filter must exist before integration)
- Testing tasks (5-6) validate implementations

### Dependencies
- Task 2 depends on Task 1 (docs reference the implementation)
- Task 4 depends on Task 3 (integration requires filter script)
- Task 5 depends on Tasks 1-2 (tests path resolution)
- Task 6 depends on Tasks 3-4 (tests output filtering)

### Success Criteria
- Symlinks work from any directory within repository
- Terminal output is human-readable, not verbose JSON
- Full logs preserved for debugging
- All existing functionality remains unchanged
- Documentation accurately reflects new capabilities
