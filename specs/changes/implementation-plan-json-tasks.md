---
status: proposed
spec_type: refactor
updates: [.ralph/IMPLEMENTATION_PLAN.md format, .ralph/prompts/PROMPT_implementation_plan.md]
---

# Implementation Plan JSON Task Format

## Current Behavior

The `.ralph/IMPLEMENTATION_PLAN.md` file uses a numbered Markdown list format for tasks under the `## Remaining Tasks` section:

```markdown
## Remaining Tasks

1. [HIGH PRIORITY] Fix authentication bug in login handler
   - Blocked by: Unclear requirements for password special chars
   - Spec: specs/authentication.md

2. Add user profile API endpoint
   - Spec: specs/user-management.md - "Profile Endpoint"

3. Implement password reset flow
```

The `.ralph/loop.sh` script extracts task information using grep and sed:
- Extracts section between `## Remaining Tasks` and next `##` header
- Uses `grep -m 1 '^[0-9]\+\.'` to find first numbered task
- Parses optional `Spec:` line in subsequent lines

**Problems with current approach:**
- Grep/sed parsing is fragile and error-prone
- No guaranteed structure for task metadata
- Priority markers like `[HIGH PRIORITY]` are freeform text
- Status markers like `[BLOCKED]` are inconsistent
- Spec references can appear in various formats
- Notes/constraints are unstructured bullet points
- Difficult to extract specific task fields reliably

**Current implementation:**
- Format example: `.ralph/IMPLEMENTATION_PLAN.md` (current projects)
- Parsing logic: `.ralph/loop.sh` lines 165-194 (`extract_current_task()`)
- Generation guidance: `.ralph/prompts/PROMPT_implementation_plan.md`

## Proposed Behavior

The `## Remaining Tasks` section will contain a **pretty-printed JSON array** of task objects as the sole source of truth. Each task object has a fixed schema with all required fields present.

**Example format:**

```markdown
## Remaining Tasks

```json
[
  {
    "id": "T-001",
    "description": "Fix authentication bug in login handler",
    "spec": "specs/authentication.md",
    "priority": "HIGH",
    "status": "BLOCKED",
    "notes": [
      "Blocked by: Unclear requirements for password special chars",
      "Needs: Clarification from human or update to specs/"
    ]
  },
  {
    "id": "T-002",
    "description": "Add user profile API endpoint",
    "spec": "specs/user-management.md",
    "priority": "MEDIUM",
    "status": "OPEN",
    "notes": [
      "POST /api/users with validation",
      "Hash passwords with bcrypt"
    ]
  },
  {
    "id": "T-003",
    "description": "Implement password reset flow",
    "spec": "",
    "priority": "LOW",
    "status": "OPEN",
    "notes": []
  }
]
```
```

### JSON Schema Requirements

Each task object MUST contain all of the following required fields:

- **`id`** (string): Unique task identifier, format: `"T-NNN"` where NNN is zero-padded number (e.g., "T-001", "T-002", "T-123")
- **`description`** (string): Brief, action-oriented task description
- **`spec`** (string): Spec file path (e.g., `"specs/feature-name.md"`) or empty string `""` if no spec reference
- **`priority`** (string): One of `"HIGH"`, `"MEDIUM"`, `"LOW"`, or empty string `""`
- **`status`** (string): One of `"OPEN"`, `"BLOCKED"`, `"DONE"`, or empty string `""`
- **`notes`** (array of strings): Additional details, constraints, or context; empty array `[]` allowed

### Formatting Rules

1. **JSON block MUST be fenced:** Use triple backticks with `json` language identifier
2. **Pretty-printed:** Each object on multiple lines with 2-space indentation
3. **Array format:** Top-level array `[...]` containing task objects
4. **Order matters:** First task in array is highest priority (top of list)
5. **All fields required:** Even if value is empty string `""` or empty array `[]`
6. **No trailing commas:** Valid JSON syntax only

### Other Sections Unchanged

All other sections of `IMPLEMENTATION_PLAN.md` remain standard Markdown:
- `## Overview` - Plain markdown text
- `## Notes` - Plain markdown with subsections as needed
- Any other custom sections

### Parsing Benefits

With this format, `.ralph/loop.sh` can:
- Extract JSON block using simple markers (find fenced `json` block under `## Remaining Tasks`)
- Parse using `jq` for reliable field extraction
- Access first task deterministically: `jq '.[0]'`
- Extract any field safely: `jq '.[0].spec'`, `jq '.[0].priority'`, etc.
- Validate schema before processing

## Migration Plan

### Step 1: Create the spec
- Write this specification document
- Define JSON schema and formatting rules
- Provide examples and validation criteria

### Step 2: Update agent prompts and templates
- Update `.ralph/prompts/PROMPT_implementation_plan.md`:
  - Replace numbered list format template with JSON array template
  - Add JSON schema documentation
  - Update all examples to use JSON format
  - Add formatting guidelines (pretty-print, required fields)
  - Update task granularity examples to show JSON structure
- Update `.ralph/prompts/PROMPT_build.md` if it references task format
- Verify no other prompts depend on numbered list format

### Step 3: Update parsing in loop.sh
- Modify `extract_current_task()` function in `.ralph/loop.sh`:
  - Extract fenced JSON block under `## Remaining Tasks`
  - Parse using `jq` to read first task object
  - Extract `description` and `spec` fields for logging
  - Add error handling for malformed JSON
  - Fall back gracefully if JSON not found (for backward compatibility during transition)

### Step 4: Update documentation
- Update `specs/ralph-overview.md` example format to show JSON
- Update `specs/README.md` with entry for this spec
- Document the change in commit message

### Step 5: Migrate existing plans (if any)
- Existing `IMPLEMENTATION_PLAN.md` files continue to work (loop.sh backward compatible during transition)
- New plans generated will use JSON format
- Manual migration of active plans can be done if needed

## Success Criteria

- [x] Spec document created with clear JSON schema and examples
- [ ] `.ralph/prompts/PROMPT_implementation_plan.md` updated with JSON format template and examples
- [ ] JSON schema clearly documented (all required fields, types, valid values)
- [ ] Formatting rules specified (pretty-print, fencing, indentation)
- [ ] Examples show well-formatted JSON with all field types
- [ ] Examples demonstrate empty/blank field handling
- [ ] `specs/README.md` updated with entry for this spec
- [ ] Documentation clearly states JSON is sole source of truth for tasks

**Note:** Actual loop.sh parsing updates are out of scope for this spec and will be handled separately.

