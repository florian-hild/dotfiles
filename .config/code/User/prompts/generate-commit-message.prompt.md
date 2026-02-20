---
agent: agent
model: Claude Haiku 4.5 (copilot)
description: Generaste a commit message based on the code changes made
---
# Goal
Generate a concise yet detailed git commit message from staged changes only, following Conventional Commits format.

# Output Format
Provide the commit message in a markdown code block so it can be easily copied:

```
<type>(<scope>): <short summary>

Body text here...
```

Do not include any explanations before or after the code block.

# Structure

## Header (Required)
```
<type>(<scope>): <short summary>
```
- **type**: feat, fix, refactor, docs, test, build, chore
- **scope**: component/file/module affected (lowercase, e.g., build.xml, jar-signer)
- **summary**: imperative mood, lowercase, no period, ~50 chars max

## Body (Always include when meaningful)
- Blank line after header
- Focus on **what changed** and **why** it matters
- Use clear section headings (e.g., "Changes:", "Improvements:", "Formatting:")
- List related changes as bullet points (aim for 3-8 items for fuller context)
- Include error messages, warnings, or important context from chat if relevant
- Plain language, no fancy formatting

## Footer (Optional)
- `Closes #123` or `Fixes #456` if applicable

# Guidelines
- Write in **English**
- Use **imperative mood** ("add", "fix", "refactor", not "added", "fixed")
- **Focus ONLY on staged files** (those added with `git add`)
- Be **detailed but concise** - enough info to understand the change at a glance
- Include relevant error messages or warnings mentioned in the chat
- No redundant phrases ("this commit", "in this change")
- **PRIORITY: Highlight functional/behavioral changes first** — changes that affect how code works, user workflows, or app behavior take precedence over formatting, style, or spelling corrections
- When mixed changes exist (features + formatting), list features in primary sections (Features:, Improvements:, Fixes:) and relegate formatting to a secondary "Code Quality:" section
- Aim for body length of 3-6 lines for better context

# Examples

```
refactor(ctest-service): enhance test health check and apply ruff formatting

Features:
- Add signing_settings object to health check with digest_alg, sig_alg
- Include path visibility in health response
- Update health status logic

Improvements:
- Health check now provides better diagnostics for signing service troubleshooting
- Clear distinction between infrastructure health and configuration readiness

Formatting:
- Organize imports with proper grouping (stdlib, third-party, local)
- Normalize string quotes to double quotes for consistency
- Improve line wrapping for long function signatures and arguments
- Apply trailing commas to multi-line structures

Scope:
- test.py with health check feature and formatting
- Applied ruff formatting across 14 additional modules (main.py, config, auth, audit, middleware, routers, services)
```
