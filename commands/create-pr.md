# Create PR

## Overview

Create a well-structured pull request with proper description, labels, and
reviewers using GitHub CLI.

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

## Steps

1. **Prepare branch**
    - Ensure all changes are committed
      ```bash
      git status  # Verify no uncommitted changes
      git add .   # Stage if needed
      git commit -m "Your commit message"
      ```
    - Push branch to remote
      ```bash
      git push origin <branch-name>
      # or if first push:
      git push -u origin <branch-name>
      ```
    - Verify branch is up to date with main
      ```bash
      git fetch origin main
      git log HEAD..origin/main  # Should show no commits if up to date
      ```

2. **Write PR description**
    - Summarize changes clearly
    - Include context and motivation
    - List any breaking changes
    - Add screenshots if UI changes
    - Use `/generate-pr-description` command for help

3. **Create PR using GitHub CLI**
    
    **Option A: Interactive Mode (Recommended)**
    ```bash
    gh pr create
    ```
    This will:
    - Prompt for PR title
    - Prompt for PR description (opens editor)
    - Ask which branch to merge into (default: main)
    - Optionally add reviewers and labels interactively
    
    **Option B: Command Line Mode**
    ```bash
    # Basic PR creation
    gh pr create --title "Your PR Title" --body "Your PR description"
    
    # With reviewers
    gh pr create \
      --title "Add user authentication" \
      --body "Implements JWT-based auth with refresh tokens" \
      --reviewer username1,username2
    
    # With labels and assignees
    gh pr create \
      --title "Add user authentication" \
      --body "Implements JWT-based auth" \
      --reviewer username1 \
      --label "enhancement,backend" \
      --assignee @me
    
    # Specify base branch
    gh pr create \
      --title "Add user authentication" \
      --body "Implements JWT-based auth" \
      --base develop  # Target branch
    
    # Open in browser after creation
    gh pr create --title "Your Title" --body "Description" --web
    ```
    
    **Option C: Use Template File**
    ```bash
    # Create description in a file first
    cat > pr_description.md << 'EOF'
    ## What & Why
    This PR adds user authentication...
    
    ## Changes
    - Added JWT middleware
    - Created auth endpoints
    
    ## Testing
    - Unit tests added
    - Manual testing completed
    EOF
    
    # Create PR using the file
    gh pr create --title "Add user authentication" --body-file pr_description.md
    ```

4. **Additional PR commands**
    
    ```bash
    # View PR status
    gh pr status
    
    # View your PR in browser
    gh pr view --web
    
    # List your PRs
    gh pr list --author @me
    
    # Add labels after creation
    gh pr edit <PR-NUMBER> --add-label "bug,urgent"
    
    # Add reviewers after creation
    gh pr edit <PR-NUMBER> --add-reviewer username1,username2
    
    # Add assignees
    gh pr edit <PR-NUMBER> --add-assignee @me
    
    # Set PR to draft
    gh pr ready --undo <PR-NUMBER>
    
    # Mark PR as ready for review
    gh pr ready <PR-NUMBER>
    
    # Request review from specific team
    gh pr edit <PR-NUMBER> --add-reviewer org/team-name
    ```

## PR Description Template

Use this template when creating your PR description:

```markdown
## 🎯 What & Why

### Problem
[Describe the problem this PR solves]

### Solution
[Explain your approach and why]

## 📝 Changes Made

- [ ] Core changes listed
- [ ] Database changes (if any)
- [ ] Breaking changes (if any)

## ✅ Testing

- [ ] Unit tests pass
- [ ] Manual testing completed
- [ ] Verified on [environment]

## 📋 Checklist

- [ ] Code follows project standards
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] No console errors
- [ ] Ready for review
```

---

## Quick Reference

### Create PR with all options:
```bash
gh pr create \
  --title "Feature: Add user authentication" \
  --body "Implements JWT authentication with refresh tokens. Fixes #123" \
  --base main \
  --reviewer username1,username2 \
  --assignee @me \
  --label "feature,backend" \
  --milestone "v2.0" \
  --web
```

### Common flags:
- `--title` or `-t`: PR title
- `--body` or `-b`: PR description
- `--body-file` or `-F`: Read description from file
- `--base` or `-B`: Target branch (default: main)
- `--reviewer` or `-r`: Request reviewers (comma-separated)
- `--assignee` or `-a`: Assign people (comma-separated, use `@me` for yourself)
- `--label` or `-l`: Add labels (comma-separated)
- `--milestone` or `-m`: Set milestone
- `--draft` or `-d`: Create as draft PR
- `--web` or `-w`: Open in browser after creation
- `--fill`: Use commit info for title and body

### Useful after PR creation:
```bash
# View PR
gh pr view [PR-NUMBER]

# Edit PR
gh pr edit [PR-NUMBER]

# Close PR
gh pr close [PR-NUMBER]

# Reopen PR
gh pr reopen [PR-NUMBER]

# Merge PR
gh pr merge [PR-NUMBER]

# Check PR status
gh pr status

# Check PR checks/CI status
gh pr checks [PR-NUMBER]

# Comment on PR
gh pr comment [PR-NUMBER] --body "Your comment"

# Review PR
gh pr review [PR-NUMBER] --approve
gh pr review [PR-NUMBER] --request-changes --body "Please fix..."
gh pr review [PR-NUMBER] --comment --body "Looks good but..."
```

---

## Notes

- GitHub CLI respects `.github/PULL_REQUEST_TEMPLATE.md` if it exists
- Use `--fill` flag to auto-populate from commit messages
- Use `--draft` to create draft PRs that can't be merged yet
- PR URLs are automatically copied to clipboard after creation
- Use `/generate-pr-description` command for help writing comprehensive descriptions
