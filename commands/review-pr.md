# PR Review

## Purpose

Analyze all PR review comments and convert them into executable action commands with step-by-step fixes. This transforms vague feedback into concrete next steps, making it clear exactly what to do.

**Context**: PR feedback often comes as scattered comments across files, with varying levels of detail. Some comments are critical, others are suggestions. Manual tracking is error-prone - you miss comments, forget context, or waste time on already-resolved threads. This automated workflow organizes everything by severity, filters out resolved/outdated comments, and generates actionable fix commands.

## Critical Execution Principles

You are analyzing PR comments and creating fix commands. Follow these principles throughout:

1. **Read comments carefully to extract intent**

   - Understand what the reviewer actually wants
   - Distinguish between "must fix" and "nice to have"
   - Capture the WHY behind the feedback, not just the WHAT
   - **WHY**: Understanding intent creates better fixes than literal interpretation

2. **Filter intelligently - skip noise**

   - Ignore already-resolved threads (use GraphQL API to check)
   - Skip outdated comments (code has changed)
   - Don't create actions for simple acknowledgments or questions
   - **WHY**: Noise dilutes signal and wastes time

3. **Categorize accurately by severity**

   - Critical: Blocks merge (security, breaking bugs, data integrity)
   - Major: Should fix before merge (architecture, types, error handling)
   - Minor: Nice to have (style, docs, minor optimizations)
   - **WHY**: Severity drives priority and helps focus effort

4. **Generate actionable fix commands**

   - Every action command must have:
     - Clear problem statement
     - Specific code location
     - Step-by-step fix instructions
     - Expected outcome
   - **WHY**: Vague commands waste time figuring out what to do

5. **Include thread IDs for automation**
   - Extract GitHub thread IDs from GraphQL API
   - Include in action commands for mark-as-resolved functionality
   - **WHY**: Enables automated GitHub integration

**Objective**: Extract review comments from a GitHub PR and generate executable action commands for addressing feedback.

**Usage**: `/review-my-pr https://github.com/owner/repo/pull/NUMBER`

⚠️ **IMPORTANT**: PR URL is REQUIRED. The command will fail if no URL is provided.

---

## 📁 Output Files

All reports and action commands will be saved in `.cursor/reviews/` and `.cursor/commands/` directories:

**File Naming Convention**:

- **Main PR Review Report**: `.cursor/reviews/review-pr-[PR-NUMBER]-[YYYYMMDD-HHMMSS].md`
- **Action Commands**: `.cursor/commands/action-pr-[PR-NUMBER]-comment-[N]-[YYYYMMDD-HHMMSS].md` (one per actionable comment)

**Important**:

- The main review report contains ALL step outputs in a single file
- Each step's report is appended to the main review file as it completes
- For each actionable comment, an action command is automatically generated
- Timestamp format: `YYYYMMDD-HHMMSS` (e.g., `20251014-153045`)

**🤖 AI Instructions (MANDATORY)**:

1. Parse the PR URL from user input
2. Extract PR number and validate
3. Use GitHub credentials from `.cursor/credentials/github.json`
4. Fetch PR comments via GitHub API
5. Create action commands for each actionable comment
6. Generate comprehensive report

---

## 🔐 Prerequisites

### GitHub Credentials Setup

**File**: `.cursor/credentials/github.json`

**Required Structure**:

```json
{
  "github": {
    "token": "ghp_your_personal_access_token_here",
    "username": "your-github-username"
  }
}
```

**Token Permissions Required**:

- `repo` (Full control of private repositories)
- `read:discussion` (Read discussions)

**How to Generate Token**:

1. Go to: https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Select scopes: `repo`, `read:discussion`
4. Copy token and save to `.cursor/credentials/github.json`

⚠️ **IMPORTANT**: The credentials file should NEVER be committed to git. It should be in `.gitignore`.

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
   - Store PR information for session

**Expected Input Format**:

- Full URL: `https://github.com/owner/repo/pull/NUMBER`
- Short URL: `github.com/owner/repo/pull/NUMBER`

**Regex Pattern**:

```bash
# Extract PR number
echo "https://github.com/owner/repo/pull/582" | grep -oE 'pull/([0-9]+)' | cut -d'/' -f2
```

**Expected Output**:

- PR Number: `582`
- Repository: `owner/repo`
- Owner: `owner`
- Repo Name: `repo`

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

The /review-my-pr command requires the Pull Request URL as a parameter.

## ❌ Error

The PR URL was not provided. The command cannot continue without this required parameter.

## ✅ Correct Usage

/review-my-pr https://github.com/owner/repo/pull/NUMBER

## 🔍 Why Is It Required?

The PR URL is necessary to:
1. ✅ Identify which PR to analyze
2. ✅ Access comments via GitHub API
3. ✅ Generate action commands specific to the PR
4. ✅ Mark comments as resolved in the future
5. ✅ Create correct reports with links to the PR

## 🚀 Next Steps

1. Find your Pull Request URL on GitHub
2. Copy the complete URL
3. Run: /review-my-pr [PR-URL]

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

Next Step: Proceed to Pre-Step 1 - Validate Credentials

