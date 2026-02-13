# Implementation Plan

## Remaining Tasks

1. **Implement branch safety check in .ralph/ralph**
   - Add `check_protected_branch()` function to detect main/master branches
   - Add `handle_protected_branch()` function for interactive prompts
   - Implement TTY detection for interactive vs non-interactive mode
   - Add branch creation logic with validation
   - Add confirmation logic for continuing on protected branch
   - Insert check after prerequisite checks, before delegating to loop.sh
   - Test all three options: abort, create branch, continue
   - Test non-interactive mode behavior

## Notes

- Branch check should occur in `.ralph/ralph` wrapper script
- Check happens after `check_prerequisites()` but before `exec .ralph/loop.sh`
- Use `git branch --show-current` to get current branch name
- Protected branches: `main` and `master` (exact match, case-sensitive)
- Interactive mode: show menu with 3 options (abort, create branch, continue)
- Non-interactive mode: exit immediately with error code 1
- Default option is abort (option 1)
- Branch creation should validate non-empty input
- Continuation requires typing exactly "yes"
- All user interactions should be logged to stdout
- Exit code 0 for user-initiated abort (not an error)
- Exit code 1 for non-interactive abort (automation failure)
