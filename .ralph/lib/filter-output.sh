#!/bin/bash
# Ralph Output Filter
# Filters JSON agent output for human-readable terminal display
# Full logs are preserved via tee before this filter

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Check for jq dependency
if ! command -v jq &>/dev/null; then
    echo -e "${RED}ERROR: jq is required for output filtering${NC}" >&2
    echo "Install jq:" >&2
    echo "  Debian/Ubuntu: apt-get install jq" >&2
    echo "  macOS: brew install jq" >&2
    echo "  RHEL/CentOS: yum install jq" >&2
    exit 1
fi

# Detect if terminal supports colors
if [ -t 1 ] && [ -n "$TERM" ] && [ "$TERM" != "dumb" ]; then
    USE_COLOR=true
else
    USE_COLOR=false
fi

# Helper function to format tool usage
format_tool() {
    local tool_json="$1"
    
    # Try to parse tool JSON
    local tool_name=$(echo "$tool_json" | jq -r '.tool // .name // empty' 2>/dev/null)
    local tool_path=$(echo "$tool_json" | jq -r '.path // .file // .absolutePath // empty' 2>/dev/null)
    local tool_command=$(echo "$tool_json" | jq -r '.command // empty' 2>/dev/null)
    local tool_regex=$(echo "$tool_json" | jq -r '.regex // empty' 2>/dev/null)
    
    # Format output based on available information
    if [ -n "$tool_name" ]; then
        local output="[TOOL] $tool_name"
        
        # Add relevant parameters
        if [ -n "$tool_path" ]; then
            output="$output: $tool_path"
        elif [ -n "$tool_command" ]; then
            # Truncate long commands
            if [ ${#tool_command} -gt 60 ]; then
                output="$output: ${tool_command:0:60}..."
            else
                output="$output: $tool_command"
            fi
        elif [ -n "$tool_regex" ]; then
            # Truncate long regex patterns
            if [ ${#tool_regex} -gt 60 ]; then
                output="$output: ${tool_regex:0:60}..."
            else
                output="$output: $tool_regex"
            fi
        fi
        
        if [ "$USE_COLOR" = true ]; then
            echo -e "${BLUE}${output}${NC}"
        else
            echo "$output"
        fi
    else
        # Fallback: show raw tool JSON if we can't parse it
        echo "[TOOL] $tool_json"
    fi
}

# Process each line of input
while IFS= read -r line; do
    # Try to parse as JSON
    if ! echo "$line" | jq empty 2>/dev/null; then
        # Not valid JSON - could be non-JSON output from agent
        # Pass through as-is (might be error messages, etc.)
        echo "$line"
        continue
    fi
    
    # Extract fields from JSON
    say_type=$(echo "$line" | jq -r '.say // empty' 2>/dev/null)
    text=$(echo "$line" | jq -r '.text // empty' 2>/dev/null)
    msg_type=$(echo "$line" | jq -r '.type // empty' 2>/dev/null)
    
    # Filter based on say_type
    case "$say_type" in
        task)
            # Show full task text
            if [ "$USE_COLOR" = true ]; then
                echo -e "${CYAN}[TASK]${NC}"
            else
                echo "[TASK]"
            fi
            echo "$text"
            ;;
            
        text)
            # Show agent reasoning/narrative
            echo "$text"
            ;;
            
        tool)
            # Parse and format tool usage
            format_tool "$text"
            ;;
            
        api_req_started)
            # Hide full payload, just show indicator
            if [ "$USE_COLOR" = true ]; then
                echo -e "${YELLOW}[API] Request started${NC}"
            else
                echo "[API] Request started"
            fi
            ;;
            
        completion_result)
            # Show completion summary
            if [ "$USE_COLOR" = true ]; then
                echo -e "${GREEN}[COMPLETE]${NC}"
            else
                echo "[COMPLETE]"
            fi
            echo "$text"
            ;;
            
        task_progress)
            # Show task progress updates
            if [ "$USE_COLOR" = true ]; then
                echo -e "${CYAN}[PROGRESS]${NC}"
            else
                echo "[PROGRESS]"
            fi
            echo "$text"
            ;;
            
        ask)
            # Show questions/prompts for user
            if [ "$USE_COLOR" = true ]; then
                echo -e "${YELLOW}[ASK]${NC}"
            else
                echo "[ASK]"
            fi
            echo "$text"
            ;;
            
        error)
            # Show errors prominently
            if [ "$USE_COLOR" = true ]; then
                echo -e "${RED}[ERROR]${NC}"
            else
                echo "[ERROR]"
            fi
            echo "$text"
            ;;
            
        "")
            # No say field - might be other message types
            # Check if it's an error or warning type
            if [ "$msg_type" = "error" ]; then
                if [ "$USE_COLOR" = true ]; then
                    echo -e "${RED}[ERROR] $text${NC}"
                else
                    echo "[ERROR] $text"
                fi
            elif [ -n "$text" ]; then
                # Show other messages with text
                echo "$text"
            fi
            # Otherwise skip (no useful content)
            ;;
            
        *)
            # Unknown say type - show with label if there's text
            if [ -n "$text" ]; then
                local label=$(echo "$say_type" | tr '[:lower:]' '[:upper:]')
                echo "[$label] $text"
            fi
            ;;
    esac
done
