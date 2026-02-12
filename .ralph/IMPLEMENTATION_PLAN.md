# Implementation Plan

## Overview

This plan implements the remaining specification: **ralph-portable-integration.md**. This is a major architectural change to transform Ralph from a standalone project into a portable development tool that can be easily integrated into any existing or new project.

All other specifications have been fully implemented and tested.

## Remaining Tasks

### High Priority - Portability Refactoring

1. **Update all path references**
   - Update `.ralph/ralph` to reference `.ralph/loop.sh`
   - Update `.ralph/loop.sh` paths for IMPLEMENTATION_PLAN.md, PROGRESS.md, prompts
   - Update `.ralph/prompts/PROMPT_build.md` to use `.ralph/` prefixed paths
   - Remove project structure assumptions from prompts
   - Spec: specs/ralph-portable-integration.md - "Update All Path References"

3. **Create .ralph/.gitignore**
   - Ignore `logs/` directory
   - Ignore `*.log` and `*.log.metrics` files
   - Spec: specs/ralph-portable-integration.md - "Create .ralph/.gitignore"

4. **Create placeholder state files**
   - Create `.ralph/IMPLEMENTATION_PLAN.md` with template
   - Create `.ralph/PROGRESS.md` with template
   - Spec: specs/ralph-portable-integration.md - "Placeholder State Files"

6. **Create .ralph/AGENTS.md.template**
   - Include required ## Specifications section
   - Include example project sections (customizable)
   - Add clear comments distinguishing Ralph vs project sections
   - Spec: specs/ralph-portable-integration.md - "AGENTS.md Template Management"

7. **Create install.sh script**
   - Check prerequisites (git repo, no existing .ralph/)
   - Clone Ralph repo to temp directory
   - Copy .ralph/ to current project
   - Remove .git from copied .ralph/
   - Add version identifier
   - Clean up temp directory
   - Spec: specs/ralph-portable-integration.md - "Installation Script"

8. **Implement ralph init command**
   - Add `init` subcommand to `.ralph/ralph`
   - Create `specs/` directory if missing
   - Create `specs/README.md` with starter template
   - Handle AGENTS.md intelligently (create from template or show message)
   - Output helpful instructions
   - Spec: specs/ralph-portable-integration.md - "Ralph Init Command"

9. **Update documentation**
   - Move all docs to `.ralph/docs/`
   - Create `.ralph/docs/README.md` (main documentation)
   - Create `.ralph/docs/installation.md` (with AGENTS.md integration guide)
   - Create `.ralph/docs/quickstart.md` (mention AGENTS.md setup)
   - Create `.ralph/docs/writing-specs.md`
   - Create `.ralph/docs/troubleshooting.md`
   - Remove project-specific examples and assumptions
   - Spec: specs/ralph-portable-integration.md - "Documentation Updates"

10. **Update specs/ralph-overview.md**
    - Update all file paths to use `.ralph/` prefix
    - Remove project-specific assumptions
    - Update examples to show `.ralph/` paths
    - Add AGENTS.md requirement explanation
    - Spec: specs/ralph-portable-integration.md - "Update ralph-overview.md"

11. **Test installation in fresh project**
    - Create test project
    - Run install.sh
    - Run ralph init
    - Create test spec
    - Run build loop for 1 iteration
    - Verify all paths work correctly
    - Spec: specs/ralph-portable-integration.md - "Testing Approach"

## Notes

### Current State
- All core Ralph functionality is implemented and working
- Docker environment is configured
- Calculator test spec fully implemented
- PROJECT_COMPLETE auto-reset working
- Metrics tracking implemented
- Signal handling (Ctrl-C) implemented

### Implementation Strategy
- This is a major refactoring that will break the current structure
- Must be done carefully with thorough testing
- Each task should be completed and tested before moving to next
- Keep git history clean with descriptive commits
- Test at each major milestone

### Dependencies
- Tasks 1-6 are foundational file reorganization
- Task 7 (install.sh) depends on tasks 1-6 being complete
- Task 8 (ralph init) depends on tasks 1-6 being complete
- Task 9 (documentation) can be done in parallel with tasks 7-8
- Task 10 (update ralph-overview.md) should be done after tasks 1-9
- Task 11 (testing) must be done last to validate everything

### Success Criteria
- Ralph can be installed into any project via curl/wget
- All Ralph files (except specs/) are under .ralph/
- No assumptions about project structure
- Installation is simple and well-documented
- Build loop works with new paths
- AGENTS.md integration is clear and flexible

### Breaking Changes
- This refactoring will break the current Ralph project structure
- After implementation, the current project will need to be migrated
- Consider creating a migration guide for existing Ralph users
- Git history will show the transition clearly

### Testing Checklist
- [ ] File structure reorganized correctly
- [ ] All path references updated
- [ ] install.sh works via curl
- [ ] ralph init creates proper structure
- [ ] AGENTS.md template works correctly
- [ ] Documentation is complete and accurate
- [ ] Build loop works in fresh project
- [ ] No project-specific assumptions remain
