# Specification Index

## System Specifications

- **ralph-system-implementation.md** - Complete specification for the Ralph Wiggum Loop system. Describes the iterative development system that solves LLM context limitations through fresh context per iteration, persistent file-based memory, and git-tracked progress. Includes architecture, workflow, error handling, and bootstrap instructions. This is the current, simplified version focusing on build-only mode.

- **ralph-overview.md** - Quick reference guide for agents working within Ralph. Condensed overview of the Ralph loop, file roles (specs/, IMPLEMENTATION_PLAN.md, PROGRESS.md), agent workflow, task selection criteria, completion signals, error handling, and working with specs. Essential reading before each iteration.

## Feature Specifications

- **project-complete-reset.md** - Fix bug where PROJECT_COMPLETE marker prevents starting new build cycles. When PROJECT_COMPLETE is detected, automatically reset IMPLEMENTATION_PLAN.md to minimal template, commit the change, and exit cleanly. Next cycle regenerates plan from specs/ without manual intervention.

- **test-simple-calculator.md** - Test specification to validate Ralph loop functionality. Defines a simple calculator module with basic operations, input validation, and comprehensive tests. Used to verify IMPLEMENTATION_PLAN.md creation, task execution, PROGRESS.md updates, and git integration.

- **docker-env-implementation-plan.md** - Automatic .env file configuration for cline CLI in Docker container. Eliminates manual setup by reading environment variables from .env file and automatically authenticating cline on container startup.

- **docker-configuration-fix-plan.md** - Fixed environment file path mismatch and directory permissions. Corrected .env loading path from `/home/ralph/.env` to `/app/.env`, set proper ownership of /app directory, and established consistent WORKDIR at /app.

## Archived Specifications

Obsolete or superseded specifications moved to `specs/archive/` for historical reference.

- **plan-mode-fix.md** (archived 2026-02-12) - Plan mode was removed from Ralph. The system now focuses solely on autonomous build loops. Specifications should be created manually or with any tool you prefer (cline CLI directly, ChatGPT, Claude, etc.).

- **ralph-system-initial-implementation.md** (archived 2026-02-12) - Superseded by ralph-system-implementation.md. The original specification included plan mode, which over-complicated the system. The new simplified specification focuses on Ralph's core strength: autonomous build loops.