---
```

---

### Pre-Step 1: Validate Credentials

**Action**: Check if GitHub credentials exist and are valid.

**File to Check**: `.cursor/credentials/github.json`

**🤖 AI Actions (MANDATORY)**:

1. Check if credentials file exists
2. Parse JSON and extract token
3. Validate token format (should start with `ghp_` or `github_pat_`)

**Command**:

```bash
# Check if credentials file exists
if [ -f .cursor/credentials/github.json ]; then
  echo "✅ Credentials file found"
else
  echo "❌ Credentials file not found"
  exit 1
fi

# Extract token (requires jq)
TOKEN=$(cat .cursor/credentials/github.json | jq -r '.github.token')

if [ -z "$TOKEN" ] || [ "$TOKEN" == "null" ]; then
  echo "❌ Token not found in credentials"
  exit 1
fi

echo "✅ Token loaded successfully"
```

**Verification Checklist**:

- [ ] Credentials file exists
- [ ] JSON is valid
- [ ] Token field exists and not empty
- [ ] Token format is valid

**Completion Criteria**:

- ✅ Credentials validated
- ⛔ If credentials missing/invalid: Stop and provide setup instructions

**🤖 AI Report Output (MANDATORY)**:

```
📋 Pre-Step 1 Complete - Credentials Validated

Status: [✅ Success / ❌ Failed]

Credentials File: .cursor/credentials/github.json
Token Format: [Valid / Invalid]
Token Preview: [first 8 chars]...

[If failed, show setup instructions]

Next Step: Proceed to Pre-Step 2 - Cleanup

---
```

---

### Pre-Step 2: Cleanup Previous PR Reviews

**Action**: Clean up previous PR review files for THIS specific PR number only.

**🤖 AI Actions (MANDATORY)**:

1. Delete files matching pattern: `.cursor/reviews/review-pr-[PR-NUMBER]-*.md`
2. Delete files matching pattern: `.cursor/commands/action-pr-[PR-NUMBER]-*.md`

**Commands to execute**:

```bash
# Remove PR-specific review files
rm -f .cursor/reviews/review-pr-[PR-NUMBER]-*.md

# Remove PR-specific action command files
rm -f .cursor/commands/action-pr-[PR-NUMBER]-*.md
```

**Verification**:

- [ ] PR-specific review files deleted
- [ ] PR-specific action files deleted
- [ ] Other PR reviews preserved (different PR numbers)

**Completion Criteria**:

- ✅ Cleanup completed successfully
- ✅ Ready for new review session

**🤖 AI Report Output (MANDATORY)**:

```
🧹 Pre-Step 2 Complete - Cleanup

Status: ✅ Success

Files Removed:
- review-pr-[PR-NUMBER]-*.md: [N] files deleted
- action-pr-[PR-NUMBER]-*.md: [N] files deleted

Other PR reviews: Preserved
Ready to start new PR review session.

---
```

---

### Step 0: Initialize PR Review Session

**Action**: Create the review report file and initialize the session.

**🤖 AI Actions (MANDATORY)**:

1. Generate timestamp: `YYYYMMDD-HHMMSS`
2. Create directory: `.cursor/reviews/` (if not exists)
3. Create main report file: `.cursor/reviews/review-pr-[PR-NUMBER]-[timestamp].md`
4. Initialize report file with header

**Report Header Template**:

```markdown
# PR Review Report - PR #[PR-NUMBER]

**Date**: [date]
**Timestamp**: [timestamp]
**PR**: #[PR-NUMBER]
**Repository**: [owner/repo]
**PR URL**: [original-url]

---
```

**Completion Criteria**:

- ✅ Review report file created
- ✅ Timestamp stored for session

**🤖 AI Report Output (MANDATORY)**:

```
📋 Step 0 Complete - Session Initialized

Status: ✅ Success

Report File: .cursor/reviews/review-pr-[PR-NUMBER]-[timestamp].md
Timestamp: [timestamp]
PR Number: [N]

Next Step: Proceed to Step 1 - Fetch PR Details

---
```

**🤖 AI Action**: Append this report to the main review file

---

### Step 1: Fetch PR Details

**Action**: Retrieve PR information from GitHub API.

**API Endpoint**: `GET /repos/{owner}/{repo}/pulls/{pull_number}`

**Command**:

```bash
# Using curl
TOKEN=$(cat .cursor/credentials/github.json | jq -r '.github.token')

curl -H "Authorization: token $TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     https://api.github.com/repos/[owner]/[repo]/pulls/[PR-NUMBER]
```

**Expected Response Data**:

- `title`: PR title
- `state`: open/closed/merged
- `user.login`: PR author
- `created_at`: Creation date
- `head.ref`: Source branch
- `base.ref`: Target branch
- `body`: PR description
- `comments`: Number of comments
- `review_comments`: Number of review comments

**Verification Checklist**:

- [ ] API call successful (200 status)
- [ ] PR exists and accessible
- [ ] Required fields extracted
- [ ] Token has correct permissions

**Completion Criteria**:

- ✅ PR details fetched successfully
- ⛔ If 404: Stop and report "PR not found"
- ⛔ If 401/403: Stop and report "Authentication failed"

**🤖 AI Report Output (MANDATORY)**:

Output the following report AND append it to the main review file:

```
📋 Step 1 Complete - PR Details Fetched

