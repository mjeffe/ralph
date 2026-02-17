# Implementation Plan Generation Guide

**This guide is used ONLY when creating a new IMPLEMENTATION_PLAN.md from specifications.**

---

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

### [Priority Level] - [Category Name]

1. [Task description - action-oriented, brief]
   - [Optional: Key detail or constraint]
   - Spec: [reference to spec file and section]

2. [Next task...]

[Additional priority sections as needed]

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

**Format:**
```markdown
1. [Task description]
   - [Optional implementation details]
   - Spec: specs/file-name.md - "Section Name"
```

**Examples:**

✅ **Good - Clear spec reference:**
```markdown
1. Implement user registration endpoint
   - POST /api/users with validation
   - Hash passwords with bcrypt
   - Spec: specs/user-management.md - "Registration"
```

✅ **Good - Multiple related tasks from same spec:**
```markdown
1. Add output filter script
   - Create .ralph/lib/filter-output.sh
   - Parse JSON-formatted agent output
   - Spec: specs/agent-output-filtering.md - "Filter Script"

2. Integrate filter into loop.sh
   - Pipe agent output through filter
   - Preserve raw logs for debugging
   - Spec: specs/agent-output-filtering.md - "Integration"
```

✅ **Good - Task without spec (internal refactoring):**
```markdown
1. Refactor database connection pooling
   - Extract connection logic to separate module
   - Add connection retry logic
   - (No spec - internal improvement)
```

❌ **Missing spec reference:**
```markdown
1. Implement user registration endpoint
   - POST /api/users with validation
```
*Why bad: No way to verify requirements or find implementation details*

❌ **Vague spec reference:**
```markdown
1. Implement user registration endpoint
   - Spec: user-management.md
```
*Why bad: Missing section name - which part of the spec?*

❌ **Wrong format:**
```markdown
1. Implement user registration endpoint (see specs/user-management.md section 3.2)
```
*Why bad: Not following standard format - harder to parse*

**When to omit spec reference:**
- Internal refactoring not driven by a spec
- Bug fixes discovered during implementation
- Tooling or infrastructure improvements
- In these cases, add a note explaining the reason

### Multi-Phase Projects

For large refactors or system changes:

```markdown
## Remaining Tasks

### Phase 1 - Foundation
1. [Core infrastructure task]
2. [Core infrastructure task]

### Phase 2 - Implementation
3. [Feature task]
4. [Feature task]

### Phase 3 - Integration & Testing
5. [Integration task]
6. [Testing task]
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

### High Priority - Core Infrastructure

1. Create user database schema and model
   - Add users table migration with fields per spec section 2.1
   - Create User model with validation
   - Spec: specs/user-management.md - "Database Schema"

2. Implement user registration endpoint
   - POST /api/users with email, password, name
   - Hash passwords with bcrypt
   - Validation: email format, password min 8 chars
   - Spec: specs/user-management.md - "Registration"

### Medium Priority - Authentication

3. Implement JWT authentication
   - POST /api/auth/login endpoint
   - Generate JWT tokens with 24hr expiry
   - Create auth middleware for protected routes
   - Spec: specs/user-management.md - "Authentication"

4. Add user profile endpoints
   - GET /api/users/:id (authenticated)
   - PUT /api/users/:id (authenticated, own profile only)
   - Spec: specs/user-management.md - "User Profile"

### Testing & Documentation

5. Add integration tests for all endpoints
   - Test registration success and validation errors
   - Test login success and failure cases
   - Test profile access controls
   - All tests must pass before completion

6. Update specs/README.md to mark spec as Implemented

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

## Tasks

1. Set up user stuff
2. Do authentication
3. Fix any bugs
4. Make it work better
5. Add tests maybe
6. Research best practices for security
7. TODO: Figure out database structure
8. Consider using JWT or sessions
```

**Why this is poor:**
- Vague task descriptions ("user stuff", "make it work better")
- No spec references
- Open-ended tasks ("fix any bugs")
- Research as a task (should be done during planning)
- Indecisive ("consider using")
- No structure or priorities
- No success criteria

---

## Final Checklist

Before committing your new IMPLEMENTATION_PLAN.md:

- [ ] Format follows the template (Overview, Tasks, Notes)
- [ ] Each task is action-oriented and specific
- [ ] Tasks reference spec file and section
- [ ] Task granularity is appropriate (completable in one iteration)
- [ ] Prioritization follows the criteria (prerequisites first, etc.)
- [ ] Dependencies are documented in Notes
- [ ] Success criteria are clear
- [ ] You searched the codebase to verify what's actually implemented
- [ ] No vague, open-ended, or research tasks
- [ ] Plan is between 5-20 tasks (adjust for project complexity)

---

**Remember:** A good implementation plan is a roadmap that any agent can follow in future iterations. Be specific, be decisive, and be thorough.
