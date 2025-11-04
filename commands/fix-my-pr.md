# Fix My PR

## Purpose

Automatically apply fixes for all PR review comments, verify the changes, and mark comments as resolved on GitHub. This closes the feedback loop fast, letting you iterate quickly on reviewer feedback.

**Context**: Addressing PR feedback manually is time-consuming and error-prone. You might miss comments, forget to mark them resolved, or introduce bugs while fixing. This automated workflow systematically processes every comment, applies fixes carefully, verifies correctness, and keeps GitHub in sync.

## Critical Execution Principles

You are executing fixes for PR review comments. Follow these principles throughout:

1. **Never speculate about code - read before changing**

   - ALWAYS read the current file state completely before applying fixes
   - Don't assume you know what's there based on the comment alone
   - Code may have changed since the comment was written
   - **WHY**: Blind fixes on stale assumptions break working code

2. **Understand the comment intent, don't just pattern-match**

   - Read the reviewer's comment carefully
   - Understand WHY they want the change
   - Consider whether their suggestion is the best fix
   - **WHY**: Reviewers sometimes suggest suboptimal solutions; your job is to fix the ROOT issue

3. **Apply fixes thoughtfully, verify thoroughly**

   - Make minimal changes that address the issue
   - Don't refactor unrelated code
   - Verify syntax, types, and logic after each change
   - **WHY**: Rushed fixes introduce new bugs

4. **Mark resolved ONLY after successful fix**

   - Never mark a comment as resolved before applying the fix
   - Verify the fix actually addresses the comment
   - If fix fails, document why and don't mark resolved
   - **WHY**: Marking unresolved items creates confusion

5. **Work sequentially for correctness**
   - Process action commands one at a time (critical → major → minor)
   - Verify each fix before moving to next
   - Don't skip verification steps to go faster
   - **WHY**: Sequential processing prevents cascading failures

**Objective**: Execute all pending action commands, apply fixes to code, verify correctness, and mark GitHub comments as resolved.

**Usage**: `/fix-my-pr https://github.com/owner/repo/pull/NUMBER`

⚠️ **IMPORTANT**: PR URL is REQUIRED. The command will fail if no URL is provided.

---

## 📁 Input/Output Files

**Input Files**:

- `.cursor/commands/action-pr-[PR-NUMBER]-comment-[N]-[timestamp].md` - Action commands to execute

**Output Files**:

- `.cursor/fixes/fix-report-pr-[PR-NUMBER]-[YYYYMMDD-HHMMSS].md` - Complete execution report
- `.cursor/fixes/fix-log-pr-[PR-NUMBER]-comment-[N]-[timestamp].md` - Individual fix logs

**Important**:

- **⚠️ Previous fix logs for this PR are AUTOMATICALLY DELETED at start (cleanup is mandatory)**
- All fixes are executed sequentially (one at a time)
- Each fix is verified before moving to next
- Resolved comments are marked on GitHub automatically
- **⚠️ Action commands are AUTOMATICALLY DELETED after processing (cleanup is mandatory)**
- Timestamp format: `YYYYMMDD-HHMMSS` (e.g., `20251014-153045`)

**🤖 AI Instructions (MANDATORY)**:

0. **VALIDATE PR URL** - Parse PR URL from user input and extract PR number (REQUIRED - stop if missing)
1. **CLEANUP OLD FIX LOGS** - Delete all previous fix reports and logs for THIS PR number using `delete_file` tool
2. Scan `.cursor/commands/` for all `action-pr-[PR-NUMBER]-*.md` files
3. **IF NO ACTION COMMANDS FOUND**: Auto-execute `/review-my-pr [PR-URL]` first, then retry scan
4. Parse each action command file to extract fix requirements
5. Apply fixes to code files
6. Verify changes (linting, compilation)
7. Mark comments as resolved on GitHub via GitHub CLI
8. Generate comprehensive execution report
9. **⚠️ CLEANUP ACTION COMMANDS (CRITICAL)**: DELETE all processed action command files using `delete_file` tool - THIS STEP IS MANDATORY AND MUST NOT BE SKIPPED

---

## 🔐 Prerequisites

### GitHub CLI Setup

**Required Tool**: GitHub CLI (`gh`)

**Installation**:

- **macOS**: `brew install gh`
- **Linux**: See https://github.com/cli/cli/blob/trunk/docs/install_linux.md
- **Windows**: `winget install --id GitHub.cli` or `choco install gh`

**Authentication**:

After installing, authenticate with GitHub:

```bash
# Login to GitHub
gh auth login

# Follow prompts:
# - Select: GitHub.com
# - Protocol: HTTPS
# - Authenticate: Login with web browser (recommended)
```

**Verify Setup**:

```bash
# Check authentication status
gh auth status

# Should show:
# ✓ Logged in to github.com as <username>
# ✓ Token: *******************
```

**Required Permissions**:

The `gh` CLI needs access to:
- Read repository contents
- Read PR data and comments
- Write PR comments (for marking as resolved)

These are typically granted during `gh auth login`.

⚠️ **IMPORTANT**: Token MUST have write permissions to mark comments as resolved.

---

## Workflow

### Pre-Step 0: Validate and Parse PR URL

**Action**: Validate that PR URL was provided and extract PR information.

⚠️ **CRITICAL**: This step is MANDATORY and must succeed before any other action.

**🤖 AI Actions (MANDATORY)**:

1. Check if user provided PR URL in command
2. If NO URL provided:
   - **STOP IMMEDIATELY**
   - Display error message explaining URL is required
   - Show correct usage example
   - Exit workflow
3. If URL provided:
   - Extract PR number using regex
   - Extract repository owner and name
   - Validate URL format
   - Store PR number for session

**Expected Input Format**:

- Full URL: `https://github.com/owner/repo/pull/NUMBER`
- Short URL: `github.com/owner/repo/pull/NUMBER`

**Regex Pattern**:

```bash
# Extract PR number
echo "https://github.com/owner/repo/pull/582" | grep -oE 'pull/([0-9]+)' | cut -d'/' -f2
```

**Verification Checklist**:

- [ ] PR URL provided by user (if not: STOP)
- [ ] URL format is valid GitHub PR URL
- [ ] PR number extracted successfully
- [ ] Repository owner/name extracted