Status: ✅ Success

PR Information:
- Title: [title]
- Author: [author]
- State: [state]
- Source Branch: [head-ref]
- Target Branch: [base-ref]
- Created: [created-at]

Comments Overview:
- Issue Comments: [N]
- Review Comments: [N]
- Total Comments: [N]

Next Step: Proceed to Step 2 - Fetch Comments

---
```

**🤖 AI Action**: Append this report to the main review file

---

### Step 2: Fetch All PR Comments

**Action**: Retrieve all comments from the PR (both issue comments and review comments).

#### 2.1 Fetch Issue Comments

**API Endpoint**: `GET /repos/{owner}/{repo}/issues/{issue_number}/comments`

**Command**:

```bash
TOKEN=$(cat .cursor/credentials/github.json | jq -r '.github.token')

curl -H "Authorization: token $TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     https://api.github.com/repos/[owner]/[repo]/issues/[PR-NUMBER]/comments
```

**Expected Response Data** (array of):

- `id`: Comment ID
- `user.login`: Comment author
- `body`: Comment text
- `created_at`: Creation timestamp
- `updated_at`: Last update timestamp

---

#### 2.2 Fetch Review Comments

**API Endpoint**: `GET /repos/{owner}/{repo}/pulls/{pull_number}/comments`

**Command**:

```bash
TOKEN=$(cat .cursor/credentials/github.json | jq -r '.github.token')

curl -H "Authorization: token $TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     https://api.github.com/repos/[owner]/[repo]/pulls/[PR-NUMBER]/comments
```

**Expected Response Data** (array of):

- `id`: Comment ID
- `user.login`: Comment author
- `body`: Comment text
- `path`: File path (if inline comment)
- `position`: Line position (if inline comment)
- `line`: Line number (if inline comment)
- `created_at`: Creation timestamp
- `updated_at`: Last update timestamp
- `in_reply_to_id`: Parent comment ID (if reply)
- `pull_request_review_id`: Associated review ID
- **`original_position`**: Original line position (null if outdated)
- **`side`**: LEFT/RIGHT (null if outdated)

---

#### 2.3 Fetch PR Reviews

**API Endpoint**: `GET /repos/{owner}/{repo}/pulls/{pull_number}/reviews`

**Command**:

```bash
TOKEN=$(cat .cursor/credentials/github.json | jq -r '.github.token')

curl -H "Authorization: token $TOKEN" \
     -H "Accept: application/vnd.github.v3+json" \
     https://api.github.com/repos/[owner]/[repo]/pulls/[PR-NUMBER]/reviews
```

**Expected Response Data** (array of):

- `id`: Review ID
- `user.login`: Reviewer
- `body`: Review text
- `state`: APPROVED/CHANGES_REQUESTED/COMMENTED
- `submitted_at`: Submission timestamp

---

#### 2.4 Fetch Review Threads (GraphQL - for resolved/outdated status)

⚠️ **MANDATORY**: Use GitHub GraphQL API to get accurate resolution and outdated status.

**API Endpoint**: `https://api.github.com/graphql`

**GraphQL Query**:

```graphql
query ($owner: String!, $name: String!, $number: Int!) {
  repository(owner: $owner, name: $name) {
    pullRequest(number: $number) {
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          isOutdated
          comments(first: 100) {
            nodes {
              id
              databaseId
              body
              author {
                login
              }
              createdAt
              path
              line
            }
          }
        }
        pageInfo {
          hasNextPage
          endCursor
        }
      }
    }
  }
}
```

**Command**:

```bash
TOKEN=$(cat .cursor/credentials/github.json | jq -r '.github.token')

curl -X POST \
  -H "Authorization: bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "query($owner: String!, $name: String!, $number: Int!) { repository(owner: $owner, name: $name) { pullRequest(number: $number) { reviewThreads(first: 100) { nodes { id isResolved isOutdated comments(first: 100) { nodes { id databaseId body author { login } createdAt path line } } } pageInfo { hasNextPage endCursor } } } } }",
    "variables": {
      "owner": "[owner]",
      "name": "[repo]",
      "number": [PR-NUMBER]
    }
  }' \
  https://api.github.com/graphql
```

**Expected Response**:

```json
{
  "data": {
    "repository": {
      "pullRequest": {
        "reviewThreads": {
          "nodes": [
            {
              "id": "PRRT_kwDOA...",
              "isResolved": true,
              "isOutdated": false,
              "comments": {
                "nodes": [
                  {
                    "databaseId": 12345,
                    "body": "Please add error handling here",
                    "author": { "login": "reviewer1" },
                    "createdAt": "2025-10-14T10:30:00Z",
                    "path": "components/form.tsx",
                    "line": 42
                  }
                ]
              }
            }
          ],
          "pageInfo": {
            "hasNextPage": false,
            "endCursor": null
          }
        }
      }
    }
  }
}
```

**Filtering Logic**:

For each review thread:

1. **Check `isResolved` field**:

   - If `true` → Thread is **resolved**, skip ALL comments in thread
   - If `false` → Thread is active, check next condition

2. **Check `isOutdated` field**:

   - If `true` → Thread is **outdated** (code changed), skip ALL comments
   - If `false` → Thread is current, include comments for analysis

3. **Result**:
   - Only threads with `isResolved: false` AND `isOutdated: false` are analyzed
   - Extract comments from these active threads only

**🤖 AI Actions (MANDATORY)**:

1. Execute GraphQL query with PR owner/name/number
2. Parse `reviewThreads.nodes` array
3. For each thread:
   - If `isResolved === true` → Skip thread (add to resolved count)
   - If `isOutdated === true` → Skip thread (add to outdated count)
   - If both false → Extract comments for analysis (add to active count)
4. Build map: `comment.databaseId` → `{threadId, isResolved, isOutdated}`
5. Store `threadId` for each comment (needed for marking as resolved later)
6. Use this map to filter REST API comments and enrich with thread IDs

---

**Verification Checklist**:

- [ ] Issue comments fetched successfully
- [ ] Review comments fetched successfully
- [ ] PR reviews fetched successfully
- [ ] Resolution/outdated status checked
- [ ] All comment data includes author and body
- [ ] Inline comments include file/line information

**Completion Criteria**:

- ✅ All comment types fetched
- ✅ Comments parsed and stored
- ✅ Resolved/outdated comments identified

**🤖 AI Report Output (MANDATORY)**:

Output the following report AND append it to the main review file:

```
📋 Step 2 Complete - Comments Fetched & Filtered

Status: ✅ Success

Comment Types Retrieved:
- Issue Comments: [N]
- Review Comments (inline): [N]
- PR Reviews: [N]

Total Comments Fetched: [N]

Filtered Comments:
- ✅ Active Comments: [N]
- 🔄 Resolved Comments (skipped): [N]
- ⏰ Outdated Comments (skipped): [N]

Comments to Analyze: [N]

Comment Breakdown by Author (active only):
- [author1]: [N] comments
- [author2]: [N] comments
...

Comment Breakdown by Type (active only):
- General comments: [N]
- Inline code comments: [N]
- Review summaries: [N]

Next Step: Proceed to Step 3 - Analyze Active Comments

---
```

**🤖 AI Action**: Append this report to the main review file

---

### Step 3: Analyze and Categorize Comments

**Action**: Analyze each **active** comment (not resolved/outdated) to determine if it requires action and categorize by severity.

**Context**: This is where you interpret human feedback and translate it into actionable next steps. Use extended thinking to understand the reviewer's intent beyond their words.

⚠️ **IMPORTANT**: Only analyze comments that are:

- ✅ NOT marked as resolved
- ✅ NOT outdated (position is not null)
- ✅ Still relevant to current code

#### 3.1 Comment Classification

**🤖 AI Actions (MANDATORY)**:

For each **active** comment, use thoughtful analysis:

**Step 1: Read the comment completely**

- Don't skim or pattern-match keywords
- Understand the full context and intent
- Consider the reviewer's perspective
- **WHY**: Quick judgments misinterpret feedback

**Step 2: Use extended thinking to classify**

Consider these questions:

```
Is it actionable?
- Does it request a code change?
- Or is it just a question/discussion?
- If unclear, read the thread - follow-ups may clarify

What's the severity?
- Could this break production? → Critical
- Does it violate architecture/types? → Major
- Is it style/preference? → Minor
- Is it just information? → Not actionable

What needs to change?
- Specific files mentioned?
- Specific lines mentioned?
- Broad architectural concern?
```

**WHY**: Thoughtful classification prevents:

- Marking questions as "critical bugs"
- Ignoring genuine security issues
- Creating busywork for style preferences

**Step 3: Extract and document**

For each **active** comment, determine:

1. **Is it actionable?** - Does it request a change or fix?

   - **If unclear**: Err on the side of actionable (reviewers often imply fixes)

2. **Severity level** - Critical / Major / Minor / Info only

   - Use extended thinking to evaluate impact
   - Consider: What breaks if we ignore this?

3. **Category** - Bug / Code Quality / Architecture / Documentation / Question

   - Help organize similar issues

4. **Affected files** - Which files need changes (if mentioned)

   - If not explicitly mentioned, infer from context

5. **Specific action** - What needs to be done
   - Be precise: "Add null check" not "fix the issue"

**Severity Classification Rules**:

**🔴 Critical** - Blocks merge:

- Security vulnerabilities mentioned
- Breaking bugs identified
- Data integrity issues
- "Must fix before merge" language
- "Blocking" or "Critical" labels

**🟡 Major** - Should fix before merge:

- Architecture concerns
- Type safety issues
- Error handling missing
- Performance problems
- "Should fix" or "Recommend fixing" language

**🟢 Minor** - Nice to have:

- Code style suggestions
- Documentation improvements
- Refactoring suggestions
- Optimization ideas
- "Consider" or "Suggestion" language

**ℹ️ Info** - No action required:

- Questions answered
- Acknowledgments
- General discussion
- Approvals without comments

**Category Classification**:

- 🐛 **Bug**: Something is broken or doesn't work
- 🏗️ **Architecture**: Design pattern or structure issue
- 🎨 **Code Quality**: Style, readability, best practices
- 📝 **Documentation**: Missing or incorrect docs/comments
- 🔍 **Review**: General review feedback
- ❓ **Question**: Needs clarification (may not need action)

---

#### 3.2 Extract Actionable Items

**🤖 AI Actions (MANDATORY)**:

For each actionable comment:

1. Extract the specific request or issue
2. Identify the file/line (if mentioned)
3. Understand the context
4. Determine the fix needed
5. Create an action item structure

**Action Item Structure**:

```json
{
  "comment_id": "comment-id-from-github",
  "comment_database_id": 12345,
  "thread_id": "PRRT_kwDOA...",
  "comment_number": 1,
  "author": "reviewer-username",
  "severity": "critical|major|minor",
  "category": "bug|architecture|code-quality|documentation|question",
  "file": "path/to/file.tsx",
  "line": 42,
  "comment_text": "Original comment text",
  "action_required": "Specific description of what needs to be done",
  "context": "Additional context if needed",
  "url": "Direct link to comment on GitHub",
  "is_resolved": false,
  "is_outdated": false,
  "status": "active"
}
```

⚠️ **Note**:

- Only comments with `"status": "active"` should be included in action items
- `thread_id` is MANDATORY for marking as resolved via GraphQL API
- Extract `thread_id` from GraphQL response in Step 2.4

---

**Verification Checklist**:

- [ ] All comments analyzed
- [ ] Actionable comments identified
- [ ] Each comment categorized by severity
- [ ] Each comment categorized by type
- [ ] File/line information extracted (if available)
- [ ] Action items clearly defined

**Completion Criteria**:

- ✅ All comments categorized
- ✅ Action items extracted

**🤖 AI Report Output (MANDATORY)**:

Output the following report AND append it to the main review file:

```
📋 Step 3 Complete - Comments Analyzed

Status: ✅ Success

Total Comments Analyzed: [N]

Actionability:
- ✅ Actionable: [N]
- ℹ️ Info only: [N]

Severity Breakdown (Actionable Only):
- 🔴 Critical: [N]
- 🟡 Major: [N]
- 🟢 Minor: [N]

Category Breakdown:
- 🐛 Bug: [N]
- 🏗️ Architecture: [N]
- 🎨 Code Quality: [N]
- 📝 Documentation: [N]
- ❓ Question: [N]

Files Affected:
- [file1]: [N] comments
- [file2]: [N] comments
...

Next Step: Proceed to Step 4 - Generate Action Commands

---
```

**🤖 AI Action**: Append this report to the main review file

---

### Step 4: Generate Action Commands

**Action**: For EACH actionable comment, create a dedicated action command file.

**File Naming**: `.cursor/commands/action-pr-[PR-NUMBER]-comment-[N]-[timestamp].md`

- Example: `action-pr-582-comment-1-20251014-153045.md`

**Command Template** (for each actionable comment):

````markdown
# Fix: PR #[PR-NUMBER] - Comment [N]

## Context

- **PR**: #[PR-NUMBER] - [PR-TITLE]
- **PR URL**: [pr-url]
- **Comment Author**: @[author]
- **Comment URL**: [direct-link-to-comment]
- **Comment ID**: [comment-database-id]
- **Thread ID**: [thread-id] ← For marking as resolved
- **Severity**: [🔴 Critical / 🟡 Major / 🟢 Minor]
- **Category**: [🐛 Bug / 🏗️ Architecture / 🎨 Code Quality / 📝 Documentation]
- **Review Date**: [date]
- **Review Report**: `.cursor/reviews/review-pr-[PR-NUMBER]-[timestamp].md`

---

## 💬 Original Comment

**Author**: @[author]  
**Posted**: [date]

> [Original comment text, formatted as quote]

[If inline comment with code context]
**File**: `[file-path]`  
**Line**: [N]

---

## 🎯 Action Required

**Summary**: [One-line summary of what needs to be done]

**Detailed Description**:
[Detailed explanation of the issue and what needs to be fixed]

**Affected Files**:

- `[file1]` [- Line [N] if specified]
- `[file2]` [- Line [N] if specified]

---

## 🔧 Fix Instructions

### Step-by-Step Guide

1. **[Action 1]**

   - [Detailed instruction]
   - [Expected outcome]

2. **[Action 2]**

   - [Detailed instruction]
   - [Expected outcome]

3. **[Action 3]**
   - [Detailed instruction]
   - [Expected outcome]

---

## 📝 Current Code

[If file/line specified]

**File**: `[file-path]`

```[language]
// Line [N]
[current code snippet]
```
````

---

## ✅ Expected Result

**After fix, the code should**:
[Description of expected outcome]

[If applicable]

```[language]
// Suggested fix
[fixed code snippet]
```

---

## 🧪 Verification Checklist

After applying fix:

- [ ] Comment feedback addressed
- [ ] Code follows project standards
- [ ] No new linter errors
- [ ] File compiles without errors
- [ ] Related tests pass (if applicable)
- [ ] Changes committed and pushed
- [ ] **Comment marked as resolved on GitHub** ⚠️ MANDATORY

