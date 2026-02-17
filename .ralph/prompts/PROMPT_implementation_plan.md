# Implementation Plan Generation Guide

**This guide is used ONLY when creating a new IMPLEMENTATION_PLAN.md from specifications.**

---

## Spec Templates

Before creating specs, review the templates in `specs/templates/`:
- **overview-template.md** - For system overview documents
- **architecture-template.md** - For subsystem architecture
- **feature-template.md** - For new features
- **change-template.md** - For refactors and reworks

## Format Template

Use this structure for IMPLEMENTATION_PLAN.md:

```markdown
# Implementation Plan

## Overview

[Brief summary of what this plan implements:
- Which spec(s) are being implemented
- Current state of the project
- High-level approach]

## Remaining Tasks

```json
[
  {
    "id": "T-001",
    "description": "[Task description - action-oriented, brief]",
    "spec": "specs/feature-name.md",
    "priority": "HIGH",
    "status": "OPEN",
    "notes": [
      "[Optional: Key detail or constraint]"
    ]
  },
  {
    "id": "T-002",
    "description": "[Next task description]",
    "spec": "",
    "priority": "MEDIUM",
    "status": "OPEN",
    "notes": []
  }
]
```
```

**JSON Schema Requirements:**

Each task object MUST contain all required fields:
- **`id`**: Unique identifier, format "T-NNN" (e.g., "T-001", "T-002")
- **`description`**: Brief, action-oriented task description
- **`spec`**: Spec file path (e.g., "specs/feature-name.md") or empty string ""
- **`priority`**: One of "HIGH", "MEDIUM", "LOW", or empty string ""
- **`status`**: One of "OPEN", "BLOCKED", "DONE", or empty string ""
- **`notes`**: Array of strings for details/constraints; empty array [] allowed

**Formatting Rules:**
- JSON block MUST be fenced with triple backticks and `json` language identifier
- Pretty-print with 2-space indentation (human readable)
- All fields required even if empty string "" or empty array []
- First task in array = highest priority

## Notes

### Implementation Strategy
[How to approach this work - any important sequencing or considerations]

### Dependencies
[Explicit task dependencies if any - "Task X must complete before Task Y"]

### Success Criteria
[What defines completion for this plan]

[Additional notes sections as needed]
```

---

## Task Granularity Guidelines

**Goal:** Each task should be completable in one iteration

**Appropriate Task Sizes:**

- **Too granular:** "Create .ralph/.gitignore file" + "Add logs/ to .gitignore" + "Add *.log to .gitignore"
  - **Better:** "Create .ralph/.gitignore to ignore logs/ and *.log files"

- **Too broad:** "Implement entire authentication system"
  - **Better:** Break into: "Create user model and database schema", "Implement login endpoint", "Add JWT token generation", etc.

**Grouping Rules:**
- Related file operations can be grouped (moving multiple files to same directory)
- Sequential steps within one feature can be grouped if they're quick
- Breaking changes that must be atomic should stay together
- Testing belongs with implementation, not as separate task

---

## Prioritization Criteria

**Order tasks using this hierarchy:**

1. **Prerequisites first** - Foundational work that unblocks other tasks
   - Example: File structure reorganization before updating path references
   - Example: Creating database tables before adding API endpoints

2. **Core functionality before enhancements**
   - Get basic feature working before adding advanced options
   - Implement happy path before edge cases

3. **Implementation before documentation**
   - Build features first, document after they work
   - Exception: When docs ARE the feature (like writing user guides)

4. **Critical path before nice-to-haves**
   - Features required for MVP come first
   - Polish and optimization can wait

**Priority Markers:**
- Use `[HIGH PRIORITY]` for blocking work or critical features
- Use `[MEDIUM]` for standard feature work
- Use `[LOW]` for enhancements, optimizations, or nice-to-haves
- No marker = medium priority assumed

---

## Plan Regeneration Consistency

**If regenerating the plan for the same spec:**

The goal is to produce similar (though not necessarily identical) plans when regenerating from the same spec. This ensures predictability and reduces confusion.

- **Maintain similar task granularity** - Don't switch between atomic and composite tasks
- **Use consistent ordering logic** - Apply the same prioritization rules
- **Preserve context** - If plan had [BLOCKED] tasks or notes about in-progress work, consider them
- **Follow the same grouping patterns** - If first plan grouped file moves, do it again

**When variation is acceptable:**
- Discovering better task sequences as you understand the work
- Breaking down tasks that were too broad in first attempt
- Adjusting priorities based on discovered dependencies

---

## Searching the Codebase

**CRITICAL:** Before adding tasks to the plan, search the codebase to verify what's implemented.

Use these search strategies:

1. **Feature names** - Search for key feature names from specs
   ```
   search_files for "authentication", "login", "user_profile", etc.
   ```

2. **File locations mentioned in specs** - Check if files exist at specified paths
   ```
   Check for src/auth/login.js, lib/database.py, etc.
   ```

3. **API endpoints or function signatures** - Search for endpoint routes or function definitions
   ```
   search_files for "/api/users", "def calculate_total", "class UserController", etc.
   ```

4. **Logical locations** - Think where feature would naturally live
   ```
   For auth features: src/auth/, lib/auth/, middleware/auth.js
   For database: src/models/, db/, migrations/
   ```

**Document findings in Overview:**
```markdown
## Overview