**Completion Criteria**:

- ✅ PR URL validated and parsed successfully
- ⛔ If URL missing: Stop and show error message (see below)
- ⛔ If URL invalid: Stop and report "Invalid GitHub PR URL"

**🤖 Error Output (if URL missing) - MANDATORY**:

Display this to user and STOP:

```
═══════════════════════════════════════════════════════════════
❌ ERROR: PR URL REQUIRED
═══════════════════════════════════════════════════════════════

The /fix-my-pr command requires the Pull Request URL as a parameter.

## ❌ Error

The PR URL was not provided. The command cannot continue without this required parameter.

## ✅ Correct Usage

/fix-my-pr https://github.com/owner/repo/pull/NUMBER

## 🔍 Why Is It Required?

The PR URL is necessary to:
1. ✅ Identify which PR to process
2. ✅ Find the correct action commands (action-pr-NUMBER-*.md)
3. ✅ Auto-execute /review-my-pr if there are no action commands
4. ✅ Mark comments as resolved on GitHub
5. ✅ Generate correct reports

## 🚀 Next Steps

1. Find your Pull Request URL on GitHub
2. Copy the complete URL
3. Run: /fix-my-pr [PR-URL]

═══════════════════════════════════════════════════════════════
EXECUTION STOPPED
═══════════════════════════════════════════════════════════════
```

**🤖 AI Report Output (if URL valid) - MANDATORY**:

```
📋 Pre-Step 0 Complete - PR URL Validated

Status: ✅ Success

Input URL: [original-url]
PR Number: [N]
Repository: [owner/repo]
Owner: [owner]
Repo Name: [repo]

Next Step: Proceed to Pre-Step 1 - Cleanup Previous Fix Sessions

---
```

---

### Pre-Step 1: Cleanup Previous Fix Sessions

**Action**: Clean up previous fix session files for THIS specific PR number only.

⚠️ **IMPORTANT**: This prevents duplicate or stale fix logs from previous runs.

**🤖 AI Actions (MANDATORY)**:

1. Scan `.cursor/fixes/` directory for files matching this PR number
2. Delete files matching pattern: `.cursor/fixes/fix-report-pr-[PR-NUMBER]-*.md`
3. Delete files matching pattern: `.cursor/fixes/fix-log-pr-[PR-NUMBER]-*.md`
4. **USE THE `delete_file` TOOL** for each file (not bash commands)
5. Preserve fix logs from OTHER PR numbers

**Deletion Method**:
⚠️ **YOU MUST USE THE `delete_file` TOOL** - Do NOT use terminal commands

**Commands to identify files**:

```bash
# List fix reports for this PR
ls -1 .cursor/fixes/fix-report-pr-[PR-NUMBER]-*.md 2>/dev/null

# List fix logs for this PR
ls -1 .cursor/fixes/fix-log-pr-[PR-NUMBER]-*.md 2>/dev/null

# Count files to be removed
FILES_COUNT=$(ls -1 .cursor/fixes/fix-report-pr-[PR-NUMBER]-*.md .cursor/fixes/fix-log-pr-[PR-NUMBER]-*.md 2>/dev/null | wc -l)
```

**Deletion Process**:

```
STEP 1: Scan for existing fix files for this PR
  - Find all: .cursor/fixes/fix-report-pr-[PR-NUMBER]-*.md
  - Find all: .cursor/fixes/fix-log-pr-[PR-NUMBER]-*.md

STEP 2: For EACH file found, call delete_file tool
  delete_file(target_file=".cursor/fixes/fix-report-pr-582-20251014-153045.md")
  delete_file(target_file=".cursor/fixes/fix-log-pr-582-comment-1-20251014-153045.md")
  delete_file(target_file=".cursor/fixes/fix-log-pr-582-comment-2-20251014-153045.md")
  ... (continue for all files)

STEP 3: Verify deletion
  - Confirm each file was deleted successfully
  - Report count of files removed
```

**Verification Checklist**:

- [ ] PR-specific fix report files deleted
- [ ] PR-specific fix log files deleted
- [ ] Other PR fix files preserved (different PR numbers)
- [ ] `delete_file` tool used for each file
- [ ] Deletion confirmed for each file

**Completion Criteria**:

- ✅ Cleanup completed successfully
- ✅ Ready for new fix session
- ✅ Old fix logs removed to avoid confusion

**🤖 AI Report Output (MANDATORY)**:

```
🧹 Pre-Step 1 Complete - Cleanup Previous Fix Sessions

Status: ✅ Success

Files Removed for PR #[PR-NUMBER]:
- fix-report-pr-[PR-NUMBER]-*.md: [N] files deleted
- fix-log-pr-[PR-NUMBER]-*.md: [N] files deleted

Total: [N] files deleted

Other PR fix logs: Preserved
Ready to start new fix session.

Next Step: Proceed to Pre-Step 2 - Initialize Fix Session

---
```

**Why Clean Up Previous Fix Sessions?**:

1. **Avoid confusion**: Old fix logs might reference outdated code
2. **Prevent duplicates**: Fresh start for each fix session
3. **Clean audit trail**: Each session has its own complete logs
4. **Preserve other PRs**: Only removes logs for THIS PR number

**What's Removed**:

- ❌ Old fix reports: `.cursor/fixes/fix-report-pr-[PR-NUMBER]-*.md`
- ❌ Old fix logs: `.cursor/fixes/fix-log-pr-[PR-NUMBER]-*.md`

**What's Preserved**:

- ✅ Fix logs from other PRs (different PR numbers)
- ✅ Action commands in `.cursor/commands/` (handled separately)
- ✅ Review reports in `.cursor/reviews/` (separate workflow)

---

### Pre-Step 2: Initialize Fix Session

**Action**: Create session report file and prepare execution environment.

**🤖 AI Actions (MANDATORY)**:

1. Generate timestamp: `YYYYMMDD-HHMMSS`
2. Create directory: `.cursor/fixes/` (if not exists)
3. Create main report file: `.cursor/fixes/fix-report-pr-[PR-NUMBER]-[timestamp].md`
4. Initialize report file with header

**Report Header Template**:

