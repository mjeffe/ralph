# Specification Index

## Specifications

- **ralph-overview.md** - An overview of the ralph system and how it works.

- **project-complete-reset.md** - Fix bug where PROJECT_COMPLETE marker prevents starting new build cycles. When PROJECT_COMPLETE is detected, automatically reset IMPLEMENTATION_PLAN.md to minimal template, commit the change, and exit cleanly. Next cycle regenerates plan from specs/ without manual intervention.

- **ralph-system-initial-implementation.md** - Core specification for the Ralph Wiggum Loop iterative development system. Defines architecture, components, workflows, and operating modes for enabling LLM agents to work on large projects through fresh context per iteration.

- **test-simple-calculator.md** - Test specification to validate Ralph loop functionality. Defines a simple calculator module with basic operations, input validation, and comprehensive tests. Used to verify IMPLEMENTATION_PLAN.md creation, task execution, PROGRESS.md updates, and git integration.

- **plan-mode-fix.md** - Fixed critical bug preventing interactive planning sessions. Changed cline invocation method, integrated spec name hints, added automatic git commit after sessions, and simplified plan mode execution by removing build-mode features (logging, health checks, validation hooks, metrics parsing).

- **docker-env-implementation-plan.md** - Automatic .env file configuration for cline CLI in Docker container. Eliminates manual setup by reading environment variables from .env file and automatically authenticating cline on container startup.

- **docker-configuration-fix-plan.md** - Fixed environment file path mismatch and directory permissions. Corrected .env loading path from `/home/ralph/.env` to `/app/.env`, set proper ownership of /app directory, and established consistent WORKDIR at /app.
