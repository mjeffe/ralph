# Docker Configuration Fix Specification

**Date:** 2026-01-31  
**Version:** 1.0  
**Status:** Approved

---

## Executive Summary

This specification addresses two critical issues in the Docker configuration that prevent proper Cline authentication and may cause permission problems for the `ralph` user.

---

## Problems Identified

### Problem 1: Environment File Path Mismatch

**Current State:**
- The `.env` file is mounted to `/app/.env` via docker-compose volume mount (`. :/app`)
- The startup script in Dockerfile looks for `.env` at `/home/ralph/.env`
- Result: Environment variables (PROVIDER, APIKEY, MODEL) are never loaded
- Consequence: Cline authentication fails silently

**Evidence:**
```dockerfile
# In Dockerfile - startup script looks here:
if [ -f "/home/ralph/.env" ]; then
  echo "Loading environment variables from /home/ralph/.env"
  export $(grep -v "^#" /home/ralph/.env | xargs)
fi

# But docker-compose.yml mounts the code here:
volumes:
  - .:/app
```

### Problem 2: Directory Permissions and Inconsistent WORKDIR

**Current State:**
- The `ralph` user is created but `/app` directory ownership is never explicitly set
- Dockerfile switches WORKDIR between `/app` and `/home/ralph` inconsistently
- Final WORKDIR is set to `/home/ralph`, but actual code lives at `/app`
- Result: Confusion about working directory and potential permission issues

**Evidence:**
```dockerfile
WORKDIR /app
USER ralph
WORKDIR /home/ralph  # <- Working from home, but code is at /app
```

---

## Solution Design

### Approach

Work from the `/app` directory where the code is actually mounted, and ensure the `ralph` user has proper ownership and permissions.

### Key Principles

1. **Single Source of Truth:** Code lives at `/app`, work from `/app`
2. **Explicit Permissions:** Set ownership explicitly, don't rely on defaults
3. **Simple Authentication:** Startup script only handles cline auth, user runs cline manually

---

## Implementation Specification

### Change 1: Set Proper Permissions for /app Directory

**Location:** Dockerfile, before `USER ralph` line

**Add:**
```dockerfile
# Ensure /app directory exists with correct permissions
RUN mkdir -p /app && chown -R ralph:ralph /app
```

**Rationale:**
- Creates `/app` if it doesn't exist
- Sets `ralph` as owner and group
- Recursive to handle any subdirectories
- Must be done as root (before USER ralph)

### Change 2: Update Startup Script to Use /app/.env

**Location:** Dockerfile, startup script creation section

**Change FROM:**
```bash
if [ -f "/home/ralph/.env" ]; then
  echo "Loading environment variables from /home/ralph/.env"
  export $(grep -v "^#" /home/ralph/.env | xargs)
fi
```

**Change TO:**
```bash
if [ -f "/app/.env" ]; then
  echo "Loading environment variables from /app/.env"
  export $(grep -v "^#" /app/.env | xargs)
fi
```

**Rationale:**
- Aligns with actual mount point from docker-compose.yml
- `.env` file will be found and loaded correctly

### Change 3: Set Final WORKDIR to /app

**Location:** Dockerfile, after `USER ralph` line

**Change FROM:**
```dockerfile
USER ralph
WORKDIR /home/ralph
```

**Change TO:**
```dockerfile
USER ralph
WORKDIR /app
```

**Rationale:**
- Consistent with where code is mounted
- When user execs into container, they start at `/app`
- Reduces confusion and extra `cd` commands

### Change 4: Clarify Startup Script Purpose

**Location:** Dockerfile, startup script

**Current behavior:** Script runs cline auth then starts bash

**Desired behavior:** Script only runs cline auth, then exits

**Rationale:**
- User confirmed they want to run cline manually after authentication
- Cleaner separation of concerns
- Container stays running via docker-compose's `tail -f /dev/null`

**Note:** The CMD in docker-compose.yml already uses `tail -f /dev/null`, so the startup script can be simplified or the CMD can be updated to run startup script then tail.

---

## Complete Modified Dockerfile