```markdown
# PR Fix Report - PR #[PR-NUMBER]

**Date**: [date]
**Timestamp**: [timestamp]
**PR**: #[PR-NUMBER]
**Session Started**: [timestamp]

---
```

**Completion Criteria**:

- ✅ Fix report file created
- ✅ Session timestamp stored
- ✅ Ready to scan for action commands

**🤖 AI Report Output (MANDATORY)**:

```
📋 Pre-Step 2 Complete - Fix Session Initialized

Status: ✅ Success

Report File: .cursor/fixes/fix-report-pr-[PR-NUMBER]-[timestamp].md
Timestamp: [timestamp]
PR Number: [N]

Next Step: Proceed to Pre-Step 3 - Validate GitHub CLI

---
```

**🤖 AI Action**: Append this report to the main fix report file

---

### Pre-Step 3: Validate GitHub CLI

**Action**: Check if GitHub CLI is installed and authenticated with write permissions.

**🤖 AI Actions (MANDATORY)**:

1. Check if `gh` CLI is installed
2. Verify authentication status
3. Test write permissions with a simple API call

**Commands**:

```bash
# Check if gh is installed
which gh || echo "❌ GitHub CLI not installed"

# Check authentication status
gh auth status

# Refresh auth token to ensure it's valid
gh auth refresh -h github.com
```

**Verification Checklist**:

- [ ] `gh` CLI is installed
- [ ] User is authenticated
- [ ] Token is valid
- [ ] Token has write permissions

**Completion Criteria**:

- ✅ GitHub CLI validated and ready
- ⛔ If gh not installed: Stop and provide installation instructions
- ⛔ If not authenticated: Stop and provide auth instructions

**🤖 AI Report Output (MANDATORY)**:

```
📋 Pre-Step 3 Complete - GitHub CLI Validated

Status: [✅ Success / ❌ Failed]

GitHub CLI Version: [version]
Authentication: [✅ Authenticated as <username> / ❌ Not authenticated]
Write Permissions: [✅ Confirmed / ❌ Missing]

[If failed, show setup instructions:]
To install GitHub CLI:
- macOS: brew install gh
- Linux: https://github.com/cli/cli/blob/trunk/docs/install_linux.md
- Windows: winget install --id GitHub.cli

To authenticate:
gh auth login

Next Step: Proceed to Step 1 - Scan Action Commands

---
```

**🤖 AI Action**: Append this report to the main fix report file

---

### Step 1: Scan and Parse Action Commands

**Action**: Find all action command files and parse them to create an execution plan.

**🤖 AI Actions (MANDATORY)**:

1. Scan `.cursor/commands/` directory
2. Find all files matching pattern: `action-pr-[PR-NUMBER]-*.md`
3. Parse each file to extract:
   - PR Number
   - Comment Number
   - Thread ID (for marking as resolved)
   - Comment Database ID
   - Severity (Critical/Major/Minor)
   - Category
   - Affected files
   - Fix instructions
   - Comment URL
4. Sort by severity: Critical → Major → Minor
5. Create execution plan

**Commands**:

```bash
# Find all action command files for this PR
ls -1 .cursor/commands/action-pr-[PR-NUMBER]-*.md 2>/dev/null | sort

# Count action commands
ls -1 .cursor/commands/action-pr-[PR-NUMBER]-*.md 2>/dev/null | wc -l
```

**Action Command Parse Structure**:

```json
{
  "file_path": ".cursor/commands/action-pr-582-comment-1-20251014-153045.md",
  "pr_number": 582,
  "comment_number": 1,
  "thread_id": "PRRT_kwDOA...",
  "comment_database_id": 12345,
  "severity": "critical|major|minor",
  "category": "bug|architecture|code-quality|documentation",
  "affected_files": ["path/to/file1.tsx", "path/to/file2.ts"],
  "fix_instructions": ["Step 1: ...", "Step 2: ...", "Step 3: ..."],
  "comment_url": "https://github.com/owner/repo/pull/582#discussion_r12345",
  "comment_text": "Original comment text",
  "author": "reviewer-username",
  "status": "pending"
}
```

**Verification Checklist**:

- [ ] All action command files found
- [ ] Each file parsed successfully
- [ ] Thread IDs extracted (MANDATORY for marking as resolved)
- [ ] Severity levels identified
- [ ] Files sorted by severity
- [ ] Execution plan created

**Completion Criteria**:

- ✅ All action commands parsed
- ✅ Execution plan ready
- ⛔ If no action commands found: Auto-execute `/review-my-pr` first (see Step 1.1 below)

---

#### Step 1.1: Auto-Execute Review (if no action commands found)

**Trigger**: No `action-pr-[PR-NUMBER]-*.md` files found in `.cursor/commands/`

**Action**: Automatically execute `/review-my-pr` to generate action commands, then retry scan.

⚠️ **IMPORTANT**: This step only executes if Step 1 found ZERO action commands.

**🤖 AI Actions (MANDATORY)**:

1. Report "No action commands found for PR #[N]"
2. Display message: "Auto-executing /review-my-pr to generate action commands..."
3. **Execute the complete `/review-my-pr` workflow** with the PR URL from Pre-Step 0
4. Wait for `/review-my-pr` to complete
5. Retry Step 1 scan for action commands
6. If action commands now exist: Continue to Step 2
7. If still no action commands: Report "No actionable comments in PR" and exit gracefully

**Display to User (before executing review-my-pr)**:

```
⚠️ No Action Commands Found

Status: ℹ️ Auto-executing /review-my-pr

No action commands found for PR #[N] in .cursor/commands/

This means either:
1. You haven't run /review-my-pr yet, OR
2. All previous action commands have been processed and removed

📋 Auto-executing /review-my-pr to scan PR comments...
🔗 PR URL: [url]

▶️ Starting PR review...

---
```

**Then Execute Complete review-my-pr Workflow**:

- Run ALL steps from `/review-my-pr` command
- Generate action commands for all actionable comments
- Wait for completion

**After review-my-pr Completes**:

Append to fix report:

```
✅ /review-my-pr Completed

Status: ✅ Success

Action Commands Generated: [N]
- 🔴 Critical: [N]
- 🟡 Major: [N]
- 🟢 Minor: [N]

Files:
- action-pr-[PR-NUMBER]-comment-1-[timestamp].md
- action-pr-[PR-NUMBER]-comment-2-[timestamp].md
- ...

▶️ Resuming /fix-my-pr execution...

---
```

**Retry Scan**:

After review-my-pr completes, automatically retry Step 1:

1. Re-scan `.cursor/commands/` for action files
2. Parse all action commands
3. Create execution plan
4. Continue to Step 2

**If Still No Action Commands**:

Display to user and exit gracefully:

```
ℹ️ No Actionable Comments Found

Status: ✅ Review Complete - No Actions Needed

The PR review completed successfully, but no actionable comments were found.

This means:
✅ All PR comments are informational, questions, or approvals
✅ No fixes are required
✅ PR is ready for merge (if approved)

Summary:
- Total Comments: [N]
- Actionable Comments: 0
- Action Commands Generated: 0

Review Report: .cursor/reviews/review-pr-[PR-NUMBER]-[timestamp].md

═══════════════════════════════════════════════════════════════
EXECUTION COMPLETE - NO ACTION REQUIRED
═══════════════════════════════════════════════════════════════
```

**Completion Criteria**:

- ✅ If no actions initially: `/review-my-pr` executed automatically
- ✅ Scan retried after review completes
- ✅ If actions found: Continue to Step 2
- ✅ If no actions found: Exit gracefully with success message

**🤖 AI Report Output (MANDATORY)**:

```
📋 Step 1 Complete - Action Commands Scanned

Status: ✅ Success

Total Action Commands Found: [N]

Breakdown by Severity:
- 🔴 Critical: [N]
- 🟡 Major: [N]
- 🟢 Minor: [N]

Breakdown by Category:
- 🐛 Bug: [N]
- 🏗️ Architecture: [N]
- 🎨 Code Quality: [N]
- 📝 Documentation: [N]

Execution Plan (in order):

### 🔴 Critical Priority
1. action-pr-[PR-NUMBER]-comment-[N]-[timestamp].md
   - Category: [category]
   - Files: [affected-files]
   - Thread ID: [thread-id] ✅

### 🟡 Major Priority
2. action-pr-[PR-NUMBER]-comment-[N]-[timestamp].md
   - Category: [category]
   - Files: [affected-files]
   - Thread ID: [thread-id] ✅

### 🟢 Minor Priority
3. action-pr-[PR-NUMBER]-comment-[N]-[timestamp].md
   - Category: [category]
   - Files: [affected-files]
   - Thread ID: [thread-id] ✅

Next Step: Proceed to Step 2 - Execute Fixes

---
```

**🤖 AI Action**: Append this report to the main fix report file

---

### Step 2: Execute Fixes (Iterative)

**Action**: For EACH action command, execute the fix, verify, and mark as resolved.

⚠️ **CRITICAL**: This step is ITERATIVE - execute one fix at a time, verify, then move to next.

**🤖 AI Actions (MANDATORY) - FOR EACH ACTION COMMAND**:

---

#### 2.1 Read and Understand Action Command

**Action**: Parse the action command file thoroughly.

**🤖 AI Actions**:

1. Read entire action command file
2. Extract all metadata:
   - Thread ID (MANDATORY)
   - Comment Database ID
   - Affected files
   - Fix instructions
   - Current code (if provided)
   - Expected result
3. Understand the context and requirements
4. Identify the specific changes needed

**Verification**:

- [ ] Action command file read completely
- [ ] Thread ID extracted (CRITICAL - needed for marking resolved)
- [ ] Fix instructions understood
- [ ] Affected files identified

---

#### 2.2 Analyze Current Code

**Action**: Read the current state of affected files to understand context before making changes.

**Context**: Code may have changed since the reviewer left their comment. You must understand the current state, not assume you know what's there.

**🤖 AI Actions**:

**⚠️ CRITICAL: Never speculate - read the actual code**

1. **Read ALL affected files COMPLETELY**

   - Don't just read the specific lines mentioned
   - Read enough context to understand the function/component
   - Note imports, dependencies, surrounding logic
   - **WHY**: The issue might not be where the comment says it is

2. **Locate the specific problem area**

   - Find the lines mentioned in the comment
   - Verify the issue still exists (code may have changed)
   - If the exact lines don't exist, search for similar patterns
   - **WHY**: Line numbers shift as code changes

3. **Understand the current implementation**

   - What does this code currently do?
   - Why was it written this way?
   - What constraints exist (types, dependencies, APIs)?
   - **WHY**: Understanding prevents breaking working code

4. **Identify what needs to change**

   - What's the actual root problem?
   - Is the reviewer's suggestion the best fix?
   - Are there better alternatives?
   - **WHY**: Don't blindly apply suggestions; fix the real issue

5. **Plan the fix approach using extended thinking**
   ```
   What's the minimal change that addresses the issue?
   What could break if I make this change?
   Do I need to update tests, types, or related code?
   Is this fix consistent with the rest of the codebase?
   ```
   **WHY**: Planning prevents hasty fixes that introduce new bugs

**Verification**:

- [ ] All affected files read COMPLETELY
- [ ] Current code understood in context
- [ ] Problem area identified and still exists
- [ ] Root cause identified (may differ from comment)
- [ ] Fix approach planned and makes sense
- [ ] Considered side effects and alternatives

---

#### 2.3 Apply Fix

**Action**: Implement the fix thoughtfully, addressing the root issue while maintaining code quality.

**Context**: This is where you change code. Be surgical - make the minimal change that solves the problem. Don't get creative or "improve" unrelated things.

**🤖 AI Actions (MANDATORY)**:

**Before changing anything**:

- Re-read the reviewer's comment to confirm understanding
- Verify your planned fix addresses their concern
- Consider: "What's the simplest fix that completely solves this?"

**When applying changes**:

1. **Make minimal, focused changes**

   - Fix ONLY what the comment addresses
   - Don't refactor unrelated code
   - Don't "improve" nearby code
   - **WHY**: Scope creep introduces unreviewed changes

2. **Follow the action command instructions, but think**

   - The command provides guidance, not gospel
   - If you see a better way, use it
   - If the suggestion is wrong, fix the real issue
   - **WHY**: You understand context better than automated parsing

