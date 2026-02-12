# Ralph Documentation

Ralph is a portable development tool that enables LLM coding agents to work on large projects by breaking work into discrete, manageable chunks with fresh context per iteration.

## What is Ralph?

Ralph addresses the context window limitations of Large Language Models by:

- **Fresh Context Per Iteration** - Each loop iteration starts the agent with a clean slate
- **Persistent Memory** - Critical information persists in files between iterations
- **Incremental Progress** - Agent completes one focused task per iteration
- **Self-Documenting** - All decisions and progress tracked in version control

This enables agents to work on projects of arbitrary size while maintaining coherence through persistent documentation.

## Key Concepts

### The Ralph Loop

Ralph operates in a continuous loop:

1. **Read State** - Agent reads specs, implementation plan, and progress
2. **Select Task** - Agent chooses highest priority task from plan
3. **Implement** - Agent implements the task completely (no placeholders)
4. **Test** - Agent runs tests and fixes any failures
5. **Document** - Agent updates plan and progress files
6. **Commit** - Agent commits changes with descriptive message
7. **Exit** - Loop exits, next iteration starts with fresh context

### Fresh Context

Each iteration starts with a clean slate:
- Agent has no memory of previous iterations
- All state persists in files: `specs/`, `.ralph/IMPLEMENTATION_PLAN.md`, `.ralph/PROGRESS.md`, git history
- Agent re-reads these files every iteration to understand current state

### Specifications-Driven

Ralph is specifications-driven:
- Human authors specifications in `specs/`
- Specifications define requirements, not implementation
- Agent reads specs to understand what to build
- Agent searches codebase to understand what exists
- Agent implements only what's specified

## File Structure

When Ralph is installed in a project:

```
Your-Project/
├── .ralph/                          # Ralph system (committed to project)
│   ├── ralph                        # Entry point script
│   ├── loop.sh                      # Core loop implementation
│   ├── AGENTS.md.template           # Template for project AGENTS.md
│   ├── IMPLEMENTATION_PLAN.md       # Task list (agent-maintained)
│   ├── PROGRESS.md                  # Completed work (agent-maintained)
│   ├── .ralph-version               # Track installed version
│   ├── .gitignore                   # Ignore logs/ directory
│   ├── prompts/                     # Agent instructions
│   │   ├── PROMPT_build.md
│   │   └── PROMPT_plan.md
│   ├── logs/                        # Execution logs (gitignored)
│   │   └── *.log
│   └── docs/                        # Ralph documentation
│       ├── README.md                # This file
│       ├── installation.md
│       ├── quickstart.md
│       ├── writing-specs.md
│       └── troubleshooting.md
│
├── AGENTS.md                        # Agent guidelines (created by ralph init)
├── specs/                           # Project specifications (committed)
│   ├── README.md                    # Spec index
│   └── [your-specs].md
│
└── [your project files...]
```

## Core Files

### specs/ - Requirements Documentation

Human-authored specifications that define what to build:

- One spec file per major feature/component
- Capture the "why" not just the "what"
- Include examples, use cases, edge cases
- Update when requirements change
- Create specs manually or with any tool you prefer

### .ralph/IMPLEMENTATION_PLAN.md - Remaining Work

Agent-maintained prioritized list of tasks:

- Created by agent in first build iteration
- Simple ordered list (top = highest priority)
- Agent removes completed items (moves to PROGRESS.md)
- Agent adds discovered issues/gaps
- Contains completion marker when all work done

### .ralph/PROGRESS.md - Completed Tasks

Historical record of completed work:

- Reverse chronological order (newest first)
- Grouped by date
- Includes commit hash for traceability
- Brief notes on implementation details

### AGENTS.md - Agent Guidelines

Project-specific guidelines for agents:

- Created by `ralph init` from template
- Must include `## Specifications` section (required by Ralph)
- Customize other sections for your project
- Defines commit message format, code style, etc.

## Getting Started

See [quickstart.md](quickstart.md) for step-by-step guide.

## Documentation

- [Installation](installation.md) - How to install Ralph into your project
- [Quick Start](quickstart.md) - Getting started guide
- [Writing Specs](writing-specs.md) - How to write effective specifications
- [Troubleshooting](troubleshooting.md) - Common issues and solutions

## Project-Agnostic Design

Ralph makes no assumptions about your project:

- Works with any programming language
- Works with any framework
- Works with any project structure
- No required dependencies (except git and cline CLI)
- All project-specific information comes from specs/

## References

- [Original Ralph post](https://ghuntley.com/ralph/)
- [Geoffrey Huntley's Loom project](https://github.com/ghuntley/loom/)
- [Ralph Playbook](https://github.com/ClaytonFarr/ralph-playbook)
- [The Real Ralph Wiggum Loop](https://thetrav.substack.com/p/the-real-ralph-wiggum-loop-what-everyone)

## License

See LICENSE file in project root for details.
