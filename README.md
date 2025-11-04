# Cursor Commands

> This project is based on [CursorCommands by AlexZaccaria](https://github.com/AlexZaccaria/CursorCommands/blob/main/README.md)

Custom commands and configuration for Cursor AI editor.

## 🎯 Quick Start

This command suite is designed to streamline your development workflow using **GitHub CLI (`gh`)** for all GitHub operations.

### Prerequisites

You need **GitHub CLI** installed and authenticated:

1. **Install GitHub CLI**

   ```bash
   # macOS
   brew install gh
   
   # Linux
   # See https://github.com/cli/cli/blob/trunk/docs/install_linux.md
   
   # Windows
   winget install --id GitHub.cli
   # or
   choco install gh
   ```

2. **Authenticate with GitHub**

   ```bash
   gh auth login
   ```

   Follow the prompts to authenticate (browser-based login recommended).

3. **Verify Setup**

   ```bash
   # Test your GitHub CLI access
   ./commands/test_gh_access.sh
   
   # Or test access to a specific repository
   ./commands/test_gh_access.sh owner/repo
   
   # Or test access to a specific PR
   ./commands/test_gh_access.sh owner/repo 123
   ```

---

## 📋 Available Commands

### PR Review & Fixes

- **`/review-my-pr <url>`** - Analyze all PR review comments and generate fix commands
  ```bash
  /review-my-pr https://github.com/owner/repo/pull/123
  ```

- **`/fix-my-pr <url>`** - Automatically apply fixes and mark comments as resolved
  ```bash
  /fix-my-pr https://github.com/owner/repo/pull/123
  ```

- **`/address-github-pr-comments <url>`** - Manual workflow for addressing comments
  ```bash
  /address-github-pr-comments https://github.com/owner/repo/pull/123
  ```

- **`/create-pr`** - Create a new pull request
  ```bash
  # Interactive mode
  gh pr create
  
  # With options
  gh pr create --title "Feature" --body "Description" --reviewer user1,user2
  ```

### Code Review & Quality

- **`/review-my-branch`** - Review all changes on your branch
- **`/review-my-changes`** - Review local changes before committing
- **`/code-review`** - Comprehensive code review workflow
- **`/write-unit-tests`** - Generate and write unit tests
- **`/add-error-handling`** - Add comprehensive error handling
- **`/security-review`** - Security audit of your code
- **`/accessibility-audit`** - Accessibility audit of UI components

### Development Workflow

- **`/setup-new-feature`** - Initialize a new feature branch with structure
- **`/fix-compile-errors`** - Identify and fix compilation errors
- **`/fix-git-issues`** - Fix git-related issues
- **`/lint-fix`** - Run linting and auto-fix issues
- **`/debug-issue`** - Debug workflow for complex issues
- **`/optimize-performance`** - Performance optimization analysis

### Documentation & API

- **`/add-documentation`** - Generate documentation
- **`/generate-pr-description`** - Create comprehensive PR descriptions
- **`/generate-api-docs`** - Generate API documentation

---

## 🔐 Security

All GitHub operations use **GitHub CLI** which handles authentication securely:

- ✅ Credentials stored in system keychain (not in files)
- ✅ OAuth tokens with granular permissions
- ✅ No credentials in repository
- ✅ Automatic token refresh
- ✅ Single authentication (`gh auth login`)

**Never commit credentials to git.** GitHub CLI keeps your credentials secure.

---

## 🧪 Testing GitHub CLI Access

Before using the commands, verify your GitHub CLI setup:

```bash
# Run the test script
./commands/test_gh_access.sh
```

This checks:
- GitHub CLI is installed
- You're authenticated
- API access works
- Rate limits are OK
- You have the necessary permissions

Test with a specific repository:
```bash
./commands/test_gh_access.sh owner/repo
```

Test with a specific PR:
```bash
./commands/test_gh_access.sh owner/repo 123
```

---

## 🚀 Typical Workflow

### 1. Create a PR

```bash
# Make changes and commit
git add .
git commit -m "Your changes"

# Create PR using gh CLI
gh pr create --title "Your PR title" --body "Description"

# Or use the helper command
/generate-pr-description
```

### 2. Get Feedback

Once reviewers comment on your PR, use:

```bash
# Review all comments (generates fix commands)
/review-my-pr https://github.com/owner/repo/pull/123

# Or manually address comments
/address-github-pr-comments https://github.com/owner/repo/pull/123
```

### 3. Apply Fixes

```bash
# Automatically apply all fixes
/fix-my-pr https://github.com/owner/repo/pull/123

# This will:
# - Apply code fixes
# - Verify changes
# - Mark comments as resolved on GitHub
# - Generate a report
```

### 4. Request Re-Review

```bash
# Reviewers automatically get notifications
# Or manually request re-review
gh pr edit 123 --add-reviewer user1,user2
```

---

## 📚 Additional Resources

- [GitHub CLI Documentation](https://cli.github.com/)
- [GitHub CLI Manual](https://cli.github.com/manual/)
- [Creating Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens)

---

## 💡 Tips

1. **Use the test script first** - Run `./commands/test_gh_access.sh` to verify setup
2. **Read command headers** - Each command file has detailed instructions
3. **Start with `/review-my-pr`** - This is the foundation of the workflow
4. **Chain commands** - Use `/review-my-pr` then `/fix-my-pr` for full automation
5. **Check gh help** - Run `gh --help` or `gh pr --help` for CLI documentation

---

## ❓ Troubleshooting

**"gh: command not found"**
- Install GitHub CLI: `brew install gh` (macOS)

**"Not authenticated"**
- Run: `gh auth login`

**"API access failed"**
- Run: `./commands/test_gh_access.sh` to diagnose

**"Permission denied"**
- Your token may lack permissions
- Run: `gh auth login` again to re-authenticate

---

## 📝 Notes

- All commands use GitHub CLI (no credential files)
- Authentication is secure and managed by GitHub CLI
- Each command is self-contained and can be used independently
- Commands work with any GitHub-hosted repository you have access to
