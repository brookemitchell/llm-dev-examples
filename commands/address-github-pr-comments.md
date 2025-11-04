# Address GitHub PR Comments

## Overview

Process outstanding reviewer feedback, apply required fixes, and draft clear
responses for each GitHub pull-request comment using GitHub CLI.

## Prerequisites

### GitHub CLI Setup

**Required Tool**: GitHub CLI (`gh`)

**Installation**:

- **macOS**: `brew install gh`
- **Linux**: See https://github.com/cli/cli/blob/trunk/docs/install_linux.md
- **Windows**: `winget install --id GitHub.cli` or `choco install gh`

**Authentication**:

```bash
# Login to GitHub
gh auth login

# Follow prompts to authenticate
```

**Verify Setup**:

```bash
# Check authentication status
gh auth status

# Should show you're logged in
```

---

## Automated Workflows

For comprehensive automated handling of PR comments, use these specialized commands:

### 1. Review PR Comments (`/review-my-pr`)
```bash
# Automatically extract and categorize all PR comments
/review-my-pr https://github.com/owner/repo/pull/NUMBER
```
This command will:
- Fetch all PR comments
- Filter out resolved/outdated comments
- Categorize by severity (Critical/Major/Minor)
- Generate actionable fix commands
- Create detailed reports

### 2. Fix PR Issues (`/fix-my-pr`)
```bash
# Automatically apply fixes and mark comments as resolved
/fix-my-pr https://github.com/owner/repo/pull/NUMBER
```
This command will:
- Execute all generated fix commands
- Apply code changes
- Verify changes (linting, compilation)
- Mark comments as resolved on GitHub
- Generate execution reports

---

## Manual Steps (if not using automated workflows)

1. **Sync and audit comments**
    - Pull the latest branch changes
      ```bash
      git pull origin <branch-name>
      ```
    - View PR comments using GitHub CLI
      ```bash
      # View PR in terminal
      gh pr view <PR-NUMBER>
      
      # View PR in browser
      gh pr view <PR-NUMBER> --web
      
      # List all comments
      gh pr view <PR-NUMBER> --comments
      
      # View specific comment
      gh api repos/{owner}/{repo}/pulls/<PR-NUMBER>/comments
      ```
    - Open the PR conversation view and read every unresolved comment
    - Group comments by affected files or themes

2. **Plan resolutions**
    - List the requested code edits for each thread
    - Identify clarifications or additional context you must provide
    - Note any dependencies or blockers before implementing changes
    - Use GitHub CLI to view diff
      ```bash
      gh pr diff <PR-NUMBER>
      ```

3. **Implement fixes**
    - Apply targeted updates addressing one comment thread at a time
    - Run relevant tests or linters after impactful changes
    - Stage changes with commits that reference the addressed feedback
      ```bash
      # Commit with reference to PR
      git commit -m "Address review comment: add error handling"
      
      # Push changes
      git push origin <branch-name>
      ```

4. **Draft responses**
    - Respond to comments using GitHub CLI
      ```bash
      # Add a comment to PR
      gh pr comment <PR-NUMBER> --body "Fixed the error handling as requested"
      
      # Reply to a specific review comment (use comment ID from API)
      gh api repos/{owner}/{repo}/pulls/comments/{comment-id}/replies \
        -f body="Done! Updated in commit abc123"
      ```
    - Summarize the action taken or reasoning provided for each comment
    - Link to commits or lines when clarification helps reviewers verify
      ```bash
      # Get commit SHA
      git rev-parse HEAD
      
      # Reference in comment: "Fixed in commit abc123"
      ```
    - Highlight any remaining questions or follow-up needs
    
5. **Mark conversations as resolved**
    - Use GitHub CLI to resolve threads
      ```bash
      # Mark review thread as resolved (requires thread ID)
      gh api graphql -f query='
      mutation {
        resolveReviewThread(input: {threadId: "THREAD_ID"}) {
          thread {
            id
            isResolved
          }
        }
      }'
      ```
    - Or resolve manually via GitHub web UI

