---
name: pr
description: Generate a PR URL with title, description, and relevant context from the conversation (benchmarks, findings, reasoning)
allowed-tools: Bash(git remote get-url:*), Bash(git branch:*), Bash(git diff:*), Bash(git log:*), Bash(node:*), Bash(open:*)
---

## Step 1: Gather context

1. Get the repo remote URL and current branch name
2. Run `git diff master...HEAD` and `git log master...HEAD --oneline` to understand all changes

## Step 2: Write the PR title and description

**Title:**
- Clear and concise (under 70 characters)
- Use conventional format if appropriate (fix:, feat:, refactor:, chore:, docs:)

**Description:**

### Summary
Write 2-3 sentences explaining what this PR does, why this change is being made, and the impact/benefit.

### Changes
Write 5-7 bullet points detailing the specific modifications.

### Conversation context
Review the conversation history for anything that strengthens the PR description: benchmarks, production query results, error analysis, investigation findings, design decisions, tradeoff discussions, or reasoning behind the approach. Include relevant findings inline — embed benchmark numbers in the summary, reference error counts or production data that motivated the change, etc. Don't create a separate section unless the context is substantial (e.g. a full EXPLAIN ANALYZE output or a detailed error breakdown).

## Step 3: Generate and open the URL

Generate the GitHub URL in this format:
```
https://github.com/[owner]/[repo]/compare/master...[current-branch]?quick_pull=1&title=[url-encoded-title]&body=[url-encoded-description]
```

- Parse owner/repo from the git remote origin URL
- URL encode the title and body parameters using `node -e` with `encodeURIComponent`
- Open the URL in Chrome using `open -a "Google Chrome"`
