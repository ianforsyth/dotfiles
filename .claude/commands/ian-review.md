---
description: Code review the diff between current branch and master
allowed-tools: Bash(git diff:*), Bash(git log:*), Bash(git branch:*)
---

# Code Review

## Context

Current branch: !`git branch --show-current`
Files changed: !`git diff --name-status master...HEAD || git diff --name-status origin/master...HEAD`
Full diff: !`git diff master...HEAD || git diff origin/master...HEAD`

## Task

Review the code changes between the current branch and master. Provide a thorough review focused on actual problems and improvements.

## Output Format

Start with a brief overview paragraph summarizing the changes and overall assessment.

Then provide a bulleted list of specific issues and suggestions. For each item include:
- The file path and line numbers
- Clear description of the issue
- Suggested fix or improvement

## Review Focus Areas

Focus on finding real issues in these areas:

**Security**
- Input validation and sanitization
- SQL injection vulnerabilities
- Authentication and authorization flaws
- Exposed secrets or credentials
- XSS vulnerabilities

**Performance**
- Inefficient algorithms or data structures
- N+1 database queries
- Memory leaks
- Missing indexes
- Unnecessary re-renders or computations

**Code Quality**
- Code duplication
- Complex functions that should be broken down
- Poor error handling
- Inconsistent patterns within the codebase
- Dead code
- Type safety issues

**Best Practices**
- Violations of established patterns in this codebase
- Improper separation of concerns
- Missing edge case handling
- Race conditions
- Backwards compatibility breaks

Keep feedback specific and actionable. Skip minor style issues unless they significantly impact readability. Focus on problems that actually matter for maintainability, security, and correctness.