6. **Request re-review**
    - After addressing comments, request re-review
      ```bash
      # Request review from specific reviewer
      gh pr edit <PR-NUMBER> --add-reviewer username
      
      # Or request re-review programmatically
      gh api repos/{owner}/{repo}/pulls/<PR-NUMBER>/requested_reviewers \
        -f reviewers[]='username1' \
        -f reviewers[]='username2'
      ```

---

## Useful GitHub CLI Commands for PR Comments

### Viewing Comments
```bash
# View PR with all comments
gh pr view <PR-NUMBER> --comments

# View PR in browser to see comments
gh pr view <PR-NUMBER> --web

# Check PR status
gh pr status

# View diff
gh pr diff <PR-NUMBER>
```

### Responding to Comments
```bash
# Add general PR comment
gh pr comment <PR-NUMBER> --body "Updated based on your feedback"

# Add comment from file
gh pr comment <PR-NUMBER> --body-file response.md

# Add comment with multiple lines
gh pr comment <PR-NUMBER> --body "
Line 1 of comment
Line 2 of comment
Line 3 of comment
"
```

### Managing Review Status
```bash
# Check review status
gh pr checks <PR-NUMBER>

# View reviewers
gh pr view <PR-NUMBER> --json reviewRequests

# Add reviewers
gh pr edit <PR-NUMBER> --add-reviewer username1,username2

# Remove reviewer
gh pr edit <PR-NUMBER> --remove-reviewer username
```

### After Fixes
```bash
# Mark PR as ready for review
gh pr ready <PR-NUMBER>

# Check if all comments are addressed
gh pr view <PR-NUMBER> --comments | grep -i "pending"

# View CI/check status
gh pr checks <PR-NUMBER>
```

---

## Response Checklist

- [ ] All reviewer comments acknowledged
- [ ] Required code changes implemented and tested
  - [ ] Run tests: `npm test` or equivalent
  - [ ] Run linter: `npm run lint` or equivalent
  - [ ] Verify build: `npm run build` or equivalent
- [ ] Clarifying explanations prepared for nuanced threads
- [ ] Follow-up items documented or escalated
- [ ] PR status updated for reviewers
- [ ] Responses posted to each addressed comment
- [ ] Conversations marked as resolved where appropriate
- [ ] Re-review requested if needed

---

## Best Practices

1. **Be Responsive**
   - Address comments within 24-48 hours
   - Let reviewers know if a fix will take longer

2. **Be Clear**
   - Explain what changed and why
   - Link to specific commits for each fix
   - Use code blocks in responses for clarity

3. **Be Thorough**
   - Don't cherry-pick easy comments
   - Address or acknowledge every comment
   - Ask for clarification if needed

4. **Test Your Changes**
   - Verify each fix works correctly
   - Run full test suite before pushing
   - Check for regressions

5. **Communicate Blockers**
   - If you disagree with a comment, explain respectfully
   - If a fix requires more discussion, start a conversation
   - Tag specific people for input if needed

---

## Quick Reference

### Automated (Recommended)
```bash
# Step 1: Review all comments and generate fix commands
/review-my-pr https://github.com/owner/repo/pull/123

# Step 2: Apply all fixes automatically
/fix-my-pr https://github.com/owner/repo/pull/123
```

### Manual Process
```bash
# 1. Pull latest
git pull origin <branch>

# 2. View comments
gh pr view <PR-NUMBER> --comments --web

# 3. Make fixes
# ... edit files ...

# 4. Test changes
npm test

# 5. Commit with reference
git commit -m "Address review: add error handling"
git push

# 6. Respond to comments
gh pr comment <PR-NUMBER> --body "Fixed in latest commit"

# 7. Request re-review
gh pr edit <PR-NUMBER> --add-reviewer username
```

---

## Notes

- Use automated workflows (`/review-my-pr` and `/fix-my-pr`) for comprehensive handling
- GitHub CLI handles authentication automatically after `gh auth login`
- All comments, even minor ones, deserve acknowledgment
- Mark conversations as resolved only after fixes are pushed
- Keep responses professional and constructive
- Link to specific commits or code when responding
