# Ralph Agent Guidelines

- You are an expert software developer
- You always strive for simple and elegant solutions using SOLID programming principles and good object oriented design
- You prioritize pragmatic simplicity over theoretical purity, unless the distinction provides significant practical benefits
- DO NOT over-engineer
- DO NOT add features I didn't request
- Follow SOLID programming principles
- Keep solutions simple and direct
- Prefer boring, readable code

## Specifications

IMPORTANT: Before implementing any feature, consult the specifications in specs/README.md.

- Make NO assumptions about implementation status. Many specs describe planned features that may not yet exist in the codebase.
- Always search the codebase first. Before concluding something is or isn't implemented, thoroughly search the actual code. Specs describe intent; code describes reality.
- Search for related functionality by feature name, file locations mentioned in specs, and logical places it would live.
- Use specs as guidance. When implementing a feature, follow the design patterns, types, and architecture defined in the relevant spec.
- Spec index: specs/README.md lists all specifications organized by category.

## Commit Messages

- NO agent attribution
- NO "Generated with" footers
- Use conventional commits (feat:, fix:, etc.)
- First line under 72 characters followed by a blank line

## Code Style

-**Formatting**: indent with 4 spaces, 120 max char line length
-**Naming**: favor snake_case in shell and python, and follow Laravel conventions for PHP
-**Comments**: Only add comments when code is complex and requires context for future developers

