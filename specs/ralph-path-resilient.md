# Ralph Path-Resilient Entry Point

## Overview

Make the `.ralph/ralph` script path-resilient so it can be invoked from any working directory within the project repository via symlink or direct execution. The script should automatically resolve its location, change to the project root, and execute all operations relative to that root.

## Problem Statement

Currently, the documentation recommends creating a symlink (`ln -s .ralph/ralph ralph`) for convenience, but this approach has a critical flaw: when the symlink is invoked, the script operates relative to the current working directory rather than the project root. This causes path resolution failures for references to `specs/`, `.ralph/loop.sh`, and other project resources.

**Example of current failure:**
```bash
# User follows install docs
ln -s .ralph/ralph ralph

# But the symlink doesn't account for relative path differences
./ralph                 # Works (cwd is project root)
cd subdir && ../ralph   # Fails (cwd is subdir, paths break)
```

This makes Ralph less convenient to use and contradicts the documented symlink approach.

## Requirements

### Path Resolution

1. **Resolve script location absolutely**
   - Use `$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)` to get the absolute path of the `.ralph/` directory
   - Do not rely on `$0` or `pwd` which reflect the caller's context
   - Handle symlinks correctly (BASH_SOURCE resolves to the actual script location)

2. **Determine project root**
   - Project root is the parent directory of `.ralph/`
   - Compute as: `PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"`
   - Where `SCRIPT_DIR` is the absolute path to `.ralph/`

3. **Change to project root early**
   - Execute `cd "$PROJECT_ROOT"` immediately after computing the root
   - Do this before any prerequisite checks or path-dependent operations
   - This ensures all subsequent commands (git, file checks, exec) operate from the correct context

### Prerequisite Checks

All existing checks should continue to work, but operate from the resolved project root:

- Git repository check: `git rev-parse --git-dir` (works after cd to root)
- `.ralph/loop.sh` existence: Check after cd to root
- `specs/` directory: Check after cd to root
- `specs/*.md` files: Check after cd to root

### Backward Compatibility

- Preserve all existing CLI behavior:
  - `./ralph` - unlimited iterations
  - `./ralph N` - max N iterations
  - `./ralph init` - initialization
  - `./ralph --help` - usage information
- Error messages remain the same
- Exit codes remain the same

### Use Cases

The updated script must support all these invocation methods:

```bash
# Direct execution from project root
.ralph/ralph

# Symlink from project root
ln -s .ralph/ralph ralph
./ralph

# Symlink from subdirectory
cd some/nested/dir
../../../ralph                    # or however many levels

# Absolute symlink from anywhere
ln -s /absolute/path/to/project/.ralph/ralph ~/bin/myproject-ralph
~/bin/myproject-ralph

# Direct execution while cwd is elsewhere (within repo)
cd src/
../.ralph/ralph
```

All of these should work identically because the script resolves its own location and changes to the project root.

### Implementation Details

**Add path resolution before any other logic:**

```bash
#!/bin/bash
# Ralph Wiggum Loop - Entry Point Script

set -e

# Resolve script location and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Change to project root - all operations happen from here
cd "$PROJECT_ROOT"

# ... rest of existing script logic ...
```

**Key points:**
- Use `BASH_SOURCE[0]` not `$0` - it resolves through symlinks
- Use `cd` in a subshell to avoid affecting the current shell when getting pwd
- Change to `PROJECT_ROOT` immediately, before any checks
- All existing path references (like `.ralph/loop.sh`, `specs/`) now work correctly

### Error Handling

If the script location cannot be determined or the project structure is invalid:

```bash
# Example validation
if [ ! -d "$PROJECT_ROOT/.ralph" ]; then
    error "Invalid Ralph installation: .ralph/ directory not found"
fi
```

This catches cases where the script is somehow moved outside its expected location.

### Documentation Updates

Update the following files to reflect that symlinks now work reliably:

**install.sh** - show_success() function:
```bash
echo "  2. (Optional) Create a convenience symlink:"
echo -e "     ${BLUE}ln -s .ralph/ralph ralph${NC}"
echo -e "     Then you can run: ${BLUE}./ralph${NC} from anywhere in your repo"
```

**.ralph/ralph** - ralph_init() function:
```bash
echo "  1. (Optional) Create a convenience symlink:"
echo "     ln -s .ralph/ralph ralph"
echo "     Then you can run: ./ralph from anywhere in your repo"
```

**docs/installation.md** - Optional: Create Convenience Symlink section:
```markdown
### 2. Optional: Create Convenience Symlink

For easier access, create a symlink in your project root:

\`\`\`bash
ln -s .ralph/ralph ralph
\`\`\`

Now you can run Ralph with:

\`\`\`bash
./ralph
\`\`\`

The symlink works from anywhere inside your repository - Ralph automatically
resolves the project root regardless of your current working directory.
```

**docs/quickstart.md** - similar update where symlinks are mentioned.

## Success Criteria

- [x] `.ralph/ralph` resolves its own location using BASH_SOURCE
- [x] Script changes to project root before any operations
- [x] All prerequisite checks work after path resolution
- [x] All CLI commands work identically regardless of invocation method
- [x] Symlink from project root works: `ln -s .ralph/ralph ralph && ./ralph`
- [x] Script works when invoked from subdirectories via relative paths
- [x] Existing error messages and exit codes preserved
- [x] Documentation updated to reflect reliable symlink support
- [x] No breaking changes to existing functionality

## What is NOT Included

- **Global PATH installation** - Ralph remains project-local; no support for copying to `~/.local/bin` or system-wide installation
- **Windows/WSL compatibility** - This spec assumes bash on Unix-like systems; Windows batch/PowerShell wrappers are out of scope
- **Configuration file support** - No `.ralphrc` or config-based path overrides
- **Multi-project switching** - Each project has its own Ralph instance; no tool to switch between projects
- **Verification of correct git repository** - Script assumes if `.ralph/` exists and parent is a git repo, it's the right project

## Notes

This is a focused bug fix that makes the documented symlink approach actually work. The change is minimal (add 4 lines of path resolution at the top of `.ralph/ralph`) but significantly improves usability.
