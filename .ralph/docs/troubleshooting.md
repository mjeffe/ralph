# Troubleshooting Guide

Common issues and solutions when using Ralph.

## Installation Issues

### "Not a git repository"

**Problem**: Installation fails with error about not being in a git repository.

**Solution**:
```bash
# Initialize git repository
git init
git add .
git commit -m "Initial commit"

# Retry installation
curl -fsSL https://raw.githubusercontent.com/mjeffe/ralph/main/install.sh | bash
```

### ".ralph/ already exists"

**Problem**: Installation fails because `.ralph/` directory already exists.

**Solution**:
```bash
# Option 1: Backup and reinstall
mv .ralph .ralph.backup
curl -fsSL https://raw.githubusercontent.com/mjeffe/ralph/main/install.sh | bash

# Option 2: Remove and reinstall (loses state)
rm -rf .ralph
curl -fsSL https://raw.githubusercontent.com/mjeffe/ralph/main/install.sh | bash
```

### Permission Denied

**Problem**: Cannot execute `.ralph/ralph` script.

**Solution**:
```bash
chmod +x .ralph/ralph
chmod +x .ralph/loop.sh
```

## Runtime Issues

### Loop Exits Immediately

**Possible Causes**:

#### 1. PROJECT_COMPLETE marker exists

**Check**:
```bash
grep -i "complete" .ralph/IMPLEMENTATION_PLAN.md
```

**Solution**:
Remove the completion marker if work remains:
```bash
# Edit .ralph/IMPLEMENTATION_PLAN.md and remove PROJECT_COMPLETE marker
```

#### 2. Validation script failing

**Check**:
```bash
.ralph/validate.sh
```

**Solution**:
Fix validation failures or temporarily disable:
```bash
chmod -x .ralph/validate.sh  # Disable validation
```

#### 3. No specs found

**Check**:
```bash
ls -la specs/
```

**Solution**:
```bash
# Create specs directory and first spec
mkdir -p specs
echo "# My Feature" > specs/my-feature.md
# Edit specs/my-feature.md with requirements
```

#### 4. Health check failures

**Check logs**:
```bash
ls -t .ralph/logs/*.log | head -1 | xargs cat
```

**Common health check issues**:
- Low disk space: Free up space
- Cline not found: Install cline CLI
- specs/ not readable: Check permissions

### Agent Not Following Specifications

**Problem**: Agent implements features not in specs or ignores requirements.

**Possible Causes**:

#### 1. Missing ## Specifications section in AGENTS.md

**Check**:
```bash
grep "## Specifications" AGENTS.md
```

