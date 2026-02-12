# Documentation Update Guide

**This guide provides detailed instructions for updating Ralph documentation files after completing tasks.**

---

## Overview

Ralph uses three main documentation files to track project state:

1. **IMPLEMENTATION_PLAN.md** - Remaining tasks (forward-looking)
2. **PROGRESS.md** - Completed tasks (historical record)
3. **specs/README.md** - Specification status (feature-level tracking)

Update these files every iteration to maintain accurate project state for future iterations.

---

## 1. Update IMPLEMENTATION_PLAN.md

**When:** After completing your task, before committing

**What to do:**

### Remove Completed Task
- Find the task you just completed in the Remaining Tasks section
- Remove it entirely from the file

### Add Discovered Tasks
If you discovered new work during implementation:
```markdown
## Remaining Tasks

1. [Next existing task...]

2. [NEWLY DISCOVERED] Fix validation bug in user input
   - Found during testing of login endpoint
   - Missing email format validation
   - Spec: specs/user-management.md - "Input Validation"
```

### Update Priorities
If priorities changed based on your work:
- Reorder tasks if dependencies became clear
- Add `[HIGH PRIORITY]` or `[BLOCKED]` markers as needed
- Update Notes section with new information

### Add Notes About Blockers
If you encountered blockers:
```markdown
## Notes

### Blocked Items
- Task 5 [BLOCKED]: Cannot implement email sending without SMTP credentials
  - Requires: Environment variable SMTP_HOST to be configured
  - Human intervention needed
```

---

## 2. Update PROGRESS.md

**When:** After completing your task, before committing

**What to do:**

### Add Completed Task Entry

Use this format:
```markdown
### YYYY-MM-DD
- [x] Task description from IMPLEMENTATION_PLAN.md
  - Commit: <hash> (you'll update this after committing)
  - Implementation notes: [brief summary of what you did]
  - Tests: [test status - "all passing", "3 new tests added", etc.]
  - [Any other relevant details]
```

### Keep Reverse Chronological Order
- **Newest entries at the top**
- Group by date
- Multiple tasks completed on same date go under same date header

### Be Specific in Notes
Good notes capture the "why" and important details:

✅ **Good:**
```markdown
- [x] Implement user registration endpoint
  - Commit: abc1234
  - Implementation notes: Added POST /api/users with email, password, name fields. Using bcrypt for password hashing with salt rounds=10. Email validation uses regex from spec.
  - Tests: Added 5 integration tests covering success case, duplicate email, invalid email format, weak password, and missing fields. All passing.
  - Database: Created users table migration (migration_001.sql)
```

❌ **Poor:**
```markdown
- [x] Add registration
  - Commit: abc1234
  - Done
```

### Update Commit Hash After Committing
1. Add entry to PROGRESS.md with placeholder: `Commit: <pending>`
2. Commit all changes
3. Get commit hash: `git rev-parse --short HEAD`
4. Update PROGRESS.md with actual hash
5. Amend commit or make a small follow-up commit

**Alternative approach:** Add to PROGRESS.md with commit hash from previous commit, then this iteration's hash will be in the next entry.

### Example PROGRESS.md:

```markdown
# Progress Log

## Completed Tasks

### 2026-02-12
- [x] Implement JWT authentication
  - Commit: def5678
  - Implementation notes: Added POST /api/auth/login endpoint. JWT tokens generated with jsonwebtoken library, 24hr expiry, signed with SECRET_KEY from env. Created auth middleware that validates token and attaches user to req.user.
  - Tests: 4 new integration tests - successful login, invalid credentials, expired token, missing token. All passing.
  - Security: Passwords never logged, tokens stored in httpOnly cookies

- [x] Create user database schema and model
  - Commit: abc1234
  - Implementation notes: Created users table migration with id, email (unique), password_hash, name, created_at, updated_at. User model includes validation methods and password comparison using bcrypt.
  - Tests: 3 unit tests for model validation. All passing.

### 2026-02-11
- [x] Set up database connection pooling
  - Commit: xyz9876
  - Implementation notes: Configured PostgreSQL connection pool with max 20 connections, idle timeout 30s. Connection string from DATABASE_URL env var.
  - Tests: Connection pool test added, verified max connections respected
```

---

## 3. Update specs/README.md

**When:** ONLY when ALL tasks for a specific spec are fully implemented

**What to check:**

1. ✅ All requirements from the spec are implemented
2. ✅ All tests for the spec are passing
3. ✅ No remaining tasks in IMPLEMENTATION_PLAN.md reference this spec
4. ✅ Documentation for the feature is complete

**What to do:**

Update the spec's status from "Planned" or "In Progress" to "Implemented":

```markdown
## Active Specifications

### Core System
- [x] **ralph-system-implementation.md** - Core Ralph loop and build mode
  - Status: Implemented (2026-02-10)
  - All features complete and tested

- [x] **docker-configuration.md** - Docker development environment
  - Status: Implemented (2026-02-11)
  - Container working, all environment variables configured

### In Progress
- [ ] **user-management.md** - User authentication and profiles
  - Status: In Progress
  - Completed: Registration, authentication
  - Remaining: Profile endpoints, password reset
```

