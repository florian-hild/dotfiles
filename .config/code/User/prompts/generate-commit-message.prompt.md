---
agent: agent
model: Claude Haiku 4.5 (copilot)
description: Generate a commit message from staged changes
---
# Goal
Generate a clear git commit message from **staged changes only** following Conventional Commits.

# Steps
1. Run `git diff --staged --stat` and `git diff --staged` to see **currently staged changes only**
   - **Important**: Re-staging a modified file will only show changes since the last stage — not cumulative changes
   - To see all uncommitted changes: `git diff HEAD --stat` instead
2. Run `git branch --show-current` to derive the commit type
3. If the user provided extra context (ticket numbers, error codes), include it in the footer
4. Write the commit message — output **only** a fenced code block with no explanations

# Rules
- **CRITICAL: Only describe changes visible in `git diff --staged` output** — nothing more, nothing less
  - Do NOT infer, assume, or mention changes that aren't in the diff
  - Do NOT predict or describe intended changes that may not be staged
  - Strictly document what the diff shows
- **NO emojis** — commit messages must be plain text, no emoji characters of any kind
- `git diff --staged` is the **single source of truth** — only describe **currently staged** changes
  - If you modify and re-stage a file, you'll only see the delta since the last stage
  - Stage all your changes at once, then request the commit message
- Chat history may add context (error codes, root cause) only if the fix is visible in the diff
- Header line: **max 50 characters**
- A reviewer should understand the change in 10 seconds

# Commit Type

Derive from the branch name:

| Branch pattern                 | Type     |
|--------------------------------|----------|
| `feature/*`, `feat/*`          | feat     |
| `fix/*`, `bugfix/*`, `hotfix/*`| fix      |
| `docs/*`                       | docs     |
| `refactor/*`                   | refactor |
| `test/*`                       | test     |
| `build/*`, `ci/*`              | build    |
| `chore/*`                      | chore    |
| anything else                  | infer    |

# Commit Message Format

```
<type>[(<scope>)]: <summary>

[<body>]

[<footer>]
```

## Header (required)
- **type** — from branch mapping above
- **scope** (optional) — only when it adds clarity, e.g. in apps with distinct modules. Omit for simple or cross-cutting changes
- **summary** — imperative mood, lowercase, no period

### Scope Detection
When scope is useful, derive it from the **top-level directory or config domain**, not the leaf filename.

| Path pattern                    | Scope      |
|---------------------------------|------------|
| `.config/code/*`, `.vscode/*`   | vscode     |
| `oracle/sql/*`                  | oracle-sql |

Multiple scopes → use a broader scope or omit entirely.

## Body (optional)
- Bullet list, max 5 items
- Focus on **what** and **why**, not how
- Include searchable context: error codes, config names, warnings

## Footer (optional)
- `Refs: JIRA-1234` or `Fixes #123` when provided by user
- `Co-authored-by:` if applicable

# Examples

```
fix(linkgroup): use correct mapping path

- Check project config dir before module dir fallback
- Log warning when mapping file not found
- Resolves "ENOENT: mapping file not found" on pull
```

```
feat(api): add health check endpoint

- Return signing settings and path visibility
- Separate infra health from config readiness

Refs: JIRA-4521
```

```
docs: update build instructions
```

```
chore: update gitignore patterns
```
