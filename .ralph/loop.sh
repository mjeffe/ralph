#!/bin/bash
# Ralph Wiggum Loop - Core Loop Implementation
# 
# Usage:
#   ./loop.sh              # Build mode, unlimited iterations
#   ./loop.sh 20           # Build mode, max 20 iterations
#   ./loop.sh plan         # Plan mode, single interactive session
#   ./loop.sh plan feature # Plan mode with spec name hint

set -e

# Configuration
ITERATION_TIMEOUT=${RALPH_ITERATION_TIMEOUT:-1800}  # 30 minutes default
AGENT_COMMAND=${RALPH_AGENT:-cline}
MIN_DISK_SPACE_MB=1024  # 1GB minimum
ENABLE_JSON_OUTPUT=${RALPH_JSON_OUTPUT:-true}  # Enable JSON output for metrics parsing

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

# Create log file with timestamp
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

# Check for PROJECT_COMPLETE marker
check_project_complete() {
    if [ -f "IMPLEMENTATION_PLAN.md" ]; then
        if grep -q "PROJECT_COMPLETE" IMPLEMENTATION_PLAN.md; then
            return 0
        fi
    fi
    return 1
}

# Parse metrics from agent JSON output
parse_metrics() {
    local log_file="$1"
    local metrics_file="${log_file}.metrics"
    
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
    
    # Write metrics to file
    {
        echo "# Agent Metrics"
        echo "API Requests: $api_requests"
        echo "Total Messages: $total_messages"
        echo "Model: $model_info"
        echo ""
        echo "# Note: Token counts and costs not available in current cline output"
        echo "# Future enhancement: Parse usage data when cline provides it"
    } > "$metrics_file"
    
    # Append metrics summary to log file
    {
        echo ""
        echo "# Metrics Summary"
        echo "API Requests: $api_requests"
        echo "Total Messages: $total_messages"
        echo "Model: $model_info"
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
MODE="build"
MAX_ITERATIONS=0
SPEC_NAME=""

if [ "$1" = "plan" ]; then
    MODE="plan"
    SPEC_NAME="${2:-}"
elif [[ "$1" =~ ^[0-9]+$ ]]; then
    MODE="build"
    MAX_ITERATIONS=$1
fi

# Set prompt file based on mode
if [ "$MODE" = "plan" ]; then
    PROMPT_FILE=".ralph/prompts/PROMPT_plan.md"
else
    PROMPT_FILE=".ralph/prompts/PROMPT_build.md"
fi

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
echo "Mode:   $MODE"
echo "Prompt: $PROMPT_FILE"
echo "Branch: $CURRENT_BRANCH"
echo "Agent:  $AGENT_COMMAND"
[ $MAX_ITERATIONS -gt 0 ] && echo "Max:    $MAX_ITERATIONS iterations"
[ "$MODE" = "plan" ] && [ -n "$SPEC_NAME" ] && echo "Spec:   $SPEC_NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Main loop
ITERATION=0

while true; do
    # Check max iterations
    if [ $MAX_ITERATIONS -gt 0 ] && [ $ITERATION -ge $MAX_ITERATIONS ]; then
        info "Reached max iterations: $MAX_ITERATIONS"
        break
    fi
    
    # Check for project completion (build mode only)
    if [ "$MODE" = "build" ] && check_project_complete; then
        info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        info "PROJECT COMPLETE! All tasks finished."
        info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        break
    fi
    
    # Run health checks (build mode only)
    if [ "$MODE" = "build" ]; then
        debug "Running health checks..."
        check_health
    fi
    
    # Create log file for this iteration (build mode only)
    if [ "$MODE" = "build" ]; then
        LOG_FILE=$(create_log_file)
    fi
    
    ITERATION=$((ITERATION + 1))
    
    # Log iteration header (build mode only)
    if [ "$MODE" = "build" ]; then
        {
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Iteration: $ITERATION"
            echo "Mode: $MODE"
            echo "Branch: $CURRENT_BRANCH"
            echo "Started: $(date '+%Y-%m-%d %H:%M:%S')"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
        } | tee -a "$LOG_FILE"
        
        info "Starting iteration $ITERATION..."
        debug "Logging to: $LOG_FILE"
    else
        info "Starting plan mode session..."
    fi
    
    # Record start time
    START_TIME=$(date +%s)
    
    # Run agent with timeout
    AGENT_EXIT_CODE=0
    if [ "$MODE" = "plan" ]; then
        # Plan mode: interactive session, no timeout, no logging
        # Build task prompt that references the guidance file
        TASK_PROMPT="Study \`.ralph/prompts/PROMPT_plan.md\` for detailed guidance on your role. "
        
        # If spec name hint provided, include it in the task
        if [ -n "$SPEC_NAME" ]; then
            TASK_PROMPT="${TASK_PROMPT}The user wants to create a specification for: **${SPEC_NAME}**. "
        fi
        
        TASK_PROMPT="${TASK_PROMPT}Follow the guidance to help create a well-structured specification."
        
        # Invoke cline in interactive plan mode (no --yolo, no --json)
        $AGENT_COMMAND --plan "$TASK_PROMPT" || AGENT_EXIT_CODE=$?
    else
        # Build mode: autonomous with timeout and logging
        # Determine agent flags based on configuration
        AGENT_FLAGS="--yolo"
        if [ "$ENABLE_JSON_OUTPUT" = "true" ]; then
            AGENT_FLAGS="$AGENT_FLAGS --json"
        else
            AGENT_FLAGS="$AGENT_FLAGS --verbose"
        fi
        
        timeout ${ITERATION_TIMEOUT}s bash -c "cat '$PROMPT_FILE' | $AGENT_COMMAND $AGENT_FLAGS" 2>&1 | tee -a "$LOG_FILE" || AGENT_EXIT_CODE=$?
        
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
    fi
    
    # Parse metrics from agent output if JSON output is enabled (build mode only)
    if [ "$MODE" = "build" ] && [ "$ENABLE_JSON_OUTPUT" = "true" ]; then
        debug "Parsing metrics from agent output..."
        parse_metrics "$LOG_FILE"
    fi
    
    # Log iteration footer (build mode only)
    if [ "$MODE" = "build" ]; then
        # Record end time and calculate duration
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - START_TIME))
        DURATION_MIN=$((DURATION / 60))
        DURATION_SEC=$((DURATION % 60))
        
        # Get commit hash if changes were committed
        COMMIT_HASH=$(git rev-parse --short HEAD 2>/dev/null || echo "none")
        
        {
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Completed: $(date '+%Y-%m-%d %H:%M:%S')"
            echo "Duration: ${DURATION_MIN}m ${DURATION_SEC}s"
            echo "Commit: $COMMIT_HASH"
            echo "Exit Code: $AGENT_EXIT_CODE"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        } | tee -a "$LOG_FILE"
        
        # Check if agent exited with error
        if [ $AGENT_EXIT_CODE -ne 0 ] && [ $AGENT_EXIT_CODE -ne 124 ]; then
            warn "Agent exited with code $AGENT_EXIT_CODE"
        fi
    fi
    
    # Run validation hook (build mode only)
    if [ "$MODE" = "build" ]; then
        run_validation
    fi
    
    # Push changes (build mode only)
    if [ "$MODE" = "build" ]; then
        # Check if there are any commits to push
        if git log origin/"$CURRENT_BRANCH"..HEAD --oneline 2>/dev/null | grep -q .; then
            debug "Pushing changes..."
            push_with_retry
        else
            debug "No new commits to push"
        fi
    fi
    
    # Plan mode is a single session, not a loop
    if [ "$MODE" = "plan" ]; then
        info "Plan mode session complete"
        
        # Check if any changes were made to specs/
        if git diff --quiet specs/ 2>/dev/null && \
           git diff --cached --quiet specs/ 2>/dev/null; then
            debug "No changes detected in specs/"
        else
            # Stage changes in specs/
            git add specs/
            
            # Generate appropriate commit message
            if [ -n "$SPEC_NAME" ]; then
                COMMIT_MSG="ralph plan: Add ${SPEC_NAME} specification"
            else
                COMMIT_MSG="ralph plan: Update specifications"
            fi
            
            git commit -m "$COMMIT_MSG"
            info "✓ Changes committed"
            
            # Push to remote (warn on failure, don't fail fatally)
            if git push origin "$CURRENT_BRANCH" 2>&1; then
                info "✓ Push successful"
            else
                warn "Push failed - you may need to push manually"
            fi
        fi
        
        break
    fi
    
    echo ""
    info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    info "Iteration $ITERATION complete"
    info "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
done

info "Loop finished"
exit 0