---

## ✅ Mark Comment as Resolved

⚠️ **IMPORTANT**: After fixing the issue, you MUST mark the comment as resolved on GitHub to avoid duplicate action items on next review.

### Option 1: Manual (via GitHub UI)

1. Go to the PR on GitHub: [pr-url]
2. Navigate to the comment: [direct-link-to-comment]
3. Click "Resolve conversation" button
4. Confirm resolution

**Direct Link**: [comment-url]

### Option 2: Automatic (via GraphQL API)

**Using curl command** (copy-paste ready):

```bash
# Mark thread as resolved
TOKEN=$(cat .cursor/credentials/github.json | jq -r '.github.token')

curl -X POST -H "Authorization: bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "mutation { resolveReviewThread(input: {threadId: \"[THREAD-ID]\"}) { thread { id isResolved } } }"
  }' \
  https://api.github.com/graphql
```

**Thread ID**: `[thread-id]`

**Verification** (optional - check if resolved):

```bash
TOKEN=$(cat .cursor/credentials/github.json | jq -r '.github.token')

curl -X POST -H "Authorization: bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "query { node(id: \"[THREAD-ID]\") { ... on PullRequestReviewThread { isResolved } } }"
  }' \
  https://api.github.com/graphql
```

**Expected Response**: `"isResolved": true`

---

## 🔗 Related Comments

[If there are related comments or threads]

- Comment [N]: [brief description] - [link]
- Comment [M]: [brief description] - [link]

---

## 📌 Priority

**Severity**: [🔴 Critical / 🟡 Major / 🟢 Minor]

[If Critical]
🔴 **CRITICAL**: This must be fixed before merging the PR.

[If Major]
🟡 **MAJOR**: Strongly recommended to fix before merging.

[If Minor]
🟢 **MINOR**: Optional improvement, can be addressed later.

---

## 🎯 Complete Workflow

**Step-by-Step Execution**:

1. ✅ Read and understand the comment
2. ✅ Apply the fix as described in "Fix Instructions"
3. ✅ Verify with the checklist above
4. ✅ Commit and push changes
5. ✅ **Mark comment as resolved on GitHub** (Option 1 or 2)
6. ✅ Move to next action command

**Why mark as resolved?**:

- Prevents duplicate action items on next `/review-my-pr` run
- Keeps PR review clean and organized
- Shows progress to reviewers
- Enables iterative workflow

---

```

---

**Verification Checklist**:
- [ ] One action command per actionable comment
- [ ] Each command is self-contained
- [ ] Original comment included verbatim
- [ ] Direct link to comment provided
- [ ] **Thread ID included for marking as resolved**
- [ ] File/line information included (if available)
- [ ] Step-by-step fix instructions provided
- [ ] Severity and category clearly marked
- [ ] Verification checklist included
- [ ] "Mark as Resolved" section with both manual and API options

**Completion Criteria**:
- ✅ Action commands created for all actionable comments
- ✅ Commands saved in `.cursor/commands/`
- ✅ Commands sorted by severity (Critical → Major → Minor)

**🤖 AI Report Output (MANDATORY)**:

Output the following report AND append it to the main review file:

```

📋 Step 4 Complete - Action Commands Generated

Status: ✅ Success

Total Actionable Comments: [N]
Total Action Commands Created: [N]

Action Commands by Severity:

- 🔴 Critical: [N]
- 🟡 Major: [N]
- 🟢 Minor: [N]

Generated Commands:

### 🔴 Critical Priority

1. `.cursor/commands/action-pr-[PR-NUMBER]-comment-[N]-[timestamp].md`
   - Author: @[author]
   - File: [file or "General"]
   - Issue: [brief description]

### 🟡 Major Priority

2. `.cursor/commands/action-pr-[PR-NUMBER]-comment-[N]-[timestamp].md`
   - Author: @[author]
   - File: [file or "General"]
   - Issue: [brief description]

### 🟢 Minor Priority

3. `.cursor/commands/action-pr-[PR-NUMBER]-comment-[N]-[timestamp].md`
   - Author: @[author]
   - File: [file or "General"]
   - Issue: [brief description]

Next Step: Proceed to Step 5 - Final Report

---

````

**🤖 AI Actions (MANDATORY)**:
- Append summary to main review file
- Create ONE action command file per actionable comment
- Save each action command to `.cursor/commands/action-pr-[PR-NUMBER]-comment-[N]-[timestamp].md`
- Use the command template provided above
- Sort by severity: Critical first, then Major, then Minor

---

### Step 5: Final Report

⚠️ **IMPORTANT: This is the COMPREHENSIVE FINAL REPORT for the user**

**Action**: Generate final summary with all findings and next steps.

**🤖 AI FINAL OUTPUT TO USER (MANDATORY)**:

Display to user using appropriate format based on findings:

---

### Format A: NO ACTIONABLE COMMENTS

Use when there are comments but none require action:

