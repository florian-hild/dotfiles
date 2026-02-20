---
agent: agent
model: Claude Sonnet 4.5 (copilot)
description: Refactor a Bash script using best practices, ShellCheck compliance, and structured logging
argument-hint: Provide the Bash script to refactor or select it in the editor
tools: [read, edit, execute]
---

# Goal
Refactor the provided Bash script following professional best practices, ShellCheck compliance, and structured logging.
Apply changes to the file while preserving its original functionality.

# Code Style

## Variables
- Use **curly braces** for all variable references: `${var_name}` not `$var`
- Use **snake_case** for variable names: `config_dir_dst`, `oracle_sid`
- Use **UPPER_CASE** for exported environment variables: `${ORACLE_HOME}`
- Declare local variables with `local` keyword inside functions
- Quote all variable expansions: `"${var}"` to prevent word splitting
- Use `readonly` for constants that should not change

## Functions
- Use descriptive function names in camelCase or snake_case consistently
- Add function documentation comments for complex logic
- Use `local` for all function-scoped variables
- Return meaningful exit codes (0 = success, non-zero = specific error)
- Prefer early returns to reduce nesting

## Arrays
- Use proper array syntax: `local -a files=(...)`
- Iterate with: `for item in "${array[@]}"; do`
- Quote array expansions: `"${files[@]}"`

# ShellCheck Compliance
- Script must pass `shellcheck -x` with no warnings
- Add `# shellcheck disable=SCXXXX` only when unavoidable, with explanation
- Use `[[ ]]` for conditionals instead of `[ ]`
- Avoid common pitfalls:
  - Always quote variables
  - Use `$()` instead of backticks
  - Handle empty variables gracefully

# Structured Logging

## Log Levels
- **DEBUG** - Detailed diagnostic info (file paths, variable values, step details)
- **INFO** - High-level progress and status messages
- **WARN** - Recoverable issues or deprecation notices
- **ERROR** - Failures requiring attention
- **FATAL** - Unrecoverable errors causing script termination

## Message Guidelines
- Be **concise yet informative**
- Include relevant context: `"Moving: ${src_file} -> ${dest_dir}"`
- Use single quotes around variable values in messages: `"ORACLE_SID = '${ORACLE_SID}'"`
- Align multi-value outputs for readability:
  ```
  log "info" "ORACLE_SID          = '${ORACLE_SID}'"
  log "info" "ORACLE_PDB          = '${ORACLE_PDB}'"
  log "info" "ORACLE_CHARACTERSET = '${ORACLE_CHARACTERSET}'"
  ```

# Error Handling
- Use `set -e` to exit on errors (or handle errors explicitly)
- Use `set -o pipefail` when using pipes
- Trap signals for graceful shutdown: `trap cleanup SIGINT SIGTERM`
- Validate inputs and environment before proceeding
- Provide meaningful error messages with context

# Script Structure
```bash
#!/usr/bin/env bash
set -e

# shellcheck disable=SC1091
source "/path/to/logger"

# Constants
readonly SCRIPT_NAME="$(basename "$0")"

# Functions (alphabetical or logical order)
function cleanup { ... }
function validate_environment { ... }
function main { ... }

# Signal handlers
trap cleanup SIGINT SIGTERM

# Entry point
main "$@"
```

# Output Format
Provide the refactored script in a code block. Include:
1. Brief summary of changes made
2. Any ShellCheck directives added with justification
3. The complete refactored script

# Example Transformation

Before:
```bash
config_dir=$ORACLE_BASE/oradata/dbconfig/$ORACLE_SID
if [ ! -d $config_dir ]; then
   mkdir -p $config_dir
   echo "Created directory"
fi
```

After:
```bash
local config_dir="${ORACLE_BASE}/oradata/dbconfig/${ORACLE_SID}"

if [[ ! -d "${config_dir}" ]]; then
    mkdir -p "${config_dir}"
    log "debug" "Created directory '${config_dir}'"
fi
```