**Solution**:
Add the required section to AGENTS.md (see [installation.md](installation.md#for-existing-projects-with-agentsmd))

#### 2. Vague specifications

**Solution**:
Make specs more specific:
- Add concrete examples
- Define edge cases
- Include success criteria
- Specify what's out of scope

See [writing-specs.md](writing-specs.md) for guidance.

#### 3. Implementation plan too vague

**Solution**:
Edit `.ralph/IMPLEMENTATION_PLAN.md` to make tasks more specific:

**Bad**:
```markdown
1. Add user authentication
```

**Good**:
```markdown
1. Implement user registration endpoint
   - POST /api/auth/register
   - Validate email format and password strength
   - Hash password with bcrypt
   - Return JWT token
   - See specs/user-authentication.md for details
```

### Tests Keep Failing

**Problem**: Agent implements features but tests fail repeatedly.

**Possible Causes**:

#### 1. Flaky tests

**Solution**:
Fix or remove flaky tests. Tests should be deterministic.

#### 2. Unclear requirements

**Solution**:
Update specs with more examples and edge cases:
```markdown
## Test Cases

### Valid Input
- Input: `{ email: "user@example.com", password: "SecurePass123" }`
- Expected: 201 status, user object returned

### Invalid Email
- Input: `{ email: "invalid", password: "SecurePass123" }`
- Expected: 400 status, error message "Invalid email format"
```

#### 3. Missing test dependencies

**Solution**:
Document test setup in specs:
```markdown
## Testing Requirements

- Test database: Use in-memory SQLite
- Mock external APIs: Use nock or similar
- Test data: Seed with fixtures in tests/fixtures/
```

### Git Push Failures

**Problem**: Loop fails to push commits to remote.

**Possible Causes**:

#### 1. Network issues

**Check**:
```bash
git fetch
```

**Solution**:
Wait for network to recover, then manually push:
```bash
git push origin $(git branch --show-current)
```

#### 2. Authentication issues

**Check**:
```bash
git remote -v
```

**Solution**:
Configure git credentials:
```bash
# For HTTPS
git config credential.helper store

# For SSH
ssh-add ~/.ssh/id_rsa
```

#### 3. Diverged branches

**Check**:
```bash
git status
```

**Solution**:
```bash
# Pull and rebase
git pull --rebase origin $(git branch --show-current)

# Or force push (use with caution)
git push --force origin $(git branch --show-current)
```

### High Costs Per Iteration

**Problem**: Each iteration uses too many tokens/API calls.

**Solutions**:

#### 1. Break down tasks

Edit `.ralph/IMPLEMENTATION_PLAN.md` to split large tasks:

**Bad**:
```markdown
1. Implement entire user management system
```

**Good**:
```markdown
1. Implement user registration endpoint
2. Implement user login endpoint
3. Implement password reset flow
4. Add user profile endpoints
```

#### 2. Add scope boundaries

Update specs to be more focused:
```markdown
## Out of Scope

- Email verification (separate spec)
- Social login (separate spec)
- Two-factor authentication (future enhancement)
```

#### 3. Use validation hooks

Create `.ralph/validate.sh` to catch issues early:
```bash
#!/bin/bash
# Run quick checks before expensive operations

# Type check
npm run typecheck || exit 1

# Lint
npm run lint || exit 1

# Unit tests only (skip slow integration tests)
npm run test:unit || exit 1
```

### Iteration Timeout

**Problem**: Iteration exceeds timeout (default 30 minutes).

**Solutions**:

#### 1. Increase timeout

Set environment variable:
```bash
export RALPH_ITERATION_TIMEOUT=3600  # 60 minutes
.ralph/ralph
```

#### 2. Break down tasks

Split large tasks into smaller ones in `.ralph/IMPLEMENTATION_PLAN.md`.

#### 3. Optimize tests

- Run only relevant tests
- Use test parallelization
- Mock slow external services

## Cline Issues

### Cline Not Found

**Problem**: Error "cline: command not found"

**Solution**:
```bash
# Install cline CLI
npm install -g @cline/cli

# Verify installation
cline --version
```

### Cline Authentication Failed

**Problem**: Cline cannot authenticate with LLM provider.

**Solution**:
```bash
# Reconfigure cline
cline auth

# Follow prompts to enter API key
```

### Cline API Rate Limits

**Problem**: Hitting API rate limits.

**Solutions**:

#### 1. Reduce iteration frequency

Run fewer iterations:
```bash
.ralph/ralph 3  # Only 3 iterations
```

#### 2. Use different model

Configure cline to use a different model with higher limits.

#### 3. Wait and retry

Rate limits typically reset after a period (check your provider's docs).

## Debugging

### Enable Verbose Logging

Check logs for detailed information:
```bash
# View latest log
ls -t .ralph/logs/*.log | head -1 | xargs cat

# Follow log in real-time
ls -t .ralph/logs/*.log | head -1 | xargs tail -f

# Search logs for errors
grep -i error .ralph/logs/*.log
```

### Check Git History

Review what Ralph has done:
```bash
# View recent commits
git log --oneline -10

# View specific commit
git show <commit-hash>

# View diff of last iteration
git diff HEAD~1
```

### Inspect State Files

Check Ralph's understanding:
```bash
# What tasks remain?
cat .ralph/IMPLEMENTATION_PLAN.md

# What's been completed?
cat .ralph/PROGRESS.md

# What specs exist?
cat specs/README.md
```

### Manual Intervention

Sometimes you need to step in:

```bash
# Stop Ralph
# Press Ctrl-C

# Check status
git status

# Review changes
git diff

# Commit manually if needed
git add -A
git commit -m "Manual fix: description"
git push

# Update implementation plan
# Edit .ralph/IMPLEMENTATION_PLAN.md

# Resume Ralph
.ralph/ralph
```

## Recovery Procedures

### Rollback Last Iteration

```bash
# Undo last commit
git reset --hard HEAD~1

# Force push (if already pushed)
git push --force origin $(git branch --show-current)

# Update progress log
# Edit .ralph/PROGRESS.md to remove last entry

# Resume Ralph
.ralph/ralph
```

### Reset to Clean State

```bash
# Backup current state
cp .ralph/IMPLEMENTATION_PLAN.md /tmp/
cp .ralph/PROGRESS.md /tmp/

# Reset to specific commit
git reset --hard <commit-hash>
git push --force origin $(git branch --show-current)

# Restore or recreate state files
cp /tmp/IMPLEMENTATION_PLAN.md .ralph/
cp /tmp/PROGRESS.md .ralph/

# Or regenerate plan
rm .ralph/IMPLEMENTATION_PLAN.md
.ralph/ralph 1  # Creates new plan
```

### Start Fresh

```bash
# Remove Ralph state (keeps specs)
rm .ralph/IMPLEMENTATION_PLAN.md
rm .ralph/PROGRESS.md

# Run Ralph to regenerate plan
.ralph/ralph 1
```

## Performance Issues

### Slow Iteration Times

**Possible Causes**:

#### 1. Large codebase

**Solution**:
- Use `.gitignore` to exclude unnecessary files
- Keep specs focused and specific
- Break project into smaller modules

#### 2. Slow tests

**Solution**:
- Optimize test suite
- Run only relevant tests
- Use test parallelization
- Mock external services

#### 3. Network latency

**Solution**:
- Use local LLM if available
- Check network connection
- Consider different API endpoint/region

### High Memory Usage

**Solution**:
```bash
# Limit concurrent operations
# Edit .ralph/loop.sh if needed

# Clear old logs
rm .ralph/logs/*.log.old

# Restart system if needed
```

## Getting Help

### Check Documentation

- [README.md](README.md) - Ralph overview
- [installation.md](installation.md) - Installation guide
- [quickstart.md](quickstart.md) - Getting started
- [writing-specs.md](writing-specs.md) - Writing specifications

### Review Logs

Logs contain valuable debugging information:
```bash
ls -t .ralph/logs/*.log | head -1 | xargs less
```

### Check GitHub Issues

Search for similar issues:
- https://github.com/mjeffe/ralph/issues

### Report a Bug

If you've found a bug:

1. Check if it's already reported
2. Gather information:
   - Ralph version: `cat .ralph/.ralph-version`
   - Error message from logs
   - Steps to reproduce
3. Create a new issue with details

## Common Error Messages

### "specs/ directory not found"

**Solution**:
```bash
.ralph/ralph init
```

### "IMPLEMENTATION_PLAN.md not found"

**Solution**:
This is normal on first run. Ralph will create it:
```bash
.ralph/ralph 1
```

### "Health check failed: disk space low"

**Solution**:
```bash
# Free up disk space
df -h  # Check usage
# Remove unnecessary files
```

### "Validation failed"

**Solution**:
```bash
# Run validation manually to see details
.ralph/validate.sh

# Fix issues or disable validation
chmod -x .ralph/validate.sh
```

### "Git push failed after 3 attempts"

**Solution**:
```bash
# Check network
ping github.com

# Check git remote
git remote -v

# Push manually
git push origin $(git branch --show-current)
```

## Prevention

### Best Practices

1. **Start small** - Test Ralph with simple specs first
2. **Monitor progress** - Check logs and commits regularly
3. **Keep specs updated** - Refine requirements as you learn
4. **Use validation** - Catch issues early with `.ralph/validate.sh`
5. **Backup state** - Commit state files regularly
6. **Review changes** - Don't blindly accept all commits

### Regular Maintenance

```bash
# Clean old logs (keep last 10)
ls -t .ralph/logs/*.log | tail -n +11 | xargs rm -f

# Review and update specs
# Edit specs/*.md as needed

# Update spec index
# Edit specs/README.md

# Commit state files
git add .ralph/IMPLEMENTATION_PLAN.md .ralph/PROGRESS.md
git commit -m "Update Ralph state"
```
