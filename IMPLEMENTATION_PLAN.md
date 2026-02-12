# Implementation Plan

## Remaining Tasks

### High Priority

1. **Implement PROJECT_COMPLETE reset functionality**
   - Spec: specs/project-complete-reset.md
   - Location: .ralph/loop.sh around line 253
   - When PROJECT_COMPLETE detected, reset IMPLEMENTATION_PLAN.md to template
   - Commit reset file and push to remote
   - Exit cleanly for next cycle to regenerate plan
   - Dependencies: None
   - Blocks: Smooth multi-spec workflow

2. **File structure reorganization for portability**
   - Spec: specs/ralph-portable-integration.md
   - Move ralph script: ralph → .ralph/ralph
   - Move IMPLEMENTATION_PLAN.md → .ralph/IMPLEMENTATION_PLAN.md
   - Move PROGRESS.md → .ralph/PROGRESS.md
   - Move docs/ → .ralph/docs/
   - Remove src/ directory (obsolete example code)
   - Create .ralph/.gitignore for logs/
   - Dependencies: None
   - Blocks: All other portability tasks

3. **Update all path references after reorganization**
   - Spec: specs/ralph-portable-integration.md
   - Update .ralph/ralph to reference .ralph/loop.sh
   - Update .ralph/loop.sh for new paths (.ralph/IMPLEMENTATION_PLAN.md, .ralph/PROGRESS.md, .ralph/prompts/)
   - Update .ralph/prompts/PROMPT_build.md with new paths
   - Update .ralph/prompts/PROMPT_plan.md with new paths
   - Dependencies: Task 2 (file reorganization)
   - Blocks: System functionality after reorganization

4. **Create placeholder state files**
   - Spec: specs/ralph-portable-integration.md
   - Create .ralph/IMPLEMENTATION_PLAN.md with template
   - Create .ralph/PROGRESS.md with template
   - Dependencies: Task 2 (file reorganization)
   - Blocks: Installation script

5. **Update documentation for portability**
   - Spec: specs/ralph-portable-integration.md
   - Move and update docs to .ralph/docs/
   - Create .ralph/docs/README.md (from root README.md)
   - Create .ralph/docs/installation.md
   - Create .ralph/docs/quickstart.md
   - Create .ralph/docs/writing-specs.md
   - Create .ralph/docs/troubleshooting.md
   - Remove project-specific examples
   - Remove assumptions about project structure
   - Dependencies: Task 2 (file reorganization)
   - Blocks: User onboarding

6. **Update specs/ralph-overview.md for new structure**
   - Spec: specs/ralph-portable-integration.md
   - Update all file paths to reflect .ralph/ structure
   - Remove project-specific assumptions
   - Update examples with .ralph/ paths
   - Dependencies: Task 2 (file reorganization)
   - Blocks: Agent understanding of system

7. **Create installation script**
   - Spec: specs/ralph-portable-integration.md
   - Create install.sh in repository root
   - Check prerequisites (git repo, no existing .ralph/)
   - Clone Ralph to temp, copy .ralph/ to project
   - Create .ralph/.ralph-version with version info
   - Clean up temp directory
   - Output success message and next steps
   - Dependencies: Tasks 2-6 (all reorganization complete)
   - Blocks: Easy Ralph adoption

8. **Implement ralph init command**
   - Spec: specs/ralph-portable-integration.md
   - Add init subcommand to .ralph/ralph script
   - Create specs/ directory if missing
   - Create specs/README.md with starter template
   - Output instructions and next steps
   - Dependencies: Task 3 (path updates)
   - Blocks: First-time user experience

9. **Final testing and validation**
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
- Task 1 (PROJECT_COMPLETE reset) can be done independently and provides immediate value
- Tasks 2-9 must be done sequentially as they build on each other
- Consider doing Task 1 first, then the portability work as a cohesive unit

### Implementation Approach
- Task 1 is a focused bug fix in loop.sh
- Tasks 2-9 represent a major architectural change
- Each task should be committed separately for clear git history
- Test thoroughly after path updates (Task 3) before proceeding

### Spec Status
- test-simple-calculator.md: ✅ Implemented (calculator module complete)
- project-complete-reset.md: 🔴 Not implemented
- ralph-portable-integration.md: 🔴 Not implemented
- All other specs: ✅ Implemented or archived

### Testing Requirements
- After Task 1: Manually trigger PROJECT_COMPLETE to verify reset behavior
- After Task 3: Run ./ralph --help to verify paths work
- After Task 9: Full integration test in fresh project

### Breaking Changes
- Portability work (Tasks 2-9) introduces breaking changes
- Users will need to adapt to new .ralph/ structure
- Migration notes in specs/ralph-portable-integration.md