```markdown
═══════════════════════════════════════════════════════════════
✅ PR REVIEW - NO ACTION REQUIRED
═══════════════════════════════════════════════════════════════

## 📊 Review Summary

**PR**: #[PR-NUMBER] - [title]
**Repository**: [owner/repo]
**Author**: @[author]
**State**: [state]
**Branch**: [head] → [base]

**Review Report**: `.cursor/reviews/review-pr-[PR-NUMBER]-[timestamp].md`

---

## 💬 Comments Analyzed

**Total Comments**: [N]
**Actionable Comments**: 0

**Comment Breakdown**:
- ℹ️ Info/Discussion: [N]
- ✅ Approvals: [N]
- ❓ Questions (answered): [N]

---

## ✅ VERDICT: No Action Required

All comments are informational or have been addressed. No fixes needed.

**Next Steps**:
1. Review comments for context
2. Merge when ready (if approved)

═══════════════════════════════════════════════════════════════
END OF PR REVIEW
═══════════════════════════════════════════════════════════════
````

---

### Format B: ACTIONABLE COMMENTS FOUND

Use when there are comments requiring action:

```markdown
═══════════════════════════════════════════════════════════════
🎯 PR REVIEW - ACTION ITEMS CREATED
═══════════════════════════════════════════════════════════════

## 📊 Review Summary

**PR**: #[PR-NUMBER] - [title]  
**Repository**: [owner/repo]  
**Author**: @[author]  
**State**: [state]  
**Branch**: [head] → [base]  
**PR URL**: [url]

**Review Report**: `.cursor/reviews/review-pr-[PR-NUMBER]-[timestamp].md`

---

## 💬 Comments Summary

**Total Comments**: [N]  
**Actionable Comments**: [N]  
**Info Only**: [N]

### Issues by Severity

- 🔴 Critical: [N] (MUST FIX BEFORE MERGE)
- 🟡 Major: [N] (Should fix before merge)
- 🟢 Minor: [N] (Optional improvements)

### Issues by Category

- 🐛 Bug: [N]
- 🏗️ Architecture: [N]
- 🎨 Code Quality: [N]
- 📝 Documentation: [N]
- ❓ Question: [N]

---

## 🛠️ ACTION COMMANDS GENERATED

[N] action command(s) created - one per actionable comment:

### 🔴 Critical Priority [if any]

1. **`.cursor/commands/action-pr-[PR-NUMBER]-comment-[N]-[timestamp].md`**
   - 👤 Author: @[author]
   - 📁 File: `[file]` [or "General"]
   - 🔗 [View Comment]([comment-url])
   - ⚠️ Issue: [brief description]

### 🟡 Major Priority [if any]

2. **`.cursor/commands/action-pr-[PR-NUMBER]-comment-[N]-[timestamp].md`**
   - 👤 Author: @[author]
   - 📁 File: `[file]` [or "General"]
   - 🔗 [View Comment]([comment-url])
   - ⚠️ Issue: [brief description]

### 🟢 Minor Priority [if any]

3. **`.cursor/commands/action-pr-[PR-NUMBER]-comment-[N]-[timestamp].md`**
   - 👤 Author: @[author]
   - 📁 File: `[file]` [or "General"]
   - 🔗 [View Comment]([comment-url])
   - 💡 Suggestion: [brief description]

**How to use**: Open any action command file to see the full comment context and step-by-step fix instructions.

---

## 🎯 VERDICT

**Status**: [⚠️ Needs Attention / ❌ Blocking Issues Found]

**Required Actions**:

[If Critical issues exist]
🔴 **CRITICAL**: [N] blocking issue(s) must be fixed before merge

- [Brief list of critical issues]

[If Major issues exist]
🟡 **MAJOR**: [N] issue(s) should be addressed before merge

- [Brief list of major issues]

[If Minor issues exist]
🟢 **MINOR**: [N] optional improvement(s)

- Can be addressed later or declined

---

## 📋 Action Plan

**Immediate Steps**:

1. Review all 🔴 Critical action commands
2. Apply fixes for Critical issues
3. Review 🟡 Major action commands
4. Address Major issues or provide justification
5. Respond to comments on GitHub
6. Request re-review after fixes

**After Fixes**:

- Push fixes to PR branch
- Mark resolved comments on GitHub
- Request final review from reviewers

---

## 📁 Files Requiring Changes

[List files mentioned in comments]

1. `[file1]` - [N] comments
   - Action: `.cursor/commands/action-pr-[PR-NUMBER]-comment-[N]-[timestamp].md`
2. `[file2]` - [N] comments
   - Action: `.cursor/commands/action-pr-[PR-NUMBER]-comment-[M]-[timestamp].md`
     ...

[If General comments not tied to specific files]
**General/Multiple Files**: [N] comments

- Action commands: [list]

---

## 👥 Reviewers

Comments by reviewer:

- @[reviewer1]: [N] comments ([N] actionable)
- @[reviewer2]: [N] comments ([N] actionable)
  ...

---

## 🔗 Quick Links

- 📝 PR: [PR URL]
- 📊 Full Report: `.cursor/reviews/review-pr-[PR-NUMBER]-[timestamp].md`
- 🛠️ Action Commands: `.cursor/commands/action-pr-[PR-NUMBER]-comment-*-[timestamp].md`