Implementing spec: specs/ralph-portable-integration.md

Search findings:
- No .ralph/ directory structure exists yet (grep confirmed)
- Current files are in root directory
- No install.sh script exists
- AGENTS.md exists but lacks ## Specifications section
```

---

## Common Patterns

### Task with Spec Reference

**Always include spec reference when task implements a specification.**

This helps future iterations understand:
- Which spec section defines the requirements
- Where to find detailed implementation guidance
- How to verify the task meets specifications

**Format (JSON):**
```json
{
  "id": "T-001",
  "description": "Implement user registration endpoint",
  "spec": "specs/user-management.md",
  "priority": "HIGH",
  "status": "OPEN",
  "notes": [
    "POST /api/users with validation",
    "Hash passwords with bcrypt"
  ]
}
```

**Examples:**

✅ **Good - Clear spec reference:**
```json
{
  "id": "T-001",
  "description": "Implement user registration endpoint",
  "spec": "specs/user-management.md",
  "priority": "HIGH",
  "status": "OPEN",
  "notes": [
    "POST /api/users with validation",
    "Hash passwords with bcrypt",
    "Spec section: Registration"
  ]
}
```

✅ **Good - Multiple related tasks from same spec:**
```json
[
  {
    "id": "T-001",
    "description": "Add output filter script",
    "spec": "specs/agent-output-filtering.md",
    "priority": "HIGH",
    "status": "OPEN",
    "notes": [
      "Create .ralph/lib/filter-output.sh",
      "Parse JSON-formatted agent output",
      "Spec section: Filter Script"
    ]
  },
  {
    "id": "T-002",
    "description": "Integrate filter into loop.sh",
    "spec": "specs/agent-output-filtering.md",
    "priority": "HIGH",
    "status": "OPEN",
    "notes": [
      "Pipe agent output through filter",
      "Preserve raw logs for debugging",
      "Spec section: Integration"
    ]
  }
]
```

✅ **Good - Task without spec (internal refactoring):**
```json
{
  "id": "T-003",
  "description": "Refactor database connection pooling",
  "spec": "",
  "priority": "MEDIUM",
  "status": "OPEN",
  "notes": [
    "Extract connection logic to separate module",
    "Add connection retry logic",
    "No spec - internal improvement"
  ]
}
```

❌ **Missing required fields:**
```json
{
  "id": "T-001",
  "description": "Implement user registration endpoint"
}
```
*Why bad: Missing required fields (spec, priority, status, notes)*

❌ **Vague spec reference:**
```json
{
  "id": "T-001",
  "description": "Implement user registration endpoint",
  "spec": "user-management.md",
  "priority": "HIGH",
  "status": "OPEN",
  "notes": []
}
```
*Why bad: Spec path should include "specs/" prefix*

❌ **Not properly formatted JSON:**
```json
{id: "T-001", description: "Task"}
```
*Why bad: Missing quotes around field names, missing required fields*

**When to use empty spec field:**
- Internal refactoring not driven by a spec
- Bug fixes discovered during implementation
- Tooling or infrastructure improvements
- In these cases, add explanation in notes array

### Multi-Phase Projects

For large refactors or system changes, use priority field and notes to indicate phases:

```json
[
  {
    "id": "T-001",
    "description": "Core infrastructure task",
    "spec": "specs/system-refactor.md",
    "priority": "HIGH",
    "status": "OPEN",
    "notes": ["Phase 1 - Foundation"]
  },
  {
    "id": "T-002",
    "description": "Another core infrastructure task",
    "spec": "specs/system-refactor.md",
    "priority": "HIGH",
    "status": "OPEN",
    "notes": ["Phase 1 - Foundation"]
  },
  {
    "id": "T-003",
    "description": "Feature implementation task",
    "spec": "specs/system-refactor.md",
    "priority": "MEDIUM",
    "status": "OPEN",
    "notes": ["Phase 2 - Implementation", "Depends on T-001, T-002"]
  },
  {
    "id": "T-004",
    "description": "Integration task",
    "spec": "specs/system-refactor.md",
    "priority": "LOW",
    "status": "OPEN",
    "notes": ["Phase 3 - Integration & Testing"]
  }
]
```

### Migration Projects

When moving from old to new architecture:

```markdown
## Notes