3. **Maintain code quality**

   - Match existing code style exactly
   - Preserve indentation and formatting
   - Keep existing patterns and conventions
   - Add proper error handling if needed
   - **WHY**: Consistency matters more than personal preference

4. **Update related code if necessary**

   - Add/update imports if you use new dependencies
   - Update types if TypeScript complains
   - Update related tests if behavior changes
   - Add comments for non-obvious changes
   - **WHY**: Changes often have ripple effects

5. **Preserve existing functionality**
   - Don't change behavior unintentionally
   - Don't remove error handling
   - Don't delete code without understanding why it's there
   - **WHY**: Defensive programming prevents regressions

**Important Rules**:

✅ **DO**:

- Follow language best practices (TypeScript/JavaScript/Python/etc)
- Maintain existing code style
- Add error handling where missing
- Update types to match reality
- Test edge cases mentally

❌ **DON'T**:

- Break existing functionality
- Introduce new bugs
- Skip verification steps
- Refactor unrelated code
- Change patterns without good reason

**Tools to Use**:

- `search_replace` - For precise code changes (preferred)
- `write` - For complete file rewrites (only if necessary)
- `read_file` - To verify changes after applying

**Verification**:

- [ ] Fix applied to all affected files
- [ ] Changes address the reviewer's concern
- [ ] Code style maintained (indentation, naming, patterns)
- [ ] No syntax errors introduced
- [ ] Related code updated (imports, types, tests)
- [ ] No unrelated changes sneaked in

---

#### 2.4 Verify Changes

**Action**: Verify that changes are correct and don't break anything.

**🤖 AI Actions (MANDATORY)**:

1. Check for TypeScript/JavaScript syntax errors
2. Run linter on changed files
3. Verify imports are correct
4. Check that types are valid
5. Ensure no new errors introduced
6. Verify fix addresses the original comment

**Commands**:

```bash
# Check TypeScript compilation
npx tsc --noEmit [file-path]

# Run ESLint on changed file
npx eslint [file-path]

# Or use available linting tools
```

**Verification Checklist**:

- [ ] No syntax errors
- [ ] No linting errors (or only pre-existing ones)
- [ ] TypeScript types are valid
- [ ] Imports are correct
- [ ] Fix addresses original comment
- [ ] No new bugs introduced
- [ ] Code compiles successfully

**Completion Criteria**:

- ✅ All verifications pass
- ⛔ If verification fails: Document issue and attempt to fix, or mark as "needs manual review"

---

#### 2.5 Mark Comment as Resolved on GitHub

**Action**: Mark the GitHub comment thread as resolved using GitHub CLI.

⚠️ **CRITICAL**: This step is MANDATORY and must succeed before moving to next action.

**🤖 AI Actions (MANDATORY)**:

1. Extract Thread ID from action command (parsed in step 2.1)
2. Execute GraphQL mutation via GitHub CLI to mark thread as resolved
3. Verify mutation succeeded
4. Confirm thread is now resolved

**GraphQL Mutation via gh CLI**:

```bash
# Mark thread as resolved using GitHub CLI
THREAD_ID="[THREAD-ID-FROM-ACTION-COMMAND]"

gh api graphql -f query='
mutation {
  resolveReviewThread(input: {threadId: "'$THREAD_ID'"}) {
    thread {
      id
      isResolved
    }
  }
}'
```

**Expected Response**:

```json
{
  "data": {
    "resolveReviewThread": {
      "thread": {
        "id": "PRRT_kwDOA...",
        "isResolved": true
      }
    }
  }
}
```

**Verification**:

```bash
# Verify thread is resolved
gh api graphql -f query='
query {
  node(id: "'$THREAD_ID'") {
    ... on PullRequestReviewThread {
      isResolved
    }
  }
}'
```

**Verification Checklist**:

- [ ] Thread ID extracted correctly
- [ ] GraphQL mutation executed via gh CLI
- [ ] Response received (200 status)
- [ ] Response contains "isResolved": true
- [ ] No errors in response
- [ ] Thread marked as resolved on GitHub

**Completion Criteria**:

- ✅ Thread marked as resolved successfully
- ⛔ If marking fails: Document error, attempt retry (max 3 attempts), or mark as "needs manual resolution"

**Error Handling**:

- If 401/403: Token lacks permissions (run `gh auth refresh`)
- If 404: Thread ID not found (may be outdated)
- If 422: Invalid input (check thread ID format)
- If 500: GitHub API error (retry after delay)

---

#### 2.6 Log Fix Execution

**Action**: Create detailed log for this specific fix.

**🤖 AI Actions (MANDATORY)**:

1. Create individual fix log file
2. Document all changes made
3. Include verification results
4. Record GitHub resolution status
5. Note any issues or warnings

**Fix Log File**: `.cursor/fixes/fix-log-pr-[PR-NUMBER]-comment-[N]-[timestamp].md`

**Fix Log Template**:

````markdown
# Fix Log - PR #[PR-NUMBER] - Comment [N]

**Action Command**: `.cursor/commands/action-pr-[PR-NUMBER]-comment-[N]-[timestamp].md`
**Execution Time**: [timestamp]
**Status**: [✅ Success / ⚠️ Partial / ❌ Failed]

---

## Original Comment

**Author**: @[author]
**Severity**: [severity]
**Category**: [category]
**URL**: [comment-url]

> [original comment text]

---

## Changes Applied

### Files Modified

1. `[file1]`

   - Lines changed: [line-range]
   - Type of change: [description]

2. `[file2]`
   - Lines changed: [line-range]
   - Type of change: [description]

### Detailed Changes

**File**: `[file1]`

```[language]
// Before
[old code]

// After
[new code]
```
````

---

## Verification Results

### Code Verification

- ✅ Syntax check: Passed
- ✅ TypeScript compilation: Passed
- ✅ Linting: Passed (or: [N] pre-existing warnings)
- ✅ Imports: Valid
- ✅ Types: Valid

### Functional Verification

- ✅ Fix addresses original comment
- ✅ No new bugs introduced
- ✅ Code style maintained
- ✅ Related code updated if needed

