---
allowed-tools: Bash(gh pr list:*), Bash(gh pr view:*), Bash(gh api:*), Bash(gh repo view:*), Bash(date:*)
description: Generate a weekly summary of GitHub PR activity
---

# Weekly PR Activity Summary

Generate a human-readable summary of pull request activity for the current week.

## Context

- Current date: !`date`
- GitHub username: !`gh api user --jq .login`
- Repository: !`gh repo view --json name -q .name`

## Your Task

Using the GitHub CLI (`gh`), analyze my pull request activity and create a concise, non-technical summary. Follow these steps:

### 1. Identify the time boundaries
- Determine the date of the most recent Monday (use `date -v-monday` for macOS)
- Determine the date of the previous Monday (use `date -v-1w -v-monday` for macOS)

### 2. Gather PR data using these commands:

**Open Pull Requests I authored:**
```bash
gh pr list --author @me --state open --json number,title,createdAt,url
```

**Merged Pull Requests I authored (since Monday) with full details:**
```bash
gh pr list --author @me --state merged --search "merged:>=YYYY-MM-DD" --json number,title,createdAt,mergedAt,url
```
Note: This fetches both createdAt and mergedAt in a single call, no need for individual PR lookups.

**Pull Requests I reviewed (since Monday):**
```bash
gh pr list --search "reviewed-by:@me updated:>=YYYY-MM-DD" --json number,title,url,author
```

### 3. Analyze and categorize the results:

For **Merged PRs**, include all that were merged since Monday with their opened and merged dates.

For **Ongoing PRs**, include all currently open PRs with their opened dates.

For **Reviewed PRs**, include all where you left comments since Monday (exclude PRs you authored) with review dates.

### 4. Create a summary with these sections:

**Weekly PR Activity Summary**

**Merged PRs**
- Opened [When opened] → Merged [When merged]: [Human-readable description of what was accomplished]
- Opened And Merged [When opened and merge are same day]: [Human-readable description of what was accomplished]
- [Focus on the impact/feature, not technical details]
- [Sort by opened date ascending, earliest first]

**Ongoing PRs**
- Opened [When opened]: [Description of the PR's purpose in simple terms]
- [Note if any need attention or are blocked]

**Reviewed PRs**
- Reviewed [When reviewed]: [Summary of what the PR does]
- [Mention the general areas/features reviewed]

### Guidelines:
- Use plain language - avoid PR numbers, branch names, or technical jargon
- Focus on what was accomplished or is being worked on, not how
- If there's no activity in a category, omit that section entirely
- Keep descriptions concise but meaningful
- Convert all timestamps from UTC to Mountain Time (UTC-7 for MST, UTC-6 for MDT)
- Format Dates as M/D

Remember: This summary should be suitable for sharing with non-technical stakeholders or in a team standup where the focus is on progress and deliverables, not implementation details.