```dockerfile
FROM ubuntu:latest

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Update package list and install required packages
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gnupg \
    nodejs \
    python3 \
    git \
    jq \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js using NodeSource repository for latest version
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs

# Install Python pip
RUN apt-get update && apt-get install -y \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install cline CLI using npm (RUN THIS AS ROOT BEFORE SWITCHING USERS)
RUN npm install -g cline

# Create a non-root user for better security
RUN useradd -m -s /bin/bash ralph

# Grant sudo privileges without password
RUN echo "ralph ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Ensure /app directory exists with correct permissions
RUN mkdir -p /app && chown -R ralph:ralph /app

# Switch to the non-root user and set working directory to /app
USER ralph
WORKDIR /app

# Create startup script for automatic cline configuration
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# Check if .env file exists at /app\n\
if [ -f "/app/.env" ]; then\n\
  echo "Loading environment variables from /app/.env"\n\
  export $(grep -v "^#" /app/.env | xargs)\n\
fi\n\
\n\
# Configure cline automatically if environment variables are set\n\
if [ -n "$PROVIDER" ] && [ -n "$APIKEY" ] && [ -n "$MODEL" ]; then\n\
  echo "Configuring cline with environment variables..."\n\
  cline auth --provider "$PROVIDER" --apikey "$APIKEY" --model "$MODEL"\n\
  echo "Cline authentication complete. You can now run: cline"\n\
else\n\
  echo "Environment variables not fully configured. Please set PROVIDER, APIKEY, and MODEL in /app/.env"\n\
fi\n\
\n\
# Execute any additional commands passed to the script\n\
exec "$@"\n\
' > /home/ralph/startup.sh && chmod +x /home/ralph/startup.sh

# Default command - run startup script with tail to keep container alive
CMD ["/home/ralph/startup.sh", "tail", "-f", "/dev/null"]
```

---

## Testing & Verification

### Pre-Implementation Checklist

- [ ] Backup current Dockerfile
- [ ] Ensure `.env` file exists in project root with correct values:
  ```
  PROVIDER=openrouter
  APIKEY=your_actual_api_key
  MODEL=qwen/qwen3-coder-30b-a3b-instruct
  ```

### Build and Test Steps

1. **Rebuild the Docker image:**
   ```bash
   docker-compose down
   docker-compose build --no-cache
   ```

2. **Start the container:**
   ```bash
   docker-compose up -d
   ```

3. **Check container logs for authentication messages:**
   ```bash
   docker-compose logs
   ```

   **Expected output:**
   ```
   Loading environment variables from /app/.env
   Configuring cline with environment variables...
   Cline authentication complete. You can now run: cline
   ```

4. **Verify working directory:**
   ```bash
   docker-compose exec ubuntu-dev pwd
   ```

   **Expected output:** `/app`

5. **Verify permissions on /app:**
   ```bash
   docker-compose exec ubuntu-dev ls -la / | grep app
   ```

   **Expected output:** 
   ```
   drwxr-xr-x  ... ralph ralph ... app
   ```

6. **Test cline authentication:**
   ```bash
   docker-compose exec ubuntu-dev cline config show
   ```

   **Expected:** Should show configured provider, model (API key will be hidden)

7. **Test file access:**
   ```bash
   docker-compose exec ubuntu-dev touch /app/test-file.txt
   docker-compose exec ubuntu-dev ls -l /app/test-file.txt
   ```

   **Expected:** File created successfully as `ralph` user

8. **Manually run cline:**
   ```bash
   docker-compose exec ubuntu-dev cline
   ```

   **Expected:** Cline should start successfully without authentication errors

### Verification Checklist

- [ ] Container builds without errors
- [ ] Container starts successfully
- [ ] Startup script finds `.env` at `/app/.env`
- [ ] Environment variables are loaded correctly
- [ ] Cline authentication completes successfully
- [ ] Working directory is `/app` when entering container
- [ ] Ralph user owns `/app` directory
- [ ] Ralph user can read/write files in `/app`
- [ ] Cline runs without authentication errors

---

## Rollback Plan

If issues occur:

1. **Restore original Dockerfile** from git or backup
2. **Rebuild:** `docker-compose build --no-cache`
3. **Restart:** `docker-compose up -d`

---

## Success Criteria

1. ✅ Cline authentication succeeds automatically on container startup
2. ✅ User can exec into container and run `cline` without re-authenticating
3. ✅ Working directory is `/app` with proper permissions
4. ✅ Ralph user can create/modify files in `/app`
5. ✅ No permission denied errors when working with files

---

## Notes and Considerations

### Why Not Copy .env to /home/ralph?

Considered but rejected because:
- Adds complexity (copying files)
- Creates two sources of truth
- Harder to maintain
- Working from `/app` is more intuitive

### Startup Script Location

The startup script is created at `/home/ralph/startup.sh` rather than `/app/startup.sh` because:
- It's created before the volume mount happens
- It's a system configuration file, not application code
- Keeps it separate from user's code files

### Environment Variable Parsing

Current implementation uses:
```bash
export $(grep -v "^#" /app/.env | xargs)
```

**Limitation:** Breaks on multiline values or values with spaces

**Better alternatives** (if needed in future):
- Use `source /app/.env` (simpler)
- Use proper .env parser tool
- Use docker-compose env_file directly (already configured)

---

## Related Documentation

- `DOCKER_USAGE.md` - General Docker usage guide
- `.env.example` - Template for environment variables
- `docker-compose.yml` - Container orchestration config

---

## Approval

- [x] Technical approach reviewed and approved
- [x] Implementation steps documented
- [x] Testing procedures defined
- [ ] Changes implemented (pending)
- [ ] Verification complete (pending)
