# Implementation Plan

## Remaining Tasks

### High Priority

1. **File structure reorganization for portability**
   - Spec: specs/ralph-portable-integration.md
   - Move ralph script: ralph → .ralph/ralph
   - Move IMPLEMENTATION_PLAN.md → .ralph/IMPLEMENTATION_PLAN.md
   - Move PROGRESS.md → .ralph/PROGRESS.md
   - Move docs/ → .ralph/docs/
   - Remove src/ directory (obsolete example code)
   - Create .ralph/.gitignore for logs/
   - Dependencies: None
   - Blocks: All other portability tasks

2. **Update all path references after reorganization**
   - Spec: specs/ralph-portable-integration.md
   - Update .ralph/ralph to reference .ralph/loop.sh
   - Update .ralph/loop.sh for new paths (.ralph/IMPLEMENTATION_PLAN.md, .ralph/PROGRESS.md, .ralph/prompts/)
   - Update .ralph/prompts/PROMPT_build.md with new paths
   - Update .ralph/prompts/PROMPT_plan.md with new paths
   - Dependencies: Task 1 (file reorganization)
   - Blocks: System functionality after reorganization

3. **Create placeholder state files**
   - Spec: specs/ralph-portable-integration.md
   - Create .ralph/IMPLEMENTATION_PLAN.md with template
   - Create .ralph/PROGRESS.md with template
   - Dependencies: Task 1 (file reorganization)
   - Blocks: Installation script

4. **Update documentation for portability**
   - Spec: specs/ralph-portable-integration.md
   - Move and update docs to .ralph/docs/
   - Create .ralph/docs/README.md (from root README.md)
   - Create .ralph/docs/installation.md
   - Create .ralph/docs/quickstart.md
   - Create .ralph/docs/writing-specs.md
   - Create .ralph/docs/troubleshooting.md
   - Remove project-specific examples
   - Remove assumptions about project structure
   - Dependencies: Task 1 (file reorganization)
   - Blocks: User onboarding

5. **Update specs/ralph-overview.md for new structure**
   - Spec: specs/ralph-portable-integration.md
   - Update all file paths to reflect .ralph/ structure
   - Remove project-specific assumptions
   - Update examples with .ralph/ paths
   - Dependencies: Task 1 (file reorganization)
   - Blocks: Agent understanding of system

6. **Create installation script**
   - Spec: specs/ralph-portable-integration.md
   - Create install.sh in repository root
   - Check prerequisites (git repo, no existing .ralph/)
   - Clone Ralph to temp, copy .ralph/ to project
   - Create .ralph/.ralph-version with version info
   - Clean up temp directory
   - Output success message and next steps
   - Dependencies: Tasks 1-5 (all reorganization complete)
   - Blocks: Easy Ralph adoption

7. **Implement ralph init command**
   - Spec: specs/ralph-portable-integration.md
   - Add init subcommand to .ralph/ralph script
   - Create specs/ directory if missing
   - Create specs/README.md with starter template
   - Output instructions and next steps
   - Dependencies: Task 2 (path updates)
   - Blocks: First-time user experience

8. **Final testing and validation**
   - Spec: specs/ralph-portable-integration.md
   - Test installation in fresh project
   - Verify all paths work correctly
   - Test build loop with new structure
   - Verify isolation (.ralph/logs/ gitignored)
   - Confirm no impact on project root
   - Dependencies: All previous tasks
   - Blocks: Release

## Notes

### Task Selection Strategy
- Tasks 1-8 must be done sequentially as they build on each other
- This represents a major architectural change for portability
- Consider completing all tasks as a cohesive unit

### Implementation Approach
- Tasks 1-8 represent a major architectural change
- Each task should be committed separately for clear git history
- Test thoroughly after path updates (Task 2) before proceeding

### Spec Status
- test-simple-calculator.md: ✅ Implemented (calculator module complete)
- project-complete-reset.md: ✅ Implemented (loop.sh lines 253-273)
- ralph-portable-integration.md: 🔴 Not implemented
- All other specs: ✅ Implemented or archived

### Testing Requirements
- After Task 2: Run ./ralph --help to verify paths work
- After Task 8: Full integration test in fresh project

### Breaking Changes
- Portability work (Tasks 1-8) introduces breaking changes
- Users will need to adapt to new .ralph/ structure
- Migration notes in specs/ralph-portable-integration.md
