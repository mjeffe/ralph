#!/bin/bash
# Ralph Wiggum Loop - Core Loop Implementation
# 
# Usage:
#   ./loop.sh              # Build mode, unlimited iterations
#   ./loop.sh 20           # Build mode, max 20 iterations

set -e

# Configuration
ITERATION_TIMEOUT=${RALPH_ITERATION_TIMEOUT:-1800}  # 30 minutes default
AGENT_COMMAND=${RALPH_AGENT:-cline}
MIN_DISK_SPACE_MB=1024  # 1GB minimum
ENABLE_JSON_OUTPUT=${RALPH_JSON_OUTPUT:-true}  # Enable JSON output for metrics parsing

# Flag for interrupt handling
INTERRUPT_RECEIVED=false

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
error() {
    echo -e "${RED}Error: $1${NC}" >&2
}

fatal() {
    echo -e "${RED}FATAL: $1${NC}" >&2
    exit 1
}

warn() {
    echo -e "${YELLOW}Warning: $1${NC}" >&2
}

info() {
    echo -e "${GREEN}$1${NC}"
}

debug() {
    echo -e "${BLUE}$1${NC}"
}

# Cleanup function for handling interrupts
cleanup() {
    echo ""
    error "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    error "Ctrl-C received - Aborting execution"
    error "Interrupted at iteration: $ITERATION"
    error "Time: $(date '+%Y-%m-%d %H:%M:%S')"
    error "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Additional cleanup tasks can be added here as needed
    # Examples: cleaning up temporary files, saving state, etc.
    
    exit 130  # Standard exit code for SIGINT
}

# Trap signals - set flag instead of calling cleanup directly
# This allows the current iteration to complete before exiting
trap 'INTERRUPT_RECEIVED=true' SIGINT SIGTERM

# Health check functions
check_disk_space() {
    local available_mb=$(df -m . | awk 'NR==2 {print $4}')
    if [ "$available_mb" -lt "$MIN_DISK_SPACE_MB" ]; then
        return 1
    fi
    return 0
}

check_git_repo() {
    git rev-parse --git-dir > /dev/null 2>&1
    return $?
}

check_specs_readable() {
    [ -d "specs" ] && [ -r "specs" ]
    return $?
}

check_agent_available() {
    command -v "$AGENT_COMMAND" > /dev/null 2>&1
    return $?
}

check_health() {
    local health_ok=true
    
    if ! check_disk_space; then
        warn "Low disk space (< ${MIN_DISK_SPACE_MB}MB available)"
        health_ok=false
    fi
    
    if ! check_git_repo; then
        fatal "Not a git repository"
    fi
    
    if ! check_specs_readable; then
        fatal "Cannot read specs/ directory"
    fi
    
    if ! check_agent_available; then
        fatal "Agent binary '$AGENT_COMMAND' not found"
    fi
    
    return 0
}

# Git push with retry logic
push_with_retry() {
    local max_attempts=3
    local attempt=1
    local current_branch=$(git branch --show-current)
    
    while [ $attempt -le $max_attempts ]; do
        if git push origin "$current_branch" 2>&1; then
            info "✓ Push successful"
            return 0
        fi
        
        if [ $attempt -lt $max_attempts ]; then
            warn "Push failed (attempt $attempt/$max_attempts), retrying in 5s..."
            sleep 5
        fi
        attempt=$((attempt + 1))
    done
    
    fatal "Git push failed after $max_attempts attempts"
}