### Migration Strategy
1. Build new system alongside old (no breaking changes yet)
2. Add feature flags to switch between old and new
3. Test thoroughly with new system
4. Remove old system in final task
```

### Spec with Dependencies

When one spec requires another to be complete:

```markdown
## Notes

### Dependencies
- Requires specs/database-schema.md to be fully implemented first
- Task 3 depends on Task 1 completing (path references need moves to finish)
- Testing tasks (10-12) should be done after all features (1-9) are complete
```

---

## What NOT to Include in Tasks

Avoid these common pitfalls:

❌ **"Research how to..."** - Do research during planning, not as a task
❌ **"Discuss with team..."** - Ralph is autonomous, no human-in-loop tasks
❌ **"Consider whether to..."** - Make decisions during planning
❌ **"TODO: Figure out..."** - Plans should be decisive
❌ **Unspecified tasks** - "Improve performance" is too vague
❌ **Open-ended tasks** - "Add more tests as needed" has no completion criteria

✅ **Do use clear, actionable tasks:**
- "Implement user authentication with JWT tokens per spec section 3.2"
- "Refactor database queries to use connection pooling"
- "Add integration tests for all API endpoints in specs/api-spec.md"

---

## Examples

### Good Implementation Plan

```markdown
# Implementation Plan

## Overview

Implementing specs/user-management.md - user CRUD operations and authentication.

Search findings:
- No existing user model or database schema
- No authentication middleware exists
- Basic Express.js app structure exists in src/app.js
- Database connection configured in src/db/connection.js

## Remaining Tasks