**Don't mark as Implemented if:**
- Only some features from the spec are done
- Tests are failing
- Known bugs exist for the feature
- Documentation is incomplete

**Do mark as Implemented when:**
- Every requirement from the spec works as specified
- All relevant tests pass
- Feature is production-ready (or as ready as spec requires)

---

## 4. Capture the Why

**When authoring any documentation**, focus on capturing context that helps future agents (or humans) understand your decisions.

### In PROGRESS.md
Explain implementation choices:
```markdown
- [x] Refactor database queries to use connection pooling
  - Commit: abc1234
  - Implementation notes: Switched from per-request connections to pool of 20. This fixes the "too many connections" error we were hitting at 50 concurrent users. Pool reuses connections and handles timeouts gracefully.
  - Why pooling: Previous approach opened new connection for each request, causing PostgreSQL to hit max_connections limit. Pooling maintains persistent connections and dramatically reduces connection overhead.
  - Tests: Load test with 100 concurrent requests passes (was failing before)
```

### In IMPLEMENTATION_PLAN.md Notes
Document important context:
```markdown
## Notes

### Why JWT Over Sessions
- Spec requires stateless authentication for microservices architecture
- JWTs allow auth to work across multiple service instances
- No need for shared session store (Redis, etc.)
- Trade-off: Can't revoke tokens before expiry (mitigated by short 24hr lifetime)
```

### In Code Comments (sparingly)
Only when code is complex and needs context:
```javascript
// Using bcrypt rounds=10 per OWASP recommendations (2026)
// Higher rounds (12+) caused unacceptable login delays in testing
const hash = await bcrypt.hash(password, 10);
```

---

## Common Patterns

### Multi-Task Completion

If you completed multiple small related tasks in one iteration:

```markdown
### 2026-02-12
- [x] Update all path references for .ralph/ migration
  - Commit: abc1234
  - Implementation notes: Updated 15 files:
    * loop.sh: IMPLEMENTATION_PLAN.md → .ralph/IMPLEMENTATION_PLAN.md
    * PROMPT_build.md: All references updated
    * ralph script: Updated path to loop.sh
    * All documentation: Updated path examples
  - Tests: Ran loop.sh with new paths, all working correctly
  - Breaking change: Old paths no longer work
```

### Feature with Testing Task

Keep implementation and testing together:

```markdown
- [x] Implement user registration endpoint with full test coverage
  - Commit: abc1234
  - Implementation notes: Added POST /api/users endpoint with email, password, name validation
  - Tests: 5 integration tests covering all edge cases - all passing
  - Code coverage: 100% for src/routes/users.js
```

### Bug Fix During Feature Work

Document both the feature and the bug:

```markdown
- [x] Add profile endpoints and fix authentication middleware bug
  - Commit: abc1234
  - Implementation notes: Added GET/PUT /api/users/:id endpoints. Fixed bug in auth middleware where expired tokens were not properly rejected (was checking wrong claim).
  - Tests: 6 new tests for profile endpoints, 2 new tests for expired token handling. All passing.
  - Bug impact: Security issue - expired tokens were being accepted. Now fixed and tested.
```

---

## Validation Checklist

Before committing, verify your documentation updates:

- [ ] Completed task removed from IMPLEMENTATION_PLAN.md
- [ ] Any new tasks discovered added to IMPLEMENTATION_PLAN.md
- [ ] Entry added to PROGRESS.md with current date
- [ ] PROGRESS.md entry includes commit hash (or placeholder)
- [ ] PROGRESS.md entry explains what was done and why
- [ ] Test status documented in PROGRESS.md
- [ ] If spec is fully complete, specs/README.md updated
- [ ] Important decisions and context captured
- [ ] Files are in correct format (markdown, proper sections)

---

## Anti-Patterns to Avoid

❌ **Forgetting to update PROGRESS.md**
- Future iterations have no record of what was done

❌ **Vague PROGRESS.md entries**
```markdown
- [x] Fixed stuff
  - Commit: abc1234
```
This tells future agents nothing useful.

❌ **Not removing completed tasks from IMPLEMENTATION_PLAN.md**
- Causes confusion about what's done vs. remaining

❌ **Marking specs as Implemented prematurely**
- Misleads future iterations about project state

❌ **Missing commit hashes in PROGRESS.md**
- Can't trace back to actual changes in git history

❌ **Not documenting discovered issues**
- Problems get lost and won't be fixed

---

## Remember

Documentation is how you communicate with future iterations of Ralph. Since each iteration starts with fresh context:

- **Be specific** - Future agents don't remember what you did
- **Be complete** - Include all relevant details
- **Be honest** - Document problems and blockers
- **Be helpful** - Explain the "why" behind decisions

Good documentation = Smooth future iterations
Poor documentation = Wasted time re-discovering context

