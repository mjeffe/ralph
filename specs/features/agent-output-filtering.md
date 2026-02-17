# Agent Output Filtering

## Overview

Create a terminal output filter for the Ralph build loop that displays human-readable agent activity while preserving complete raw logs. The filter parses JSON-formatted agent output to show reasoning, tool usage, errors, and summaries while hiding verbose prompts and API payloads.

## Problem Statement

When Ralph runs the agent with `--json` flag, all output is piped via `tee` to both the log file and terminal. This includes:
- Full task prompts (thousands of characters)
- Raw API request payloads
- Verbose JSON structures
- Repeated contextual information

This creates an overwhelming terminal experience where humans cannot effectively monitor agent progress. The raw logs are valuable for debugging, but the terminal output should be concise and actionable.

## Requirements

### Functional Requirements

**Terminal Output Should Display:**
- Tool usage with clear indication of which tools are being used (read_file, search_files, browser_action, etc.)
- Agent reasoning and narrative text (`say: "text"`)
- Task descriptions (headline/summary from `say: "task"`)
- Error messages and warnings
- Completion results and summaries
- MCP tool usage indicators
- Task progress updates

**Terminal Output Should Hide:**
- Full prompt payloads from `say: "api_req_started"`
- Raw JSON that isn't user-facing
- Verbose context dumps
- Repetitive token-level details

**Full Logs Preserve:**
- Every byte of raw agent output
- Complete JSON structures
- All API payloads
- Full debugging information

### Non-Functional Requirements

- **JSON-only parsing**: Filter expects JSON output from agent (`--json` flag)
- **Dependency**: Requires `jq` for JSON parsing
- **Failure mode**: If `jq` is missing, display clear warning and fail (do not proceed with raw output)
- **Performance**: Minimal overhead; real-time streaming output
- **Maintainability**: Simple, readable bash/jq implementation

## Technical Specification

### Architecture

```
agent output (JSON)
    ↓
    ├─→ tee → full.log (unchanged)
    └─→ filter script → terminal (filtered)
```

### Filter Script Location

Create `.ralph/lib/filter-output.sh` as a standalone executable script.

### Integration Point

Update `.ralph/loop.sh` in the build mode agent execution section:

**Current:**
```bash
timeout ${ITERATION_TIMEOUT}s bash -c "cat '$PROMPT_FILE' | $AGENT_COMMAND $AGENT_FLAGS" 2>&1 | tee -a "$LOG_FILE"
```

**Modified:**
```bash
timeout ${ITERATION_TIMEOUT}s bash -c "cat '$PROMPT_FILE' | $AGENT_COMMAND $AGENT_FLAGS" 2>&1 | tee -a "$LOG_FILE" | .ralph/lib/filter-output.sh
```

### JSON Message Types

Based on agent output samples, the JSON structure is:
```json
{
  "ts": 1770313341632,
  "type": "say",
  "say": "task|text|tool|api_req_started|completion_result|...",
  "text": "...",
  "modelInfo": {...}
}
```

### Filtering Rules

| `say` value | Terminal Output | Notes |
|-------------|----------------|-------|
| `task` | Full text shown | Do not truncate; show complete task prompt |
| `text` | Full text shown | Agent reasoning/narrative |
| `tool` | Parse and format tool usage | e.g., "Tool: read_file (.ralph/loop.sh)" |
| `api_req_started` | Show "API request started" only | Hide full payload |
| `completion_result` | Full text shown | Final summary |
| `task_progress` | Show progress updates | Task checklist status |
| `ask` | Full text shown | Questions/prompts for user |
| Other | Show with label | e.g., "Say[other_type]: ..." |

### Error Handling

**Invalid JSON line:**
- Log to stderr: `[filter] Warning: unparseable JSON line (skipped)`
- Continue processing

**Missing fields:**
- Best-effort display
- Show what's available, note missing fields

**jq not available:**
- Display clear error message:
  ```
  ERROR: jq is required for output filtering
  Install jq: apt-get install jq (Debian/Ubuntu)
               brew install jq (macOS)
  ```
- Exit with non-zero code (this will fail the build loop)

### Output Formatting

**Tool usage format:**
```
[TOOL] <tool_name>: <relevant_params>
```

**Text/reasoning format:**
```
<text content>
```

**Task format:**
```
[TASK]
<full task text>
```

**API request format:**
```
[API] Request started
```