---

## GitHub Resolution

**Thread ID**: [thread-id]
**Resolution Status**: [✅ Resolved / ❌ Failed]

[If successful]
✅ Comment marked as resolved on GitHub successfully

- Mutation executed at: [timestamp]
- Verification: isResolved = true

[If failed]
❌ Failed to mark as resolved

- Error: [error message]
- Attempted retries: [N]
- Manual resolution required: [comment-url]

---

## Summary

**Status**: [✅ Success / ⚠️ Partial Success / ❌ Failed]

[If success]
✅ Fix applied successfully
✅ All verifications passed
✅ Comment resolved on GitHub

[If partial]
⚠️ Fix applied but with issues:

- [list of issues or warnings]

[If failed]
❌ Fix failed:

- Reason: [failure reason]
- Next steps: [manual actions needed]

---

## Next Steps

[If success]
✅ Moving to next action command

[If issues]
⚠️ Manual review recommended for:

- [specific concerns]

---

```

**Completion Criteria**:
- ✅ Fix log file created
- ✅ All details documented

**🤖 AI Action**: Create fix log file and append summary to main fix report

---

#### 2.7 Update Execution Progress

**Action**: Update main fix report with progress.

**🤖 AI Report Output (MANDATORY)**:

Append to main fix report:

```

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Fix Executed - Comment [N] of [TOTAL]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Status: [✅ Success / ⚠️ Partial / ❌ Failed]

Action Command: action-pr-[PR-NUMBER]-comment-[N]-[timestamp].md
Comment Author: @[author]
Severity: [severity]
Category: [category]

Files Modified:

- [file1]
- [file2]

Verification:

- Code changes: ✅ Applied
- Syntax check: ✅ Passed
- Linting: ✅ Passed
- GitHub resolved: ✅ Marked as resolved

Fix Log: .cursor/fixes/fix-log-pr-[PR-NUMBER]-comment-[N]-[timestamp].md

[If issues]
⚠️ Issues:

- [list of issues]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Progress: [N] of [TOTAL] completed ([percentage]%)

Next: [next-action-command or "Final Report"]

---

```

**Completion Criteria**:
- ✅ Progress updated in main report
- ✅ Ready to move to next action (or final report if last)

---

### Step 2: Iteration Logic

**🤖 AI Actions (MANDATORY)**:

```

FOR EACH action command in execution plan (sorted by severity):

1. Execute Step 2.1 - Read and Understand
2. Execute Step 2.2 - Analyze Current Code
3. Execute Step 2.3 - Apply Fix
4. Execute Step 2.4 - Verify Changes
5. Execute Step 2.5 - Mark as Resolved on GitHub (MANDATORY)
6. Execute Step 2.6 - Log Fix Execution
7. Execute Step 2.7 - Update Progress

