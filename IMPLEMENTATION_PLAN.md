# Implementation Plan

## Remaining Tasks

### High Priority - Core Portability

1. Move IMPLEMENTATION_PLAN.md to .ralph/IMPLEMENTATION_PLAN.md
   - Update this file's location
   - Update all references in loop.sh and prompts

3. Move PROGRESS.md to .ralph/PROGRESS.md
   - Move existing progress log
   - Update all references in loop.sh and prompts

4. Move ralph script to .ralph/ralph
   - Move entry point script
   - Update to reference .ralph/loop.sh correctly
   - Add 'init' subcommand support

5. Create placeholder state files in .ralph/
   - Create minimal IMPLEMENTATION_PLAN.md template
   - Create minimal PROGRESS.md template
   - These will be in the repo for fresh installations

6. Move documentation to .ralph/docs/
   - Create .ralph/docs/ directory
   - Move README.md content to .ralph/docs/README.md
   - Move docs/* to .ralph/docs/
   - Update all documentation for new structure

7. Remove src/ directory
   - Delete src/lib/calculator.js
   - Delete src/lib/calculator.test.js
   - Remove entire src/ directory (example code no longer needed)

8. Update .ralph/loop.sh path references
   - Update IMPLEMENTATION_PLAN.md path to .ralph/IMPLEMENTATION_PLAN.md
   - Update PROGRESS.md path to .ralph/PROGRESS.md
   - Update prompts path references

9. Update .ralph/prompts/PROMPT_build.md
    - Update all file path references to use .ralph/ prefix
    - Remove src/ directory assumptions
    - Remove project-specific examples
    - Emphasize project-agnostic approach

10. Create install.sh script
    - Curl-able installation script
    - Check prerequisites (git repo, no existing .ralph/)
    - Clone Ralph to temp, copy .ralph/ to project
    - Add .ralph/.ralph-version file
    - Clean up temp directory

11. Implement 'ralph init' command
    - Add init subcommand to .ralph/ralph script
    - Create specs/ directory if missing
    - Create specs/README.md template
    - Handle AGENTS.md intelligently (create from template or show message)

12. Update specs/ralph-overview.md
    - Update all file paths to use .ralph/ prefix
    - Remove project-specific assumptions
    - Add AGENTS.md requirement documentation
    - Update examples with new structure

13. Create .ralph/docs/installation.md
    - Document curl installation method
    - Include AGENTS.md integration guide
    - Explain ## Specifications section requirement
    - Provide examples for new and existing projects

14. Create .ralph/docs/quickstart.md
    - Getting started guide
    - Mention AGENTS.md setup during init
    - Reference template location
    - Simple workflow example

15. Update .ralph/docs/README.md
    - Main Ralph documentation
    - Remove project-specific examples (calculator)
    - Remove language-specific guidance
    - Emphasize project-agnostic nature

16. Test installation in fresh project
    - Create test project
    - Run install.sh
    - Run ralph init
    - Verify structure and functionality

17. Update specs/README.md
    - Mark ralph-portable-integration.md as Implemented
    - Add completion date
    - Update status tracking

## Notes

- This is a major architectural change for portability
- All Ralph files (except specs/) will move under .ralph/
- Breaking change for current Ralph users (if any)
- Focus on making Ralph a portable tool, not a project itself
- AGENTS.md template is critical for proper agent behavior
- Only ## Specifications section is required in AGENTS.md
- Installation script must be curl-able from GitHub
- All documentation must be project-agnostic