**Completion format:**
```
[COMPLETE]
<completion text>
```

**Error format (colorized if terminal supports it):**
```
[ERROR] <error text>
```

## Implementation Details

### Filter Script Pseudocode

```bash
#!/bin/bash
# .ralph/lib/filter-output.sh

# Check for jq
if ! command -v jq &>/dev/null; then
    echo "ERROR: jq is required for output filtering" >&2
    echo "Install: apt-get install jq (Debian/Ubuntu) or brew install jq (macOS)" >&2
    exit 1
fi

# Process each line
while IFS= read -r line; do
    # Try to parse as JSON
    if ! echo "$line" | jq empty 2>/dev/null; then
        echo "[filter] Warning: unparseable JSON line (skipped)" >&2
        continue
    fi
    
    # Extract fields
    say_type=$(echo "$line" | jq -r '.say // empty')
    text=$(echo "$line" | jq -r '.text // empty')
    
    # Filter based on say_type
    case "$say_type" in
        task)
            echo "[TASK]"
            echo "$text"
            ;;
        text)
            echo "$text"
            ;;
        tool)
            # Parse tool JSON from text field
            # Format: [TOOL] <tool_name>: <path or relevant info>
            ;;
        api_req_started)
            echo "[API] Request started"
            ;;
        completion_result)
            echo "[COMPLETE]"
            echo "$text"
            ;;
        *)
            # Show other types with label
            if [ -n "$text" ]; then
                echo "[${say_type^^}] $text"
            fi
            ;;
    esac
done
```

### Color Support (Optional Enhancement)

If terminal supports colors (check `$TERM`), use ANSI codes:
- Tool usage: Blue
- Errors: Red
- Completion: Green
- Default: No color

## Examples

### Example 1: Tool Usage

**Raw JSON:**
```json
{"ts":1770313345243,"type":"say","say":"tool","text":"{\"tool\":\"readFile\",\"path\":\"IMPLEMENTATION_PLAN.md\"}"}
```

**Terminal Output:**
```
[TOOL] readFile: IMPLEMENTATION_PLAN.md
```

### Example 2: API Request

**Raw JSON:**
```json
{"ts":1770313342453,"type":"say","say":"api_req_started","text":"{\"request\":\"<task>...5000 chars of prompt...</task>\"}"}
```

**Terminal Output:**
```
[API] Request started
```

### Example 3: Agent Reasoning

**Raw JSON:**
```json
{"ts":1770313344122,"type":"say","say":"text","text":"I'll start by reading the current state files to understand where we are in the Ralph build process."}
```

**Terminal Output:**
```
I'll start by reading the current state files to understand where we are in the Ralph build process.
```

## Success Criteria

- [x] `.ralph/lib/filter-output.sh` created and executable
- [ ] Filter script checks for jq dependency
- [ ] Filter script fails with clear error if jq missing
- [ ] Terminal shows task descriptions (full text, not truncated)
- [ ] Terminal shows agent reasoning/text
- [ ] Terminal shows formatted tool usage
- [ ] Terminal hides api_req_started payloads (shows label only)
- [ ] Terminal shows completion results
- [ ] Full logs remain unchanged
- [ ] Invalid JSON lines handled gracefully
- [ ] `.ralph/loop.sh` updated to use filter
- [ ] Filter tested with real agent output
- [ ] No noticeable performance degradation

## Out of Scope

- Text output mode (non-JSON) support
- GUI or web-based dashboard
- Log file analysis tools
- Historical log viewing/searching
- Output truncation (may be added in future if needed)
- Advanced color schemes or themes

## Testing Approach

1. **Unit test filter script:**
   - Feed sample JSON lines
   - Verify correct filtering
   - Test error cases (invalid JSON, missing fields)

2. **Integration test:**
   - Run ralph build loop with filter enabled
   - Verify terminal output is readable
   - Verify log file is complete
   - Confirm jq dependency check works

3. **Performance test:**
   - Run build loop with large output volume
   - Verify no significant slowdown

4. **Error case test:**
   - Remove jq
   - Verify clear error message and failure

## Notes

- This is a non-breaking change; existing logs remain unchanged
- Filter can be disabled by removing pipe to filter script
- Future enhancement: configuration file to customize filtering rules
- Future enhancement: optional output truncation toggle
- Future enhancement: color customization

## Dependencies

- Requires `jq` to be installed on the system
- No other external dependencies