═══════════════════════════════════════════════════════════════
END OF PR REVIEW
═══════════════════════════════════════════════════════════════
```

---

**🤖 AI Actions (MANDATORY)**:

- Determine which format to use:
  - Format A: If 0 actionable comments
  - Format B: If any actionable comments
- Append appropriate format to main review file
- Display to user
- Ensure all files are properly saved and accessible

---

## Error Handling

### Common Errors and Solutions

**Error: Invalid PR URL**

- **Cause**: URL format not recognized
- **Solution**: Ensure URL is in format: `https://github.com/owner/repo/pull/NUMBER`

**Error: Credentials not found**

- **Cause**: `.cursor/credentials/github.json` doesn't exist
- **Solution**: Create credentials file with GitHub token (see Prerequisites)

**Error: Authentication failed (401)**

- **Cause**: Invalid or expired token
- **Solution**: Generate new GitHub token with correct permissions

**Error: PR not found (404)**

- **Cause**: PR doesn't exist or repository is private without access
- **Solution**: Verify PR number and ensure token has access to repository

**Error: Rate limit exceeded**

- **Cause**: Too many API requests
- **Solution**: Wait for rate limit to reset (check headers for reset time)

**Error: No comments found**

- **Cause**: PR has no comments yet
- **Solution**: Report "No comments to review" and exit gracefully

---

## Workflow Verification

**Before Starting**:

- [ ] GitHub credentials configured in `.cursor/credentials/github.json`
- [ ] Token has correct permissions (repo, read:discussion)
- [ ] Valid PR URL provided
- [ ] PR exists and is accessible

**After Pre-Steps**:

- [ ] PR URL parsed successfully
- [ ] Credentials validated
- [ ] Previous reviews cleaned up
- [ ] Session initialized

**After Step 1**:

- [ ] PR details fetched
- [ ] PR metadata extracted
- [ ] Comment counts retrieved

**After Step 2**:

- [ ] All comment types fetched
- [ ] Issue comments retrieved
- [ ] Review comments retrieved
- [ ] PR reviews retrieved

**After Step 3**:

- [ ] All comments analyzed
- [ ] Actionable comments identified
- [ ] Severity levels assigned
- [ ] Categories assigned

**After Step 4**:

- [ ] Action commands generated
- [ ] One command per actionable comment
- [ ] Commands sorted by severity

**After Step 5**:

- [ ] Final report complete
- [ ] Summary displayed to user
- [ ] All files saved
- [ ] Next steps clear

---

## Advanced Features

### Pagination for Large PRs

**Note**: The GraphQL query in Step 2.4 uses `first: 100` which limits results to 100 threads/comments.

For PRs with more than 100 review threads, implement pagination:

```bash
# Check pageInfo.hasNextPage
# If true, make another request with:
# after: "endCursor_value"

# Example second page:
curl -X POST -H "Authorization: bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "query": "query($owner: String!, $name: String!, $number: Int!, $after: String) { repository(owner: $owner, name: $name) { pullRequest(number: $number) { reviewThreads(first: 100, after: $after) { nodes { id isResolved isOutdated comments(first: 100) { nodes { databaseId body author { login } path line } } } pageInfo { hasNextPage endCursor } } } } }",
    "variables": {
      "owner": "owner",
      "name": "repo",
      "number": 582,
      "after": "Y3Vyc29yOnYyOpK5..."
    }
  }' \
  https://api.github.com/graphql
```

**🤖 AI Implementation**:

1. Check `pageInfo.hasNextPage` after each request
2. If `true`, make additional request with `after: endCursor`
3. Combine results from all pages
4. Most PRs will fit in first page (100 threads is ~300-500 comments)

---

### Optional Enhancements

**Auto-link to Files**:

- For inline comments, provide direct links to file locations
- Use format: `[file]:[line]`

**Comment Threading**:

- Group related comments together
- Show reply chains
- Identify resolved vs unresolved threads

**Reviewer Statistics**:

- Track review patterns
- Show most active reviewers
- Highlight blocking reviewers

**Historical Tracking**:

- Keep history of all PR reviews
- Track fix completion rates
- Show trend over time

**Integration with BUGBOT**:

- Cross-reference with BUGBOT checklist
- Identify if comments match existing rules
- Suggest preventive measures

**Smart Re-run Detection**:

- Track which action commands have been executed
- Skip creating duplicate action commands
- Show "Already addressed" status for completed items

---

## Notes

- This workflow is designed to be executed by AI assistance
- Each step builds on the previous one
- Do not skip verification checklists
- Document all findings thoroughly
- Prioritize critical issues
- Always provide direct links to comments
- Respect GitHub API rate limits
- Keep credentials secure and never commit them
- **IMPORTANT**: This workflow uses GraphQL API exclusively for resolved/outdated detection
- Always filter out resolved and outdated comments to avoid duplicate action items
- Re-running the command on the same PR will skip already resolved comments
- GraphQL API provides 100% accurate `isResolved` and `isOutdated` flags
- **MANDATORY**: Always include Thread ID in action commands for marking as resolved
- Action commands must include instructions to mark comment as resolved after fix
