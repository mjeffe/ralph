# Ralph Portable Integration

## Overview

Transform Ralph from a standalone project into a portable development tool that can be easily integrated into any existing or new project. Ralph should be unobtrusive, isolated, and project-agnostic.

## Problem Statement

Ralph currently assumes it IS the project - it expects to be cloned as the project root, includes example code (src/), and has files scattered between root and .ralph/. This makes it difficult to use Ralph as a development tool within other projects.

We need Ralph to be:
- **Portable** - Easy to install into any project via curl/wget
- **Isolated** - All operational files under .ralph/ (except specs/)
- **Unobtrusive** - Minimal impact on host project structure
- **Project-agnostic** - No assumptions about project type or structure
- **Maintainable** - Clear separation between Ralph tooling and project code

## Requirements

### 1. File Structure Reorganization

**Move to .ralph/:**
- `ralph` script → `.ralph/ralph`
- `IMPLEMENTATION_PLAN.md` → `.ralph/IMPLEMENTATION_PLAN.md`
- `PROGRESS.md` → `.ralph/PROGRESS.md`
- Documentation → `.ralph/docs/` (all current docs, updated)

**Keep in project root:**
- `specs/` - Project specifications (high visibility)

**Remove entirely:**
- `src/` directory and all contents (obsolete example code)
- `docs/` directory (moved to `.ralph/docs/`)

**Final structure when installed in a project:**
```
The-Project/
├── .ralph/                          # Ralph system (committed to project)
│   ├── ralph                        # Entry point
│   ├── loop.sh                      # Core loop
│   ├── AGENTS.md.template           # Template for project AGENTS.md
│   ├── IMPLEMENTATION_PLAN.md       # Task list
│   ├── PROGRESS.md                  # Completed work
│   ├── .ralph-version               # Track installed version
│   ├── .gitignore                   # Ignore logs/ directory
│   ├── prompts/
│   │   ├── PROMPT_build.md
│   │   └── PROMPT_plan.md
│   ├── logs/                        # Ignored by .ralph/.gitignore
│   │   └── *.log
│   └── docs/                        # Ralph documentation
│       ├── README.md
│       ├── quickstart.md
│       └── [other docs]
│
├── AGENTS.md                        # Agent guidelines (created by ralph init)
├── specs/                           # Project specs (committed to project)
│   ├── README.md
│   └── [project-specific specs]
│
├── [host project files...]
└── README.md                        # Host project readme
```

### 2. Installation Script

Create `install.sh` in Ralph repository root for curl-able installation.

**Behavior:**
1. Check prerequisites:
   - Verify running from a git repository
   - Check for existing `.ralph/` directory (error if exists)
   - Verify git is available

2. Fetch and copy Ralph:
   - Clone Ralph repo to temp directory
   - Copy `.ralph/` directory to current project
   - Remove `.git` directory from copied `.ralph/`
   - Add version identifier to `.ralph/.ralph-version`
   - Clean up temp directory

3. Output success message:
   - Where Ralph is installed
   - Next steps (run `.ralph/ralph init`)
   - Documentation location (`.ralph/docs/`)
   - Convenience symlink suggestion

**Usage:**
```bash
# From the host project root
curl -fsSL https://raw.githubusercontent.com/mjeffe/ralph/main/install.sh | bash

# Or with wget
wget -qO- https://raw.githubusercontent.com/mjeffe/ralph/main/install.sh | bash
```

**Error handling:**
- Not in git repo → clear error message
- `.ralph/` already exists → error with instructions
- Network failure → meaningful error
- Permission issues → clear guidance

### 3. Ralph Init Command

Add `init` subcommand to `.ralph/ralph` script.

**Behavior:**
```bash
.ralph/ralph init
```

1. Check prerequisites:
   - Verify running from git repository
   - Verify `.ralph/` directory exists (Ralph installed)

2. Create project structure:
   - Create `specs/` directory if missing
   - Create `specs/README.md` with starter template
   - Handle `AGENTS.md` intelligently (see below)

3. Handle AGENTS.md:
   - **If `AGENTS.md` does NOT exist:**
     - Create `AGENTS.md` from `.ralph/AGENTS.md.template`
     - Output: "✓ Created AGENTS.md from template"
   - **If `AGENTS.md` EXISTS:**
     - Do NOT overwrite or modify
     - Display informational message about ## Specifications section requirement
     - Reference `.ralph/AGENTS.md.template` for details

4. Output instructions:
   - Where documentation lives (`.ralph/docs/`)
   - How to run Ralph (`.ralph/ralph` or create symlink)
   - Suggestion to create convenience symlink: `ln -s .ralph/ralph ralph`
   - Next steps (create specs, run build loop)

**specs/README.md template:**
```markdown
# Specification Index

## Active Specifications

(No specifications yet - create your first spec)

## How to Create Specs

1. Create a new file: `specs/feature-name.md`
2. Document requirements, use cases, and success criteria
3. Run Ralph build loop: `.ralph/ralph`

See `.ralph/docs/` for detailed guidance on writing specifications.
```

