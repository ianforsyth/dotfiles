---
name: create-hook
description: Create a new Claude Code hook for the current project
argument-hint: [description of what to catch]
---

Create a Claude Code hook for the current project based on the user's request: $ARGUMENTS

## Hook structure

Hooks need two things:

1. **A shell script** in `.claude/hooks/` that does the check
2. **A settings entry** in `.claude/settings.json` that wires it up

## Settings format

Add hooks to `.claude/settings.json` under the `hooks` key. Merge with existing entries if the file already exists.

```json
{
  "hooks": {
    "<Event>": [
      {
        "matcher": "<ToolPattern>",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/<script-name>.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

## Events

- `PreToolUse` - before a tool runs (can block it)
- `PostToolUse` - after a tool succeeds (can reject the result)
- `Stop` - when Claude finishes responding
- `SessionStart` - when a session begins

## Matcher

Filters which tool triggers the hook. Supports `|` for multiple tools:
- `Edit|Write` - file modifications
- `Bash` - shell commands
- `Read` - file reads

## Shell script pattern

Scripts receive JSON on stdin with `tool_input` and `tool_response`. Key fields:

- `.tool_input.file_path` - the file being operated on
- `.tool_input.content` - file content (Write)
- `.tool_input.command` - shell command (Bash)

Exit codes:
- `0` - pass (stdout JSON is optional feedback)
- `2` - block the action (stderr message is shown to Claude as the reason)

```bash
#!/bin/bash
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Guard: skip if not relevant
if [[ -z "$FILE_PATH" || ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# Check for the pattern
if grep -nE 'BAD_PATTERN' "$FILE_PATH" > /dev/null 2>&1; then
  MATCHES=$(grep -nE 'BAD_PATTERN' "$FILE_PATH")
  echo "Description of what's wrong and what to do instead:" >&2
  echo "$MATCHES" >&2
  exit 2
fi

exit 0
```

## Steps

1. Read `.claude/settings.json` to see existing hooks
2. Create the script in `.claude/hooks/` with a descriptive kebab-case name
3. `chmod +x` the script
4. Add the hook entry to `.claude/settings.json`, merging with existing hooks