# Clean up old log files based on retention policy
# Policy: Keep at least 30 days OR 30 files, whichever is greater
cleanup_logs() {
    local log_dir=".ralph/logs"
    
    # Check if log directory exists
    if [ ! -d "$log_dir" ]; then
        return 0
    fi
    
    # Get all .log files sorted by modification time (oldest first)
    local log_files=()
    while IFS= read -r -d '' file; do
        log_files+=("$file")
    done < <(find "$log_dir" -name "*.log" -type f -print0 | xargs -0 ls -t -r 2>/dev/null)
    
    # If we have 30 or fewer files, keep all
    local file_count=${#log_files[@]}
    if [ $file_count -le 30 ]; then
        return 0
    fi
    
    # Calculate cutoff timestamp (30 days ago)
    local cutoff_timestamp=$(date -d "30 days ago" +%s 2>/dev/null || date -v-30d +%s 2>/dev/null)
    
    # Build list of files to protect
    local protected_files=()
    
    # Protect files newer than 30 days
    for file in "${log_files[@]}"; do
        local file_mtime=$(stat -c %Y "$file" 2>/dev/null || stat -f %m "$file" 2>/dev/null)
        if [ "$file_mtime" -ge "$cutoff_timestamp" ]; then
            protected_files+=("$file")
        fi
    done
    
    # Protect most recent 30 files (reverse order = newest first)
    local recent_files=()
    for ((i=${#log_files[@]}-1; i>=0 && ${#recent_files[@]}<30; i--)); do
        recent_files+=("${log_files[$i]}")
    done
    
    # Merge protected sets (use associative array to deduplicate)
    declare -A protected_set
    for file in "${protected_files[@]}" "${recent_files[@]}"; do
        protected_set["$file"]=1
    done
    
    # Delete files not in protected set
    local deleted_count=0
    for file in "${log_files[@]}"; do
        if [ -z "${protected_set[$file]}" ]; then
            rm -f "$file"
            deleted_count=$((deleted_count + 1))
        fi
    done
    
    if [ $deleted_count -gt 0 ]; then
        debug "Cleaned up $deleted_count old log file(s)"
    fi
}

# Create log file with timestamp (called once per invocation)
create_log_file() {
    local date_stamp=$(date +%Y-%m-%d)
    local log_dir=".ralph/logs"
    
    # Ensure log directory exists
    mkdir -p "$log_dir"
    
    # Find next available log number for today
    local log_num=1
    while [ -f "$log_dir/${date_stamp}_$(printf '%03d' $log_num).log" ]; do
        log_num=$((log_num + 1))
    done
    
    echo "$log_dir/${date_stamp}_$(printf '%03d' $log_num).log"
}

# Check for PROJECT_COMPLETE lock file
check_project_complete() {
    [ -f ".ralph/PROJECT_COMPLETE" ]
}

# Extract current task and spec from IMPLEMENTATION_PLAN.md
extract_current_task() {
    local plan_file=".ralph/IMPLEMENTATION_PLAN.md"
    
    # Check if plan file exists
    if [ ! -f "$plan_file" ]; then
        echo "TASK=(no plan file)"
        echo "SPEC=(not specified)"
        return
    fi
    
    # Extract section between "## Remaining Tasks" and next "##" header
    local remaining_section=$(sed -n '/## Remaining Tasks/,/^## /p' "$plan_file" | sed '$d')
    
    # Find first numbered task (format: "1. Task description")
    local task_line=$(echo "$remaining_section" | grep -m 1 '^[0-9]\+\.')
    
    if [ -z "$task_line" ]; then
        echo "TASK=(no remaining tasks)"
        echo "SPEC=(not specified)"
        return
    fi
    
    # Extract task description (text after number and period)
    local task_desc=$(echo "$task_line" | sed 's/^[0-9]\+\.\s*//')
    
    # Look for "Spec:" line in the lines following this task (before next numbered item)
    local spec_line=$(echo "$remaining_section" | sed -n "/^[0-9]\+\. /,/^[0-9]\+\. /p" | grep -m 1 'Spec:' | head -1)
    
    # Extract spec filename (format: "specs/filename.md")
    local spec_file=""
    if [ -n "$spec_line" ]; then
        spec_file=$(echo "$spec_line" | sed -n 's/.*specs\/\([^ ]*\.md\).*/\1/p')
    fi
    
    # Output
    echo "TASK=${task_desc}"
    if [ -n "$spec_file" ]; then
        echo "SPEC=${spec_file}"
    else
        echo "SPEC=(not specified)"
    fi
}

# Parse metrics from agent JSON output and embed in log
parse_metrics() {
    local log_file="$1"
    local iteration="$2"
    local duration="$3"
    local commit_hash="$4"
    local exit_code="$5"
    
    # Check if jq is available for JSON parsing
    if ! command -v jq > /dev/null 2>&1; then
        return 0
    fi
    
    # Extract metrics from JSON output
    # Look for api_req_started and completion_result messages
    local api_requests=0
    local model_info=""
    local total_messages=0
    
    # Count API requests and extract model information
    api_requests=$(grep -c '"say":"api_req_started"' "$log_file" 2>/dev/null || echo "0")
    total_messages=$(grep -c '"type":"say"' "$log_file" 2>/dev/null || echo "0")
    
    # Extract model info from first message (if available)
    model_info=$(grep -m 1 '"modelInfo"' "$log_file" 2>/dev/null | \
        jq -r '.modelInfo | "\(.providerId)/\(.modelId)"' 2>/dev/null || echo "unknown")
    
    # Append metrics summary to log file (no separate .metrics file)
    {
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Iteration $iteration Metrics"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "API Requests: $api_requests"
        echo "Total Messages: $total_messages"
        echo "Model: $model_info"
        echo "Duration: $duration"
        echo "Commit: $commit_hash"
        echo "Exit Code: $exit_code"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    } >> "$log_file"
}

# Run optional validation hook
run_validation() {
    if [ -x ".ralph/validate.sh" ]; then
        info "Running project validation..."
        if .ralph/validate.sh; then
            info "✓ Validation passed"
            return 0
        else
            fatal "Validation failed"
        fi
    fi
    return 0
}

# Parse arguments
MAX_ITERATIONS=0

if [[ "$1" =~ ^[0-9]+$ ]]; then
    MAX_ITERATIONS=$1
fi

# Set prompt file
PROMPT_FILE="$(dirname "$0")/prompts/PROMPT_build.md"

# Verify prompt file exists
if [ ! -f "$PROMPT_FILE" ]; then
    fatal "Prompt file not found: $PROMPT_FILE"
fi

# Display startup information
CURRENT_BRANCH=$(git branch --show-current)
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Ralph Wiggum Loop - Core"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Prompt: $PROMPT_FILE"
echo "Branch: $CURRENT_BRANCH"
echo "Agent:  $AGENT_COMMAND"
[ $MAX_ITERATIONS -gt 0 ] && echo "Max:    $MAX_ITERATIONS iterations"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Clean up old logs before creating new log file
cleanup_logs

# Create log file once at startup (before main loop)
LOG_FILE=$(create_log_file)
info "Logging to: $LOG_FILE"
echo ""

# Main loop
ITERATION=0

while true; do
    # Check if interrupt was received
    if [ "$INTERRUPT_RECEIVED" = true ]; then
        cleanup
    fi
    
    # Check max iterations
    if [ $MAX_ITERATIONS -gt 0 ] && [ $ITERATION -ge $MAX_ITERATIONS ]; then
        info "Reached max iterations: $MAX_ITERATIONS"
        break
    fi
    
    # Check for project completion
    if check_project_complete; then
        info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        info "PROJECT COMPLETE! All tasks finished."
        info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        break
    fi
    
    # Run health checks
    debug "Running health checks..."
    check_health
    
    ITERATION=$((ITERATION + 1))
    
    # Extract current task and spec
    eval "$(extract_current_task)"
    
    # Log iteration header with task/spec context
    {
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Iteration: $ITERATION"
        echo "Task: $TASK"
        echo "Spec: $SPEC"
        echo "Branch: $CURRENT_BRANCH"
        echo "Started: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
    } | tee -a "$LOG_FILE"
    
    info "Starting iteration $ITERATION..."
    info "Task: $TASK"
    info "Spec: $SPEC"
    
    # Record start time
    START_TIME=$(date +%s)
    
    # Run agent with timeout
    AGENT_EXIT_CODE=0
    
    # Build mode: autonomous with timeout and logging
    # Determine agent flags based on configuration
    AGENT_FLAGS="--yolo"
    if [ "$ENABLE_JSON_OUTPUT" = "true" ]; then
        AGENT_FLAGS="$AGENT_FLAGS --json"
    else
        AGENT_FLAGS="$AGENT_FLAGS --verbose"
    fi
    
    # Run agent with output filtering
    # - Full output goes to log file via tee
    # - Terminal gets filtered output for readability
    # - Filter only applies when JSON output is enabled
    if [ "$ENABLE_JSON_OUTPUT" = "true" ]; then
        timeout ${ITERATION_TIMEOUT}s bash -c "cat '$PROMPT_FILE' | $AGENT_COMMAND $AGENT_FLAGS" 2>&1 | tee -a "$LOG_FILE" | "$(dirname "$0")/lib/filter-output.sh" || AGENT_EXIT_CODE=$?
    else
        timeout ${ITERATION_TIMEOUT}s bash -c "cat '$PROMPT_FILE' | $AGENT_COMMAND $AGENT_FLAGS" 2>&1 | tee -a "$LOG_FILE" || AGENT_EXIT_CODE=$?
    fi
    
    # Check if timeout occurred (exit code 124)
    if [ $AGENT_EXIT_CODE -eq 124 ]; then
        {
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "FATAL: Agent exceeded iteration timeout (${ITERATION_TIMEOUT}s)"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        } | tee -a "$LOG_FILE"
        fatal "Agent exceeded iteration timeout (${ITERATION_TIMEOUT}s)"
    fi
    
    # Record end time and calculate duration
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    DURATION_MIN=$((DURATION / 60))
    DURATION_SEC=$((DURATION % 60))
    DURATION_STR="${DURATION_MIN}m ${DURATION_SEC}s"
    
    # Get commit hash if changes were committed
    COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "none")
    
    # Parse metrics from agent output and embed in log (no separate .metrics file)
    if [ "$ENABLE_JSON_OUTPUT" = "true" ]; then
        debug "Parsing metrics from agent output..."
        parse_metrics "$LOG_FILE" "$ITERATION" "$DURATION_STR" "$COMMIT_HASH" "$AGENT_EXIT_CODE"
    fi
    
    # Log iteration footer
    {
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Iteration $ITERATION Complete"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Completed: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Duration: $DURATION_STR"
        echo "Commit: $COMMIT_HASH"
        echo "Exit Code: $AGENT_EXIT_CODE"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
    } | tee -a "$LOG_FILE"
    
    # Check if agent exited with error
    if [ $AGENT_EXIT_CODE -ne 0 ] && [ $AGENT_EXIT_CODE -ne 124 ]; then
        warn "Agent exited with code $AGENT_EXIT_CODE"
    fi
    
    # Run validation hook
    run_validation
    
    # Push changes
    # Check if there are any commits to push
    if git log origin/"$CURRENT_BRANCH"..HEAD --oneline 2>/dev/null | grep -q .; then
        debug "Pushing changes..."
        push_with_retry
    else
        debug "No new commits to push"
    fi
    
    echo ""
    info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    info "Iteration $ITERATION complete"
    info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Check again for interrupt after iteration completes
    if [ "$INTERRUPT_RECEIVED" = true ]; then
        cleanup
    fi
done

info "Loop finished"
exit 0
