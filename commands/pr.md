# Generate PR URL

Look at the git diff between the current branch and master branch.

Generate a PR title and description based on the changes:

1. PR Title:
   - Clear and concise (under 70 characters)
   - Use conventional format if appropriate (fix:, feat:, refactor:, chore:, docs:)

2. PR Description:
   
   ## Summary
   Write 2-3 sentences explaining what this PR does, why this change is being made, and the impact/benefit.
   
   ## Changes
   Write 5-7 bullet points detailing the specific modifications.

Generate the GitHub URL in this format:
https://github.com/[owner]/[repo]/compare/master...[current-branch]?quick_pull=1&title=[url-encoded-title]&body=[url-encoded-description]

Properly URL encode the title and body parameters and get the repository info from the git remote origin.

Then open the URL in Chrome using the `open -a "Google Chrome"` command.