### 4. Update All Path References

Update every script and document that references file paths:

**In .ralph/ralph:**
- Update path to `.ralph/loop.sh`
- Handle `init` subcommand

**In .ralph/loop.sh:**
- Update path to `.ralph/IMPLEMENTATION_PLAN.md`
- Update path to `.ralph/PROGRESS.md`
- Update path to `.ralph/prompts/PROMPT_build.md`

**In .ralph/prompts/PROMPT_build.md:**
- Update references to `IMPLEMENTATION_PLAN.md` → `.ralph/IMPLEMENTATION_PLAN.md`
- Update references to `PROGRESS.md` → `.ralph/PROGRESS.md`
- Remove all references to `src/` or project structure assumptions
- Emphasize reading specs for project structure

**In .ralph/prompts/PROMPT_plan.md:**
- Remove project structure assumptions
- Clarify that Ralph is project-agnostic

### 5. Documentation Updates

Move and update all documentation to `.ralph/docs/`:

**Create/Update:**
- `.ralph/docs/README.md` - Main Ralph documentation (updated from root README.md)
- `.ralph/docs/installation.md` - How to install Ralph into projects (must include AGENTS.md integration)
- `.ralph/docs/quickstart.md` - Getting started guide (must mention AGENTS.md setup)
- `.ralph/docs/writing-specs.md` - How to write specifications
- `.ralph/docs/troubleshooting.md` - Common issues

**Remove all:**
- Project-specific examples (calculator, etc.)
- References to `src/` directory
- Assumptions about project structure
- Language-specific guidance (PHP, Laravel, etc.)

**Emphasize:**
- Ralph is project-agnostic
- Project structure defined in specs
- Works with any language/framework
- Isolated in .ralph/ directory

**AGENTS.md Documentation Requirements:**

In `.ralph/docs/installation.md`, include:
- Explanation of why ## Specifications section is required in AGENTS.md
- How AGENTS.md connects agents to specs/
- Full example of AGENTS.md with both Ralph and project sections
- Instructions for integrating with existing AGENTS.md files

In `.ralph/docs/quickstart.md`, include:
- Brief mention of AGENTS.md creation during `ralph init`
- Where to find template if manual integration needed (`.ralph/AGENTS.md.template`)
- Note that only ## Specifications section is mandatory

Example for installation.md:
```markdown
## AGENTS.md Integration

Ralph requires a `## Specifications` section in your project's AGENTS.md file. This section directs agents to consult specs/README.md before implementing features, ensuring they work from specifications rather than assumptions.

### For New Projects
When you run `ralph init`, AGENTS.md will be created automatically from the template.

### For Existing Projects with AGENTS.md
If your project already has an AGENTS.md file, add this section:

