---
name: commit
description: Stage all changes and create a commit with a brief message and bulleted description
disable-model-invocation: true
allowed-tools: Bash(git *)
---

## Steps

1. Run `git diff` and `git status` to review all changes
2. Stage all changes with `git add -A`
3. Write a commit message in the following format:
   - **Subject**: Brief summary in imperative mood
   - **Body**: 3-5 bullet points describing the key changes
4. Commit using a HEREDOC for the message
5. Run `git status` to verify

## Commit Format

```
Brief subject line

- First key change
- Second key change
- Third key change
```

## Rules

- No author attributions
- Keep the subject line concise
- Bullet points should describe *what* changed, not *why*
