# Documentation Update Guide

**This guide provides detailed instructions for updating Ralph documentation files after completing tasks.**

---

## Overview

Ralph uses two main documentation files to track project state:

1. **IMPLEMENTATION_PLAN.md** - Remaining tasks (forward-looking)
2. **specs/README.md** - Specification status (feature-level tracking)

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

## 2. Update specs/README.md

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

## 3. Capture the Why

**When authoring any documentation**, focus on capturing context that helps future agents (or humans) understand your decisions.

### In Git Commit Messages
Explain implementation choices:
```
ralph: implement user authentication with JWT

- Added POST /api/auth/login endpoint
- JWT tokens with 24hr expiry, signed with SECRET_KEY
- Created auth middleware for token validation
- Using bcrypt rounds=10 per OWASP recommendations
- All tests passing (4 new integration tests)

Why JWT: Spec requires stateless auth for microservices.
Allows auth across multiple service instances without
shared session store.
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

```
ralph: update all path references for .ralph/ migration

- Updated 15 files with new .ralph/ paths
- loop.sh: IMPLEMENTATION_PLAN.md → .ralph/IMPLEMENTATION_PLAN.md
- PROMPT_build.md: All references updated
- ralph script: Updated path to loop.sh
- All documentation: Updated path examples
- Tests: Ran loop.sh with new paths, all working correctly

Breaking change: Old paths no longer work
```

### Feature with Testing Task

Keep implementation and testing together:

```
ralph: implement user registration endpoint with full test coverage

- Added POST /api/users endpoint
- Email, password, name validation per spec
- 5 integration tests covering all edge cases
- Code coverage: 100% for src/routes/users.js
- All tests passing
```

### Bug Fix During Feature Work

Document both the feature and the bug:

```
ralph: add profile endpoints and fix auth middleware bug

- Added GET/PUT /api/users/:id endpoints
- Fixed security bug: expired tokens were being accepted
- Auth middleware now properly rejects expired tokens
- 6 new tests for profile endpoints
- 2 new tests for expired token handling
- All tests passing

Bug impact: Security issue now fixed and tested
```

---

## Validation Checklist

Before committing, verify your documentation updates:

- [ ] Completed task removed from IMPLEMENTATION_PLAN.md
- [ ] Any new tasks discovered added to IMPLEMENTATION_PLAN.md
- [ ] Git commit message explains what was done and why
- [ ] Test status documented in commit message
- [ ] If spec is fully complete, specs/README.md updated
- [ ] Important decisions and context captured
- [ ] Files are in correct format (markdown, proper sections)

---

## Anti-Patterns to Avoid

❌ **Vague commit messages**
```
ralph: fixed stuff
```
This tells future agents nothing useful.

❌ **Not removing completed tasks from IMPLEMENTATION_PLAN.md**
- Causes confusion about what's done vs. remaining

❌ **Marking specs as Implemented prematurely**
- Misleads future iterations about project state

❌ **Not documenting discovered issues**
- Problems get lost and won't be fixed

❌ **Missing context in commits**
- Can't understand why decisions were made

---

## Remember

Documentation is how you communicate with future iterations of Ralph. Since each iteration starts with fresh context:

- **Be specific** - Future agents don't remember what you did
- **Be complete** - Include all relevant details in commit messages
- **Be honest** - Document problems and blockers
- **Be helpful** - Explain the "why" behind decisions

Good documentation = Smooth future iterations
Poor documentation = Wasted time re-discovering context