IF any step fails critically:
  - Document failure in fix log
  - Mark as "needs manual review"
  - Update progress report
  - CONTINUE to next action (don't stop entire process)

IF all steps succeed:
  - Mark action as completed
  - Move to next action

END FOR

AFTER all actions processed:
  - Proceed to Step 3 - Final Report

```

**Important Notes**:
- Process actions sequentially (one at a time)
- Always verify before moving to next
- Always mark as resolved on GitHub (critical step)
- Don't stop on single failure - continue with remaining actions
- Document all outcomes (success, partial, failure)

---

### Step 3: Generate Final Report

**Action**: Create comprehensive final report with all execution results.

**🤖 AI Actions (MANDATORY)**:
1. Summarize all executed fixes
2. Count successes, failures, warnings
3. List all modified files
4. Provide next steps
5. Display final report to user

**🤖 AI FINAL OUTPUT TO USER (MANDATORY)**:

```markdown
═══════════════════════════════════════════════════════════════
✅ PR FIX EXECUTION COMPLETE
═══════════════════════════════════════════════════════════════

## 📊 Execution Summary

**PR**: #[PR-NUMBER]
**Session Started**: [timestamp]
**Session Completed**: [timestamp]
**Duration**: [duration]

**Full Report**: `.cursor/fixes/fix-report-pr-[PR-NUMBER]-[timestamp].md`

---

## 📋 Actions Processed

**Total Actions**: [N]

### Results Breakdown
- ✅ Successful: [N]
- ⚠️ Partial Success: [N]
- ❌ Failed: [N]
- 🔄 Skipped: [N]

### By Severity
- 🔴 Critical: [N] processed ([N] success, [N] failed)
- 🟡 Major: [N] processed ([N] success, [N] failed)
- 🟢 Minor: [N] processed ([N] success, [N] failed)

### By Category
- 🐛 Bug: [N] fixed
- 🏗️ Architecture: [N] fixed
- 🎨 Code Quality: [N] fixed
- 📝 Documentation: [N] fixed

---

## 📁 Files Modified

Total files changed: [N]

1. `[file1]`
   - Actions applied: [N]
   - Status: ✅ All successful
   - Changes: [brief description]

2. `[file2]`
   - Actions applied: [N]
   - Status: ✅ All successful
   - Changes: [brief description]

[If any files had issues]
⚠️ Files with warnings:
- `[file]`: [warning description]

---

## ✅ GitHub Comments Resolved

**Comments Marked as Resolved**: [N] of [TOTAL]

### Successfully Resolved
1. Comment [N] by @[author] - [comment-url]
2. Comment [N] by @[author] - [comment-url]
...

[If any failed to resolve]
### ⚠️ Failed to Resolve (Manual Action Required)
1. Comment [N] by @[author] - [comment-url]
   - Reason: [error]
   - Action: Please resolve manually via GitHub UI

---

## 🔍 Detailed Fix Logs

Individual fix logs created:
1. `.cursor/fixes/fix-log-pr-[PR-NUMBER]-comment-[N]-[timestamp].md`
2. `.cursor/fixes/fix-log-pr-[PR-NUMBER]-comment-[N]-[timestamp].md`
...

---

## ⚠️ Issues and Warnings

[If no issues]
✅ No issues encountered - all fixes applied successfully!

[If issues exist]
Total issues: [N]

### Critical Issues
[If any critical issues]
❌ [Issue description]
   - Action: [action-command]
   - Affected: [files]
   - Required: Manual intervention
   - Details: [fix-log-file]

### Warnings
[If any warnings]
⚠️ [Warning description]
   - Action: [action-command]
   - Note: [additional context]

---

## 📝 Verification Summary

### Code Quality Checks
- ✅ Syntax validation: [N] files checked, [N] passed
- ✅ TypeScript compilation: [N] files checked, [N] passed
- ✅ Linting: [N] files checked, [N] passed
- ✅ Imports validation: [N] files checked, [N] passed

### GitHub Integration
- ✅ Comments resolved: [N] of [N]
- ✅ Threads closed: [N] of [N]
- [If any failed] ⚠️ Manual resolution needed: [N]

---

## 🎯 Next Steps

### Immediate Actions
1. **Review Changes**: Check modified files for correctness
   ```bash
   git diff
   ```

2. **Run Tests**: Execute test suite to ensure nothing broke
   ```bash
   npm test
   # or
   npm run test
   ```

3. **Build Project**: Verify project still builds
   ```bash
   npm run build
   ```

[If any manual resolutions needed]
4. **Resolve Remaining Comments**: Manually resolve [N] comments on GitHub
   - [Link to comment 1]
   - [Link to comment 2]

### Follow-Up Actions
- [ ] Verify PR build passes on CI/CD
- [ ] Request re-review from reviewers
- [ ] Respond to any remaining questions in PR comments

---

## 📊 Statistics

**Code Changes**:
- Lines added: [estimated]
- Lines modified: [estimated]
- Lines removed: [estimated]
- Files modified: [N]

**Execution Metrics**:
- Total execution time: [duration]
- Average time per fix: [time]
- API calls made: [N]
- GitHub resolutions: [N]

---

## 🔗 Quick Links

- 📝 **PR URL**: [pr-url]
- 📊 **Full Fix Report**: `.cursor/fixes/fix-report-pr-[PR-NUMBER]-[timestamp].md`
- 📋 **Fix Logs**: `.cursor/fixes/fix-log-pr-[PR-NUMBER]-comment-*-[timestamp].md`

---

## ✅ Session Complete

[If all successful]
🎉 **SUCCESS!** All PR review comments have been addressed and resolved.

The PR is now ready for re-review. All changes have been applied, verified, and marked as resolved on GitHub.

[If partial success]
⚠️ **PARTIAL SUCCESS**: Most fixes applied, but [N] require manual attention.

Review the issues above and fix log files for details on what needs manual intervention.

[If significant failures]
❌ **ATTENTION REQUIRED**: [N] fixes failed and need manual intervention.

Please review the detailed logs and address failed actions manually.

═══════════════════════════════════════════════════════════════
END OF FIX EXECUTION
═══════════════════════════════════════════════════════════════
```

**🤖 AI Actions (MANDATORY)**:
1. Append this final report to main fix report file
2. Display report to user
3. **⚠️ PROCEED TO STEP 4 - CLEANUP ACTION COMMANDS (DO NOT SKIP)** ⚠️

⚠️⚠️⚠️ **CRITICAL REMINDER** ⚠️⚠️⚠️
**YOU MUST NOW EXECUTE STEP 4 TO DELETE ALL ACTION COMMAND FILES**
**THE WORKFLOW IS NOT COMPLETE WITHOUT STEP 4**
**DO NOT STOP HERE - CONTINUE TO STEP 4 IMMEDIATELY**

---

### Step 4: Cleanup Action Commands

**Action**: Remove all processed action command files.

⚠️ **CRITICAL**: This step is MANDATORY and runs AFTER all fixes are completed and the final report is generated.

⚠️ **DO NOT SKIP THIS STEP** - The workflow is not complete until all action commands are deleted.

**🤖 AI Actions (MANDATORY)**:
1. List all action command files that were processed in Step 1
2. **USE THE `delete_file` TOOL** to delete each action command file
3. Delete EVERY file matching pattern: `.cursor/commands/action-pr-[PR-NUMBER]-comment-*.md`
4. Verify deletion succeeded (files should no longer exist)
5. Report cleanup results
6. Preserve all other files (fix logs, review reports, other commands)

**Deletion Method**:
⚠️ **YOU MUST USE THE `delete_file` TOOL** - Do NOT use terminal commands

**Example - Delete each action file**:
```
For each action command file found in Step 1:
  - Use: delete_file(target_file=".cursor/commands/action-pr-582-comment-1-20251014-153045.md")
  - Use: delete_file(target_file=".cursor/commands/action-pr-582-comment-2-20251014-153045.md")
  - Use: delete_file(target_file=".cursor/commands/action-pr-582-comment-N-20251014-153045.md")
  - Continue until ALL action-pr-[PR-NUMBER]-*.md files are deleted
```

**How to Delete**:
1. For EACH action command file processed:
   - Call `delete_file` with the exact file path
   - Example: `delete_file(target_file=".cursor/commands/action-pr-582-comment-1-20251014-153045.md")`
2. Delete ALL files, not just some
3. Verify each deletion succeeded

**Cleanup Strategy**:
- ✅ Remove ALL `action-pr-[PR-NUMBER]-*.md` files in `.cursor/commands/`
- ✅ Keep other command files intact (fix-my-pr.md, review-my-pr.md, etc.)
- ✅ Verify successful deletion
- ℹ️ Fix logs are preserved in `.cursor/fixes/` for audit trail
- ℹ️ Review reports preserved in `.cursor/reviews/` for history

**Verification Checklist**:
- [ ] All action command files for this PR identified
- [ ] **`delete_file` tool called for EACH action command file**
- [ ] Action commands removed successfully (verified with tool response)
- [ ] Other command files preserved (fix-my-pr.md, review-my-pr.md, etc.)
- [ ] Fix logs preserved in `.cursor/fixes/`
- [ ] Review reports preserved in `.cursor/reviews/`
- [ ] Cleanup logged in final report

**Completion Criteria**:
- ✅ **`delete_file` tool used (not bash commands)**
- ✅ All processed action commands removed (one by one)
- ✅ Deletion confirmed for each file
- ✅ Workspace clean and ready for next review cycle

**🤖 AI Report Output (MANDATORY)**:

Append to main fix report:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📋 Step 4 Complete - Action Commands Cleanup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Status: ✅ Success

Action Commands Removed: [N]

Files Cleaned:
- action-pr-[PR-NUMBER]-comment-1-[timestamp].md ✅ Removed
- action-pr-[PR-NUMBER]-comment-2-[timestamp].md ✅ Removed
- action-pr-[PR-NUMBER]-comment-N-[timestamp].md ✅ Removed

Total: [N] action command files removed

Preserved Files:
- ✅ Fix logs in .cursor/fixes/ (kept for audit trail)
- ✅ Review reports in .cursor/reviews/ (kept for history)
- ✅ Other command files (fix-my-pr.md, review-my-pr.md, etc.)

Workspace Status: ✅ Clean and ready for next cycle

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

═══════════════════════════════════════════════════════════════
SESSION COMPLETE
═══════════════════════════════════════════════════════════════

All fixes have been applied, verified, and cleaned up.

Next Steps:
1. Review changes: git diff
2. Run tests: npm test

---
```

**Display to user (MANDATORY)**:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🧹 CLEANUP COMPLETE - ACTION COMMANDS DELETED
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✅ All [N] processed action commands have been DELETED:

- action-pr-[PR-NUMBER]-comment-1-[timestamp].md ✅ DELETED
- action-pr-[PR-NUMBER]-comment-2-[timestamp].md ✅ DELETED
- action-pr-[PR-NUMBER]-comment-N-[timestamp].md ✅ DELETED

✅ Fix logs preserved in .cursor/fixes/ for future reference
✅ Review reports preserved in .cursor/reviews/
✅ Workspace is now clean and ready for next review cycle

To re-generate action commands (if reviewer adds new comments):
Run: /fix-my-pr [PR-URL]
(Will auto-execute /review-my-pr if needed)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ FIX-MY-PR WORKFLOW COMPLETE ✅
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

⚠️ **IMPORTANT**: Verify that you actually deleted the files. Do NOT just say you did - actually use the `delete_file` tool for each action command file.

**Why Remove Action Commands?**:
1. **Workspace cleanliness**: Avoid clutter from completed tasks
2. **Clear state**: Next `/fix-my-pr` won't re-process old actions
3. **Prevent confusion**: Only active/pending actions remain
4. **Iterative workflow**: Clean slate for next review cycle
5. **Audit trail preserved**: Fix logs still available in `.cursor/fixes/`

**What's Preserved**:
- ✅ Fix logs: `.cursor/fixes/fix-log-*.md` (complete history)
- ✅ Fix reports: `.cursor/fixes/fix-report-*.md` (execution summary)
- ✅ Review reports: `.cursor/reviews/review-pr-*.md` (original review)
- ✅ GitHub: Comments marked as resolved (permanent)

**What's Removed**:
- ❌ Action commands: `.cursor/commands/action-pr-[PR-NUMBER]-*.md` (no longer needed)

**Rationale**:
- Action commands are **instructions** for fixes to be applied
- Once fixes are applied and verified, instructions are no longer needed
- If reviewer adds new comments, `/review-my-pr` will generate new action commands
- Old action commands would only create confusion or duplicate work

---

## Error Handling

### Common Errors and Solutions

**Info: No action commands found**
- **Cause**: No `action-pr-*.md` files in `.cursor/commands/`
- **Auto-Action**: `/fix-my-pr` will automatically run `/review-my-pr` first
- **Note**: No manual intervention needed - workflow handles this automatically

**Error: Thread ID missing from action command**
- **Cause**: Action command file doesn't contain Thread ID
- **Solution**: Re-run `/review-my-pr` to regenerate with Thread IDs

**Error: Failed to mark as resolved (401/403)**
- **Cause**: Token lacks write permissions
- **Solution**: Run `gh auth refresh -h github.com` to refresh token

**Error: Failed to mark as resolved (404)**
- **Cause**: Thread ID not found or outdated
- **Solution**: Skip marking (comment may be already resolved or deleted)

**Error: File not found**
- **Cause**: File mentioned in action command doesn't exist
- **Solution**: Document in fix log, mark as needs manual review

**Error: TypeScript compilation failed**
- **Cause**: Fix introduced syntax or type errors
- **Solution**: Attempt to fix automatically, or revert and mark for manual review

**Error: Linting failed**
- **Cause**: Fix doesn't meet linting standards
- **Solution**: Apply auto-fix if possible, otherwise document and continue

**Error: Cannot apply fix automatically**
- **Cause**: Fix instructions too vague or complex
- **Solution**: Document in fix log, mark as needs manual review, continue with remaining fixes

---

## Notes

- **PR URL is REQUIRED** - command will fail if not provided
- **Previous fix logs are automatically deleted at start** - ensures fresh logs for each run
- This workflow executes fixes automatically but intelligently
- **Auto-executes `/review-my-pr`** if no action commands found
- Each fix is applied, verified, and validated before marking as resolved
- Failures in one fix don't stop the entire process
- All actions are logged for audit and debugging
- GitHub comments are marked as resolved automatically using GitHub CLI
- **Action commands are automatically removed after successful processing**
- Manual intervention may be needed for complex cases
- Always review changes thoroughly
- Test thoroughly after running fixes
- Re-running is safe - already resolved comments are skipped by `/review-my-pr`
- **CRITICAL**: Thread IDs must be present in action commands for marking as resolved
- Cleanup ensures workspace stays clean for iterative workflows
- GitHub CLI handles all authentication and API interactions

---

## Success Criteria

**Complete Success**:

- ✅ All action commands processed
- ✅ All fixes applied successfully
- ✅ All verifications passed
- ✅ All comments marked as resolved on GitHub
- ✅ Action commands cleaned up (removed)
- ✅ No errors or warnings

**Partial Success**:

- ✅ Most action commands processed
- ✅ Most fixes applied successfully
- ⚠️ Some verifications had warnings
- ✅ Most comments marked as resolved
- ⚠️ Some require manual attention

**Needs Attention**:

- ⚠️ Some action commands processed
- ⚠️ Several fixes failed
- ❌ Multiple verification failures
- ⚠️ Several comments not resolved
- ❌ Requires manual intervention
