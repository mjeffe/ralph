# Specification Index

This document provides a structured index of all specifications. Use this as your starting point to understand the system and locate relevant documentation.

## Specification Templates

Templates for creating new specs are available in `specs/templates/`:
- **overview-template.md** - For system-wide overview documents
- **architecture-template.md** - For subsystem architecture documentation
- **feature-template.md** - For new feature specifications
- **change-template.md** - For refactors, reworks, and system changes

## Living Overview (Current System)

These documents describe the system as it exists today.

- **ralph-overview.md** - Quick reference guide for agents. Condensed overview of the Ralph loop, file roles, agent workflow, task selection criteria, completion signals, and error handling. Essential reading before each iteration.

- **ralph-system-implementation.md** - Complete specification for the Ralph system. Describes the iterative development system, architecture, workflow, error handling, and bootstrap instructions. This is the current, simplified version focusing on build-only mode.

## Architecture Specs

Detailed subsystem documentation describing how specific parts of the system work.

*(No architecture specs yet - will be created as system grows)*

## Feature Specs

Specifications for individual features and capabilities.

- **features/ralph-portable-integration.md** - Transform Ralph into a portable development tool. Reorganizes all Ralph files under .ralph/, creates curl-able installation script, adds ralph init command, makes Ralph completely project-agnostic.
  - Status: **Implemented** (2026-02-12)

- **features/ralph-path-resilient.md** - Fix symlink path resolution bug in `.ralph/ralph` entry point. Makes the script automatically resolve its location and change to project root.
  - Status: **Implemented** (2026-02-13)

- **features/agent-output-filtering.md** - Terminal output filter for Ralph build loop. Parses JSON-formatted agent output to display human-readable activity while hiding verbose prompts.
  - Status: **Implemented** (2026-02-13)

- **features/branch-safety-check.md** - Pre-flight safety check for Ralph entry point. Detects when running on protected branches and prompts user to abort or create a new branch.
  - Status: **Implemented** (2026-02-13)

- **features/test-simple-calculator.md** - Test specification to validate Ralph loop functionality. Defines a simple calculator module with basic operations, input validation, and comprehensive tests.
  - Status: **Implemented** (2026-02-05)

- **features/docker-env-implementation-plan.md** - Automatic .env file configuration for cline CLI in Docker container.
  - Status: **Implemented** (2026-02-05)

- **features/docker-configuration-fix-plan.md** - Fixed environment file path mismatch and directory permissions.
  - Status: **Implemented** (2026-02-05)

## Change Specs (Reworks / Refactors)

Specifications for changes to existing functionality. These describe transitions from current behavior to proposed behavior.

- **changes/logging-rework.md** - Rework Ralph's logging system to produce a single log file per invocation, embed metrics directly in the log, eliminate PROGRESS.md entirely, and include task/spec references in iteration headers.
  - Status: **Implemented** (2026-02-17)
  - Type: refactor
  - Updated: ralph-overview.md

## Archived / Superseded

Obsolete or superseded specifications moved to `specs/archive/` for historical reference.

- **archive/project-complete-reset.md** - Fix bug where PROJECT_COMPLETE marker prevents starting new build cycles.

- **archive/plan-mode-fix.md** - Plan mode was removed from Ralph. The system now focuses solely on autonomous build loops.

- **archive/ralph-system-initial-implementation.md** - Superseded by ralph-system-implementation.md. The original specification included plan mode, which over-complicated the system.