```json
[
  {
    "id": "T-001",
    "description": "Create user database schema and model",
    "spec": "specs/user-management.md",
    "priority": "HIGH",
    "status": "OPEN",
    "notes": [
      "Add users table migration with fields per spec section 2.1",
      "Create User model with validation",
      "Spec section: Database Schema"
    ]
  },
  {
    "id": "T-002",
    "description": "Implement user registration endpoint",
    "spec": "specs/user-management.md",
    "priority": "HIGH",
    "status": "OPEN",
    "notes": [
      "POST /api/users with email, password, name",
      "Hash passwords with bcrypt",
      "Validation: email format, password min 8 chars",
      "Spec section: Registration"
    ]
  },
  {
    "id": "T-003",
    "description": "Implement JWT authentication",
    "spec": "specs/user-management.md",
    "priority": "MEDIUM",
    "status": "OPEN",
    "notes": [
      "POST /api/auth/login endpoint",
      "Generate JWT tokens with 24hr expiry",
      "Create auth middleware for protected routes",
      "Spec section: Authentication"
    ]
  },
  {
    "id": "T-004",
    "description": "Add user profile endpoints",
    "spec": "specs/user-management.md",
    "priority": "MEDIUM",
    "status": "OPEN",
    "notes": [
      "GET /api/users/:id (authenticated)",
      "PUT /api/users/:id (authenticated, own profile only)",
      "Spec section: User Profile"
    ]
  },
  {
    "id": "T-005",
    "description": "Add integration tests for all endpoints",
    "spec": "specs/user-management.md",
    "priority": "LOW",
    "status": "OPEN",
    "notes": [
      "Test registration success and validation errors",
      "Test login success and failure cases",
      "Test profile access controls",
      "All tests must pass before completion"
    ]
  },
  {
    "id": "T-006",
    "description": "Update specs/README.md to mark spec as Implemented",
    "spec": "",
    "priority": "LOW",
    "status": "OPEN",
    "notes": []
  }
]
```
```

## Notes

### Implementation Strategy
- Use existing database connection pattern from src/db/connection.js
- Follow Express.js middleware patterns already in codebase
- JWT secret should be loaded from environment variable

### Success Criteria
- All endpoints return correct status codes and responses per spec
- Password hashing working (never store plain text)
- Authentication required for protected routes
- All integration tests passing
- No security vulnerabilities (validated passwords, protected routes)
```

### Poor Implementation Plan (Don't do this)

```markdown
# Implementation Plan

## Remaining Tasks

```json
[
  {
    "id": "1",
    "description": "Set up user stuff",
    "spec": "",
    "priority": "",
    "status": "",
    "notes": []
  },
  {
    "description": "Do authentication",
    "spec": "user-management.md"
  },
  {"id": "T-003", "description": "Fix any bugs"}
]
```
```

**Why this is poor:**
- Vague task descriptions ("user stuff", "do authentication")
- Inconsistent ID format ("1" vs "T-003")
- Missing required fields (second and third tasks)
- No proper spec path format ("user-management.md" should be "specs/user-management.md")
- Open-ended tasks ("fix any bugs")
- No priorities or meaningful status
- No structure or success criteria
- Malformed JSON (second and third objects missing fields)

---

## Final Checklist

Before committing your new IMPLEMENTATION_PLAN.md:

- [ ] Format follows the template (Overview, JSON Tasks, Notes)
- [ ] Remaining Tasks section contains fenced ```json block
- [ ] JSON is valid and pretty-printed (2-space indentation)
- [ ] All task objects have all required fields (id, description, spec, priority, status, notes)
- [ ] Task IDs follow "T-NNN" format with zero-padding
- [ ] Each task description is action-oriented and specific
- [ ] Spec paths include "specs/" prefix or are empty string ""
- [ ] Priority values are "HIGH", "MEDIUM", "LOW", or ""
- [ ] Status values are "OPEN", "BLOCKED", "DONE", or ""
- [ ] Notes are arrays (empty array [] allowed)
- [ ] Task order reflects priority (first = highest)
- [ ] Task granularity is appropriate (completable in one iteration)
- [ ] Prioritization follows the criteria (prerequisites first, etc.)
- [ ] Dependencies are documented in Notes section or task notes
- [ ] Success criteria are clear in Notes section
- [ ] You searched the codebase to verify what's actually implemented
- [ ] No vague, open-ended, or research tasks
- [ ] Plan is between 5-20 tasks (adjust for project complexity)

---

**Remember:** A good implementation plan is a roadmap that any agent can follow in future iterations. Be specific, be decisive, and be thorough.
