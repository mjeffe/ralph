# Branch Safety Check

## Overview

Add a pre-flight safety check to Ralph's entry point that warns users when running on `main` or `master` branches and prompts them to either abort, create a new branch, or explicitly confirm they want to continue on the protected branch.

## Problem Statement

Ralph's autonomous loop produces multiple automated commits during development. Running Ralph directly on `main` or `master` branches risks polluting the main branch history with incremental development commits. Users should make an explicit, intentional choice before starting the loop on protected branches.

## Requirements

### Detection and Trigger

1. **Check location:** Branch check occurs in `.ralph/ralph` wrapper script after prerequisite checks but before delegating to `loop.sh`
2. **Branch detection:** Use `git branch --show-current` to get current branch name
3. **Protected branches:** Check if branch name equals `main` or `master` (exact match, case-sensitive)
4. **Trigger:** If on protected branch, show warning and prompt for action

### Interactive Mode Behavior

When running in an interactive terminal (stdin is a tty):

**Warning Display:**
```
⚠️  WARNING: You are on branch 'main'

Running Ralph on main/master can create many development commits.
It's recommended to work on a feature branch instead.

Options:
  1. Abort (recommended)
  2. Create a new branch
  3. Continue on main (requires confirmation)

Choose an option [1]:
```

**Option 1 - Abort (Default):**
- Pressing Enter or entering `1` exits cleanly with exit code 0
- Display message: `Aborted. Create a feature branch and try again.`
- No changes made, no commits created

**Option 2 - Create Branch:**
- Prompt: `Enter new branch name: `
- Read branch name from user input
- Validate: non-empty, valid git branch name characters
- Create branch: `git checkout -b <branch-name>`
- If creation succeeds: display confirmation and proceed to loop
- If creation fails: display error and abort with exit code 1

**Option 3 - Continue on Main:**
- Prompt: `Type 'yes' to confirm you want to continue on main: `
- Read confirmation from user input
- If user types exactly `yes`: proceed to loop
- Any other input: abort with exit code 0

### Non-Interactive Mode Behavior

When running in a non-interactive context (stdin is not a tty, e.g., cron, CI/CD):

1. Detect branch is `main` or `master`
2. Print warning message to stderr:
   ```
   ERROR: Running on protected branch 'main'
   Ralph cannot run on main/master in non-interactive mode.
   Switch to a feature branch first.
   ```
3. Exit immediately with exit code 1
4. No prompts, no user interaction

### Implementation Details

**TTY Detection:**
```bash
if [ -t 0 ]; then
    # Interactive mode - show prompts
else
    # Non-interactive mode - abort immediately
fi
```

**Branch Name Validation:**
- Not empty
- Git will handle invalid characters when attempting creation
- Capture git error output if branch creation fails

**Function Signature (bash):**
```bash
check_protected_branch() {
    local current_branch="$(git branch --show-current)"
    
    if [ "$current_branch" = "main" ] || [ "$current_branch" = "master" ]; then
        handle_protected_branch "$current_branch"
    fi
}
```

### Error Messages

**Branch creation failed:**
```
Error: Failed to create branch '<branch-name>'
Git error: <git error output>
```

**Invalid option selected:**
```
Invalid option. Please choose 1, 2, or 3.
```

### Logging

- Display chosen action before proceeding
- Examples:
  - `✓ Continuing on branch 'feature-123'` (if new branch created)
  - `✓ Continuing on 'main' (user confirmed)`
  - `Aborted`

## Use Cases

### Use Case 1: Developer on Main (Abort)

```
$ ./ralph
⚠️  WARNING: You are on branch 'main'
...
Choose an option [1]: 
Aborted. Create a feature branch and try again.

$ git checkout -b feature/my-feature
$ ./ralph
# Loop starts successfully
```

### Use Case 2: Developer Creates Branch

```
$ ./ralph
⚠️  WARNING: You are on branch 'main'
...
Choose an option [1]: 2
Enter new branch name: feature/auth-fix
✓ Created and switched to branch 'feature/auth-fix'
✓ Continuing on branch 'feature/auth-fix'

[Loop starts]
```

### Use Case 3: Developer Explicitly Continues on Main

```
$ ./ralph
⚠️  WARNING: You are on branch 'main'
...
Choose an option [1]: 3
Type 'yes' to confirm you want to continue on main: yes
✓ Continuing on 'main' (user confirmed)

[Loop starts]
```

### Use Case 4: Non-Interactive CI/CD

```
$ echo "" | ./ralph
ERROR: Running on protected branch 'main'
Ralph cannot run on main/master in non-interactive mode.
Switch to a feature branch first.
$ echo $?
1
```

## Success Criteria

- [ ] Running `./ralph` on `main` displays warning with options
- [ ] Running `./ralph` on `master` displays warning with options
- [ ] Pressing Enter or selecting option 1 aborts cleanly (exit 0)
- [ ] Selecting option 2 prompts for branch name and creates branch
- [ ] After successful branch creation, loop proceeds on new branch
- [ ] Selecting option 3 prompts for "yes" confirmation
- [ ] Typing "yes" exactly allows loop to proceed on main/master
- [ ] Typing anything other than "yes" aborts
- [ ] Non-interactive mode (no tty) aborts immediately with error (exit 1)
- [ ] Running on any other branch (not main/master) skips check entirely
- [ ] Empty branch name input displays error and aborts
- [ ] Failed branch creation displays git error and aborts
- [ ] All user interactions logged to stdout for visibility

## Out of Scope

- Auto-generating branch names with timestamps or patterns
- Persisting user preference to always skip check
- Configurable list of protected branch names
- Branch naming convention enforcement
- Remote branch protection checks
- Integration with git hooks
- Customizable warning messages via configuration

## Dependencies

None - this is a new safety feature added to the existing `.ralph/ralph` entry point.

## Notes

- This check happens once per Ralph invocation, not on every iteration
- The check occurs after git repository validation but before any loop operations
- User can always bypass by checking out a branch manually before running Ralph
- Exit code 0 for user-initiated abort is intentional (not an error condition)
- Exit code 1 for non-interactive abort signals automation failure
