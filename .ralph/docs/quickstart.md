# Quick Start Guide

Get up and running with Ralph in minutes.

## Prerequisites

- Git repository initialized
- Cline CLI installed and configured
- Ralph installed (see [installation.md](installation.md))

## Step 1: Initialize Ralph

From your project root:

```bash
.ralph/ralph init
```

This creates:
- `specs/` directory for your specifications
- `specs/README.md` with starter template
- `AGENTS.md` from template (if it doesn't exist)

**Note**: If you already have an `AGENTS.md` file, you'll need to manually add the `## Specifications` section. See [installation.md](installation.md#for-existing-projects-with-agentsmd) for details.

## Step 2: Create Your First Specification

Create a specification file in `specs/`:

```bash
# Create a new spec file
touch specs/my-feature.md
```

Edit `specs/my-feature.md` with your requirements:

```markdown
# My Feature

## Overview

Brief description of what this feature does and why it's needed.

## Requirements

### Functional Requirements

1. **Requirement 1**
   - Description of what needs to be implemented
   - Expected behavior
   - Example: "User can submit a form with name and email"

2. **Requirement 2**
   - Another requirement
   - Include edge cases
   - Example: "Form validates email format before submission"

### Non-Functional Requirements

- Performance: Response time under 200ms
- Security: Input sanitization required
- Accessibility: WCAG 2.1 AA compliance

## Use Cases

### Use Case 1: Happy Path

1. User navigates to form
2. User enters valid data
3. User submits form
4. System displays success message

### Use Case 2: Error Handling

1. User enters invalid email
2. System displays validation error
3. User corrects email
4. Form submits successfully

## Success Criteria

- [ ] All functional requirements implemented
- [ ] All tests passing
- [ ] Documentation updated
- [ ] Code reviewed and merged

## Out of Scope

- Email verification (future enhancement)
- Social login integration (separate spec)
```

**Tips for writing specs:**
- Be specific about requirements
- Include examples and use cases
- Define success criteria clearly
- Specify what's out of scope
- See [writing-specs.md](writing-specs.md) for detailed guidance

## Step 3: Update specs/README.md

Add your new spec to the index:

```markdown
# Specification Index

## Active Specifications

### My Feature (my-feature.md)
- **Status:** Active
- **Priority:** High
- **Last Updated:** 2026-02-12
- **Description:** Brief description of the feature
```

This helps agents understand what specs exist and their status.

## Step 4: Run Ralph

Start the build loop:

```bash
.ralph/ralph
```

Or with a maximum iteration limit:

```bash
.ralph/ralph 10  # Run maximum 10 iterations
```

**What happens:**

1. **First iteration**: Agent reads specs and creates `.ralph/IMPLEMENTATION_PLAN.md`
2. **Subsequent iterations**: Agent implements tasks from the plan
3. **Each iteration**: Agent commits changes and updates progress
4. **Loop exits**: When all tasks complete or max iterations reached

## Step 5: Monitor Progress

### View Logs

Check the latest log file:

```bash
# View most recent log
ls -t .ralph/logs/*.log | head -1 | xargs cat

# Follow log in real-time
ls -t .ralph/logs/*.log | head -1 | xargs tail -f
```

### Check Implementation Plan

See what tasks remain:

```bash
cat .ralph/IMPLEMENTATION_PLAN.md
```

### Check Progress

See what's been completed:

```bash
cat .ralph/PROGRESS.md
```

### Check Git History

See commits made by Ralph:

```bash
git log --oneline --author="ralph"
```

## Step 6: Review and Iterate

After Ralph completes iterations:

1. **Review the code** - Check what was implemented
2. **Run tests** - Verify everything works
3. **Update specs** - Refine requirements if needed
4. **Run again** - Continue with more iterations

## Common Workflows

### Adding a New Feature

```bash
# 1. Create spec
echo "# New Feature" > specs/new-feature.md
# Edit specs/new-feature.md with requirements

# 2. Update spec index
# Edit specs/README.md to add new spec

# 3. Run Ralph
.ralph/ralph
```

### Fixing a Bug

```bash
# 1. Document the bug in a spec
echo "# Bug Fix: Issue Description" > specs/bug-fix-issue-123.md
# Edit with bug details, expected behavior, reproduction steps

# 2. Update spec index
# Edit specs/README.md

# 3. Run Ralph
.ralph/ralph
```

### Refactoring Code

```bash
# 1. Create refactoring spec
echo "# Refactor: Component Name" > specs/refactor-component.md
# Edit with refactoring goals, patterns to follow, success criteria

# 2. Update spec index
# Edit specs/README.md

# 3. Run Ralph
.ralph/ralph
```

## Stopping Ralph

Press `Ctrl-C` at any time to stop the loop gracefully.

**Safe to stop:**
- Between iterations (after commit)
- During agent execution (may leave uncommitted changes)

**After stopping:**
```bash
# Check for uncommitted changes
git status

# Commit manually if needed
git add -A
git commit -m "Manual commit after stopping Ralph"

# Or discard changes
git reset --hard HEAD
```

## Tips for Success

### Write Clear Specifications

- Be specific about requirements
- Include examples and edge cases
- Define success criteria
- Specify what's out of scope

### Start Small

- Begin with simple, well-defined features
- Break large features into smaller specs
- Validate Ralph works before tackling complex tasks

### Monitor Progress

- Check logs regularly
- Review commits after each iteration
- Update specs based on learnings

### Use Validation Hooks

Create `.ralph/validate.sh` to run checks after each iteration:

```bash
#!/bin/bash
# Example validation script

# Run tests
npm test || exit 1

# Run linter
npm run lint || exit 1

# Check types
npm run typecheck || exit 1

echo "✓ All validations passed"
```

Make it executable:

```bash
chmod +x .ralph/validate.sh
```

### Leverage Git

- Review diffs before accepting changes
- Use branches for experimental features
- Rollback if needed: `git reset --hard HEAD~1`

## Next Steps

- **Learn more about writing specs**: [writing-specs.md](writing-specs.md)
- **Troubleshoot issues**: [troubleshooting.md](troubleshooting.md)
- **Understand Ralph internals**: [README.md](README.md)

## Example: Complete Workflow

Here's a complete example from start to finish:

```bash
# 1. Install Ralph (if not already installed)
curl -fsSL https://raw.githubusercontent.com/mjeffe/ralph/main/install.sh | bash

# 2. Initialize
.ralph/ralph init

# 3. Create spec
cat > specs/user-authentication.md << 'EOF'
# User Authentication

## Requirements

1. User can register with email and password
2. User can login with credentials
3. Passwords are hashed with bcrypt
4. JWT tokens issued on successful login
5. Protected routes require valid JWT

## Success Criteria

- [ ] Registration endpoint implemented
- [ ] Login endpoint implemented
- [ ] Password hashing working
- [ ] JWT generation working
- [ ] Auth middleware implemented
- [ ] All tests passing
EOF

# 4. Update spec index
cat > specs/README.md << 'EOF'
# Specification Index

## Active Specifications

### User Authentication (user-authentication.md)
- **Status:** Active
- **Priority:** High
- **Last Updated:** 2026-02-12
EOF

# 5. Run Ralph
.ralph/ralph 5  # Run up to 5 iterations

# 6. Monitor progress
cat .ralph/IMPLEMENTATION_PLAN.md
cat .ralph/PROGRESS.md

# 7. Review changes
git log --oneline -5
git diff HEAD~5

# 8. Test the implementation
npm test
```

## Getting Help

- **Documentation**: Check `.ralph/docs/` for detailed guides
- **Logs**: Review `.ralph/logs/` for execution details
- **Troubleshooting**: See [troubleshooting.md](troubleshooting.md)
- **GitHub**: https://github.com/mjeffe/ralph

## Optional: Create Convenience Symlink

For easier access, create a symlink:

```bash
ln -s .ralph/ralph ralph
```

Now you can run:

```bash
./ralph        # Instead of .ralph/ralph
./ralph 10     # Instead of .ralph/ralph 10
./ralph --help # Instead of .ralph/ralph --help
```