[Include the ## Specifications section content here]

You can view the complete template at `.ralph/AGENTS.md.template` for reference.

### Customizing AGENTS.md
The template includes example sections for commit messages and code style. These are suggestions—modify or remove them to match your project's conventions. Only the ## Specifications section is required for Ralph.
```

### 6. Create .ralph/.gitignore

Create `.ralph/.gitignore` to ignore logs:

```gitignore
# Ralph execution logs
logs/
*.log
*.log.metrics
```

This prevents the need to modify the host project's .gitignore.

### 7. Placeholder State Files

Create placeholder files in Ralph repository:

**`.ralph/IMPLEMENTATION_PLAN.md`:**
```markdown
# Implementation Plan

## Remaining Tasks

(This file will be generated from specs/ on first build iteration)

## Notes

Run `.ralph/ralph` to begin the build loop.
```

**`.ralph/PROGRESS.md`:**
```markdown
# Progress Log

## Completed Tasks

(Tasks will be logged here as work is completed)
```

### 8. Version Tracking

Create `.ralph/.ralph-version` during installation:

```
RALPH_VERSION=1.0.0
INSTALLED_DATE=2026-02-12
SOURCE=https://github.com/mjeffe/ralph
```

This allows:
- Users to know what version they have
- Future `ralph update` command (future enhancement)
- Debugging and support

### 9. AGENTS.md Template Management

Create `.ralph/AGENTS.md.template` to provide agent guidelines for projects.

**Template structure:**

```markdown
# Agent Guidelines

<!-- ========================================================================
     RALPH REQUIREMENTS - DO NOT REMOVE
     The following section is required for Ralph to function properly.
     ======================================================================== -->

## Specifications

IMPORTANT: Before implementing any feature, consult the specifications in specs/README.md.

- Make NO assumptions about implementation status. Many specs describe planned features that may not yet exist in the codebase.
- Always search the codebase first. Before concluding something is or isn't implemented, thoroughly search the actual code. Specs describe intent; code describes reality.
- Search for related functionality by feature name, file locations mentioned in specs, and logical places it would live.
- Use specs as guidance. When implementing a feature, follow the design patterns, types, and architecture defined in the relevant spec.
- Spec index: specs/README.md lists all specifications organized by category.

<!-- ========================================================================
     PROJECT GUIDELINES - CUSTOMIZE BELOW
     The sections below are examples. Modify them to match your project's
     conventions, or remove them entirely if not needed.
     ======================================================================== -->

## General Guidelines

- You are an expert software developer
- You always strive for simple and elegant solutions using SOLID programming principles
- You prioritize pragmatic simplicity over theoretical purity
- DO NOT over-engineer
- DO NOT add features I didn't request
- Keep solutions simple and direct
- Prefer boring, readable code

## Commit Messages

- NO agent attribution
- NO "Generated with" footers
- Use conventional commits (feat:, fix:, etc.)
- First line under 72 characters followed by a blank line

## Code Style

- **Formatting**: Follow project conventions (check existing code)
- **Naming**: Follow language/framework conventions
- **Comments**: Only add comments when code is complex and requires context
```

**Ralph init behavior:**

When `ralph init` is run:

1. **If `AGENTS.md` does NOT exist:**
   - Create `AGENTS.md` from `.ralph/AGENTS.md.template`
   - Output: "✓ Created AGENTS.md from template"

2. **If `AGENTS.md` EXISTS:**
   - Do NOT overwrite or modify
   - Output informational message:
   ```
   ⚠ Note: Found existing AGENTS.md
   
   Ralph requires a "## Specifications" section in AGENTS.md for proper operation.
   This section tells agents to consult specs/README.md before implementing features.
   
   Please add this section to your AGENTS.md (see .ralph/AGENTS.md.template for the exact content).
   
   You can review the full template at: .ralph/AGENTS.md.template
   ```

**Why this approach:**

- **Minimal intrusion:** Only ## Specifications section is required
- **Flexible:** Works with existing AGENTS.md files
- **Clear separation:** Comments distinguish Ralph vs project sections
- **Customizable:** Projects can modify or remove example sections
- **Reference:** Template serves as documentation and example

### 10. Update ralph-overview.md

Update `specs/ralph-overview.md` to reflect new structure:
- Update all file paths to use `.ralph/` prefix
- Remove project-specific assumptions
- Update examples to show `.ralph/` paths
- Clarify that Ralph can be used in any project
- Mention AGENTS.md requirement (## Specifications section)
- Explain how AGENTS.md connects agents to specs/

## Success Criteria

- [ ] All Ralph files except specs/ moved under .ralph/
- [ ] `install.sh` script works via curl/wget
- [ ] `ralph init` command creates specs/ and template
- [ ] `.ralph/AGENTS.md.template` created with full structure
- [ ] `ralph init` intelligently handles existing AGENTS.md
- [ ] All path references updated throughout codebase
- [ ] Documentation moved to .ralph/docs/ and updated
- [ ] `.ralph/docs/installation.md` includes AGENTS.md integration guide
- [ ] `.ralph/docs/quickstart.md` mentions AGENTS.md setup
- [ ] src/ directory completely removed
- [ ] .ralph/.gitignore created
- [ ] Placeholder IMPLEMENTATION_PLAN.md and PROGRESS.md created
- [ ] .ralph/.ralph-version created during install
- [ ] specs/ralph-overview.md updated with new paths and AGENTS.md requirement
- [ ] No assumptions about project structure in any Ralph files
- [ ] Installation tested in a fresh project
- [ ] Build loop works with new paths
- [ ] All documentation reviewed for accuracy

## Out of Scope

- Configuration file support (future enhancement)
- `ralph update` command (future enhancement)
- Multiple agent support beyond cline (future enhancement)
- Git submodule installation method (using copy approach)
- Plan mode installation (use install script for now)

## Future Enhancements

Once core portability is achieved, consider:
- `ralph update` - fetch and merge upstream changes
- Configuration file (`.ralph/config.yml`)
- Multi-agent support (roo, crush, etc.)
- Ralph marketplace/plugin system
- Project templates for common stacks

## Testing Approach

1. **Install in fresh project:**
   ```bash
   mkdir test-project && cd test-project
   git init
   curl -fsSL https://raw.githubusercontent.com/mjeffe/ralph/main/install.sh | bash
   .ralph/ralph init
   ```

2. **Create test spec:**
   ```bash
   echo "# Test Feature" > specs/test-feature.md
   # Add simple requirements
   ```

3. **Run build loop:**
   ```bash
   .ralph/ralph 1  # Single iteration
   # Verify IMPLEMENTATION_PLAN.md created
   # Verify paths work correctly
   ```

4. **Verify isolation:**
   - Check that .ralph/logs/ is gitignored
   - Verify no impact on project root
   - Confirm specs/ is only visible non-ralph directory

## Migration Notes

For current Ralph users (if any):
- Backup existing project
- Install new portable Ralph into fresh directory
- Manually copy specs/ to new location
- Review and migrate any customizations
- This is a breaking change

## Implementation Priority

1. File reorganization (move files to .ralph/)
2. Update path references (critical for functionality)
3. Remove src/ directory
4. Create placeholder state files
5. Create .ralph/.gitignore
6. Update documentation
7. Create install.sh script
8. Implement ralph init command
9. Add .ralph-version tracking
10. Final testing and validation
