# Implementation Plan

## Remaining Tasks

### High Priority

1. **Implement PROJECT_COMPLETE reset functionality**
   - Spec: specs/project-complete-reset.md
   - Current issue: loop.sh checks for `.ralph/PROJECT_COMPLETE` file, but spec requires checking IMPLEMENTATION_PLAN.md for text marker
   - Fix check_project_complete() function to grep IMPLEMENTATION_PLAN.md for "PROJECT_COMPLETE" text
   - When detected, reset IMPLEMENTATION_PLAN.md to template, commit, push, and exit
   - Location: .ralph/loop.sh around line 253
   - Dependencies: None
   - Blocks: Smooth multi-spec workflow

2. **File structure reorganization for portability**
   - Spec: specs/ralph-portable-integration.md
   - Move ralph script: ralph → .ralph/ralph
   - Move IMPLEMENTATION_PLAN.md → .ralph/IMPLEMENTATION_PLAN.md
   - Move PROGRESS.md → .ralph/PROGRESS.md
   - Move docs/ → .ralph/docs/ (if docs/ exists)
   - Remove src/ directory (obsolete example code)
   - Create .ralph/.gitignore for logs/
   - Dependencies: None
   - Blocks: All other portability tasks

3. **Update all path references after reorganization**
   - Spec: specs/ralph-portable-integration.md
   - Update ralph script to reference .ralph/loop.sh
   - Update .ralph/loop.sh for new paths (.ralph/IMPLEMENTATION_PLAN.md, .ralph/PROGRESS.md, .ralph/prompts/)
   - Update .ralph/prompts/PROMPT_build.md with new paths
   - Dependencies: Task 2 (file reorganization)
   - Blocks: System functionality after reorganization

4. **Create placeholder state files**
   - Spec: specs/ralph-portable-integration.md
   - Create .ralph/IMPLEMENTATION_PLAN.md with template
   - Create .ralph/PROGRESS.md with template
   - Dependencies: Task 2 (file reorganization)
   - Blocks: Installation script

5. **Create AGENTS.md template**
   - Spec: specs/ralph-portable-integration.md
   - Create .ralph/AGENTS.md.template with full structure
   - Include ## Specifications section (required)
   - Include example sections for commit messages and code style
   - Dependencies: None
   - Blocks: ralph init command

6. **Update documentation for portability**
   - Spec: specs/ralph-portable-integration.md
   - Move and update docs to .ralph/docs/ (if docs/ exists)
   - Create .ralph/docs/README.md (from root README.md)
   - Create .ralph/docs/installation.md (must include AGENTS.md integration)
   - Create .ralph/docs/quickstart.md (must mention AGENTS.md setup)
   - Create .ralph/docs/writing-specs.md
   - Create .ralph/docs/troubleshooting.md
   - Remove project-specific examples (calculator, etc.)
   - Remove assumptions about project structure
   - Dependencies: Task 2 (file reorganization)
   - Blocks: User onboarding

7. **Update specs/ralph-overview.md for new structure**
   - Spec: specs/ralph-portable-integration.md
   - Update all file paths to reflect .ralph/ structure
   - Remove project-specific assumptions
   - Update examples with .ralph/ paths
   - Add AGENTS.md requirement (## Specifications section)
   - Explain how AGENTS.md connects agents to specs/
   - Dependencies: Task 2 (file reorganization)
   - Blocks: Agent understanding of system

8. **Create installation script**
   - Spec: specs/ralph-portable-integration.md
   - Create install.sh in repository root
   - Check prerequisites (git repo, no existing .ralph/)
   - Clone Ralph to temp, copy .ralph/ to project
   - Create .ralph/.ralph-version with version info
   - Clean up temp directory
   - Output success message and next steps
   - Dependencies: Tasks 2-7 (all reorganization complete)
   - Blocks: Easy Ralph adoption

9. **Implement ralph init command**
   - Spec: specs/ralph-portable-integration.md
   - Add init subcommand to .ralph/ralph script
   - Create specs/ directory if missing
   - Create specs/README.md with starter template
   - Handle AGENTS.md intelligently (create from template if missing, show message if exists)
   - Output instructions and next steps
   - Dependencies: Tasks 3, 5 (path updates and AGENTS.md template)
   - Blocks: First-time user experience

10. **Final testing and validation**
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
- Tasks 2-10 must be done sequentially as they build on each other
- Consider doing Task 1 first, then the portability work as a cohesive unit

### Implementation Approach
- Task 1 is a focused bug fix in loop.sh
- Tasks 2-10 represent a major architectural change
- Each task should be committed separately for clear git history
- Test thoroughly after path updates (Task 3) before proceeding

### Spec Status
- test-simple-calculator.md: ✅ Implemented (calculator module complete)
- project-complete-reset.md: 🔴 Not implemented (check_project_complete() uses wrong approach)
- ralph-portable-integration.md: 🔴 Not implemented
- All other specs: ✅ Implemented or archived

### Testing Requirements
- After Task 1: Manually add PROJECT_COMPLETE to IMPLEMENTATION_PLAN.md to verify reset behavior
- After Task 3: Run ./ralph --help to verify paths work
- After Task 10: Full integration test in fresh project

### Breaking Changes
- Portability work (Tasks 2-10) introduces breaking changes
- Users will need to adapt to new .ralph/ structure
- Migration notes in specs/ralph-portable-integration.md
