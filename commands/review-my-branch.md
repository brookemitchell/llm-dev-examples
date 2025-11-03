# Branch Review

## Purpose

Comprehensively review all branch changes against project architecture standards before merging to staging. This catches issues before they pollute the main codebase and ensures consistent quality across the team.

**Context**: Pre-merge review is your quality gate. Finding issues in your branch is 100x cheaper than finding them in staging after merge. This automated workflow ensures no architectural violations slip through, maintaining codebase health over time.

## Critical Execution Principles

You are executing a thorough branch review workflow. Follow these principles throughout:

1. **Never speculate about code you haven't read**

   - ALWAYS read the complete file before making any judgment
   - Don't assume based on file names, commit messages, or branch name
   - **WHY**: Speculation leads to hallucinations and false positives

2. **Use extended thinking for complex architectural decisions**

   - When evaluating architecture violations, reason through the implications
   - Consider whether an issue is a real problem or acceptable in context
   - Think about how changes fit into the broader system
   - **WHY**: Architecture review requires understanding system-wide impacts

3. **Be thorough but pragmatic**

   - Report real issues with specific evidence (line numbers, code snippets)
   - Don't block merges for minor style preferences
   - Distinguish between must-fix and nice-to-have
   - **WHY**: Reviews should add value, not create busywork

4. **Generate actionable fixes**

   - Every issue must have a clear path to resolution
   - Include code examples showing before/after
   - Provide context for WHY the change improves the code
   - **WHY**: Actionable feedback speeds up the fix cycle

5. **Work efficiently with parallel operations**
   - Read multiple files simultaneously when possible
   - Process independent checks in parallel
   - **WHY**: Faster reviews = shorter feedback loops = better velocity

**Objective**: Ensure all code changes meet project architecture standards before merging to staging.

---

## 📁 Output Files

All reports and todo-lists will be saved in `.cursor/reviews/` directory:

**File Naming Convention**:

- **Main Review Report**: `.cursor/reviews/review-branch-[YYYYMMDD-HHMMSS].md`
- **Action Commands**: `.cursor/commands/action-[filename-slug]-[YYYYMMDD-HHMMSS].md` (one per file with issues)

**Important**:

- The main review report contains ALL step outputs in a single file
- Each step's report is appended to the main review file as it completes
- For each file with issues, an action command is automatically generated
- Action commands are executable Cursor commands that fix the specific issues
- Timestamp format: `YYYYMMDD-HHMMSS` (e.g., `20251014-153045`)

**🤖 AI Instructions (MANDATORY)**:

1. At the start of the review, create the main review file with timestamp
2. After each step, append the step report to the main review file
3. At the end, for EACH file with issues, generate an action command file
4. Provide links to all generated action commands in the final output

---

## Workflow

### Pre-Step: Cleanup Previous Reviews

**Action**: Clean up all previous review files and action commands before starting a new review session.

**🤖 AI Actions (MANDATORY)**:

1. Delete all files in `.cursor/reviews/` directory
2. Delete all files starting with `action-` in `.cursor/commands/` directory

**Commands to execute**:

```bash
# Remove all review files
rm -f .cursor/reviews/*

# Remove all action command files
rm -f .cursor/commands/action-*.md
```

**Verification**:

- [ ] All files in `.cursor/reviews/` deleted
- [ ] All `action-*.md` files in `.cursor/commands/` deleted
- [ ] Directories still exist (only files removed)

**Completion Criteria**:

- ✅ Cleanup completed successfully
- ✅ Ready for new review session

**🤖 AI Report Output (MANDATORY)**:

Output to user:

```
🧹 Cleanup Complete

Status: ✅ Success

Files Removed:
- .cursor/reviews/*: [N] files deleted
- .cursor/commands/action-*.md: [N] files deleted

Directories: Preserved
Ready to start new review session.

---
```

---

### Step 0: Initialize Review Session

**Action**: Create the review report file and initialize the session.

**🤖 AI Actions (MANDATORY)**:

1. Generate timestamp: `YYYYMMDD-HHMMSS`
2. Create directory: `.cursor/reviews/` (if not exists)
3. Create main report file: `.cursor/reviews/review-branch-[timestamp].md`
4. Initialize report file with header:

   ```markdown
   # Branch Review Report

   Date: [date]
   Timestamp: [timestamp]
   Branch: [branch-name]
   Comparing Against: staging

   ---
   ```

5. Store timestamp for use in fix todo-list filename

**Completion Criteria**:

- ✅ Review report file created
- ✅ Timestamp stored for session

---

### Step 1: Preparation & Discovery

#### 1.1 Identify Commits

**Action**: List all commits ahead of staging signed by the current git user.

**Command**:

```bash
git log staging..HEAD --author="$(git config user.name)" --oneline
```

**Expected Output**:

- Format: `<commit-sha> <commit-message>`
- One line per commit
- Example:
  ```
  8ed6083fc final changes
  e27dc56e8 now with 99% more infinite scroller flavour!
  bbcd10cea fully working and implemented
  ```

**Verification Checklist**:

- [ ] Command executed successfully
- [ ] At least one commit found
- [ ] All commits are authored by current user
- [ ] Commit messages are descriptive

**Completion Criteria**:

- ✅ If commits found: Proceed to 1.2
- ⛔ If no commits found: Stop and report "No commits to review"

**🤖 AI Report Output (MANDATORY)**:

Output the following report AND append it to `.cursor/reviews/review-branch-[timestamp].md`:

```
📋 Step 1.1 Complete - Commit Identification

Status: [✅ Success / ❌ Failed]
Branch: [current-branch-name]
Comparing Against: staging
Git User: [user-name]

Commits Found: [N]

Commit List:
1. [sha] - [message]
2. [sha] - [message]
...

Command Executed:
git log staging..HEAD --author="$(git config user.name)" --oneline

Date Range: [earliest] to [latest]

Next Step: [Proceed to 1.2 / Stop - No commits]

---
```

**🤖 AI Action**: Append this report to the main review file

---

#### 1.2 Extract Changed Files

**Action**: Get all files modified in the author's commits only (excluding deleted files).

**Command**:

```bash
git log staging..HEAD --author="$(git config user.name)" --name-only --diff-filter=d --pretty=format: | sort -u | grep -v '^$'
```

**Expected Output**:

- One file path per line
- Deduplicated list
- Example:
  ```
  apps/studio2/app/[locale]/(dashboard)/(sidebar)/playlists/page.tsx
  apps/studio2/components/playlists/playlist-form-dialog.tsx
  apps/studio2/hooks/use-playlists.ts
  ```

**Verification Checklist**:

- [ ] Command executed successfully
- [ ] File paths are valid and exist in workspace
- [ ] No deleted files in the list
- [ ] Files are deduplicated
- [ ] All files belong to commits from current author

**Completion Criteria**:

- ✅ File list generated successfully
- ✅ At least one file found

**🤖 AI Report Output (MANDATORY)**:

Output the following report AND append it to the main review file:

```
📋 Step 1.2 Complete - Changed Files Extraction

Status: ✅ Success
Total Files Extracted: [N]
Source: Commits by [author-name]

Files by Type:
- Components (.tsx/.jsx): [N]
- Hooks (.ts/.tsx): [N]
- Queries/API (.ts): [N]
- Types (.ts): [N]
- Schemas (.ts): [N]
- Config files: [N]
- Other: [N]

Complete File List:
1. [file-path-1]
2. [file-path-2]
...

Command Executed:
git log staging..HEAD --author="$(git config user.name)" --name-only --diff-filter=d --pretty=format: | sort -u | grep -v '^$'

Next Step: Proceed to 1.3 - Create Review Todo List

---
```

**🤖 AI Action**: Append this report to the main review file

---

#### 1.3 Create Review Todo List

**Action**: Create a todo list with one item per file to be reviewed.

**Format**: `Review: [relative-path-to-file]`

**Example**:

```
- [ ] Review: app/[locale]/(dashboard)/(sidebar)/playlists/page.tsx
- [ ] Review: components/playlists/playlist-form-dialog.tsx
- [ ] Review: hooks/use-playlists.ts
```

**Verification Checklist**:

- [ ] Todo list created successfully
- [ ] One todo item per file
- [ ] All todos marked as "pending"
- [ ] File paths are relative to workspace root

**Completion Criteria**:

- ✅ Todo list created with all files from 1.2

**🤖 AI Report Output (MANDATORY)**:

Output the following report AND append it to the main review file:

```
📋 Step 1.3 Complete - Review Todo List Created

Status: ✅ Success
Total Todo Items: [N]

Todo List:
- [ ] Review: [file-1]
- [ ] Review: [file-2]
- [ ] Review: [file-3]
...

All items marked as: pending
Ready to begin file-by-file review.

Next Step: Proceed to Step 2 - Apply Review Checklist

---
```

**🤖 AI Action**: Append this report to the main review file

---

### Step 2: Load Review Checklist

**Action**: Load the comprehensive BUGBOT review checklist into memory before proceeding with file reviews.

**File to Read**: `.cursor/BUGBOT.md`

**🤖 AI Action (MANDATORY)**:

```
Read and load into memory: .cursor/BUGBOT.md
```

This file contains:

- Complete project architecture checklist
- 12 review sections covering all aspects
- English typo verification (Section 11)
- Severity level definitions (Critical, Major, Minor)
- Common anti-patterns to avoid

**Verification Checklist**:

- [ ] BUGBOT.md file loaded successfully
- [ ] All 12 sections available in memory
- [ ] Ready to apply checklist to each file

**Completion Criteria**:

- ✅ BUGBOT.md loaded and ready for use
- ✅ Proceed to Step 3

**🤖 AI Report Output (MANDATORY)**:

Output the following report AND append it to the main review file:

```
📋 Step 2 Complete - Review Checklist Loaded

Status: ✅ Success
Checklist File: .cursor/BUGBOT.md
Sections Loaded: 12

Review Checklist Sections:
1. Architecture & Framework
2. Data Layer
3. React Query Configuration
4. Forms & Validation
5. Realtime
6. File Structure
7. Code Quality
8. Security
9. Internationalization
10. Linting & Build
11. Documentation & Language (includes English typo check)
12. Common Anti-Patterns

Severity Levels:
- 🔴 Critical
- 🟡 Major
- 🟢 Minor

Next Step: Proceed to Step 3 - File-by-File Review

---
```

**🤖 AI Action**: Append this report to the main review file

---

### Step 3: File-by-File Review Process

#### 3.1 Review Execution

**Action**: For each file in the todo list, execute a comprehensive review against the BUGBOT checklist loaded in Step 2.

**Procedure**:

1. Mark current todo item as "in_progress"
2. Read the file contents
3. Apply BUGBOT checklist (all 12 sections from `.cursor/BUGBOT.md`)
4. Document findings (pass/fail for each applicable check)
5. **Pay special attention to Section 11: English typos & grammar**
6. Mark todo item as "completed"
7. Repeat for next file

**Verification Checklist**:

- [ ] File read successfully
- [ ] All applicable checklist items evaluated
- [ ] Findings documented with line numbers/code references
- [ ] Issues categorized by severity (critical/major/minor)
- [ ] Pass/fail status determined

**🤖 AI Report Output (MANDATORY - Per File)**:

⚠️ **IMPORTANT: Use appropriate report format based on findings**

**If file has NO issues (passes completely)**:
Use brief summary format:

```
📋 Step 3.1 - File Review: [filename]

File: [full-path] | Lines: [N] | Status: ✅ PASS
Issues: 0 (0 Critical, 0 Major, 0 Minor)

Summary: [One-line description of what the file does/contains]

Todo Status: completed ✅
---
```

**If file has ANY issues (Critical, Major, or Minor)**:
Use detailed format:

```
📋 Step 3.1 - File Review: [filename]

Status: ⚠️ Issues Found / ❌ Failed
File: [full-path]
Lines of Code: [N]

BUGBOT Checklist Results:
✅ 1. Architecture & Framework: Pass
✅ 2. Data Layer: Pass
⚠️ 3. React Query Configuration: Issue found
✅ 4. Forms & Validation: Pass / N/A
✅ 5. Realtime: Pass / N/A
✅ 6. File Structure: Pass
⚠️ 7. Code Quality: Minor issues
✅ 8. Security: Pass
✅ 9. Internationalization: Pass / N/A
✅ 10. Linting & Build: Pass
⚠️ 11. Documentation & Language: Typos found
✅ 12. Common Anti-Patterns: Pass

Issues Found: [N]
- 🔴 Critical: [N]
- 🟡 Major: [N]
- 🟢 Minor: [N]

Detailed Findings:

### 🔴 Critical Issues
[List with line numbers and code snippets]

### 🟡 Major Issues
[List with line numbers and code snippets]

### 🟢 Minor Issues
[List with line numbers and code snippets]

Todo Status: completed ✅

---
```

**🤖 AI Action**: Append appropriate report format to the main review file (repeat for each file)

---

#### 3.2 Issue Classification

**Action**: For each file reviewed, classify issues found.

**Severity Levels**:

- **Critical**: Blocks merge, must fix immediately
  - Security vulnerabilities
  - Breaking changes
  - Data loss risks
- **Major**: Should fix before merge
  - Architecture violations
  - Type mismatches
  - Missing error handling
- **Minor**: Can address later
  - Code style inconsistencies
  - Missing documentation
  - Optimization opportunities

**Verification Checklist**:

- [ ] All issues documented with severity level
- [ ] Issue descriptions include file path and line numbers
- [ ] Root cause identified for each issue
- [ ] Recommended fix provided

---

#### 3.3 Review Summary Per File

**Action**: Generate a summary report for each file reviewed.

**Report Format**:

```markdown
## Review: [filename]

**Status**: ✅ Pass / ⚠️ Pass with Issues / ❌ Fail

**Findings**:

- ✅ Architecture & Framework: Pass
- ✅ Data Layer: Pass
- ⚠️ Query Keys: Issue found (line 15)
- ✅ Code Quality: Pass
- ✅ Security: Pass

**Issues**:

1. [Major] userKeys imported from wrong location (line 6)
   - Current: `@/hooks/use-user`
   - Should be: `@/lib/queries/v2/user`
   - Recommendation: Move key factory to fetcher file

**Overall**: Pass with 1 major issue to address
```

**Verification Checklist**:

- [ ] Summary generated for each file
- [ ] All checklist sections addressed
- [ ] Issues clearly documented
- [ ] Status accurately reflects findings
- [ ] Recommendations provided for fixes

**Completion Criteria**:

- ✅ All files reviewed
- ✅ All todo items marked as "completed"
- ✅ Summary generated for each file

**🤖 AI Report Output (MANDATORY - After All Files)**:

Output the following report AND append it to the main review file:

```
📋 Step 3.3 Complete - All Files Reviewed

Status: ✅ Complete
Total Files Reviewed: [N]

Summary by File:
1. [file-1]: ✅ Pass
2. [file-2]: ⚠️ Pass with Issues (1 Major, 2 Minor)
3. [file-3]: ❌ Fail (1 Critical, 2 Major)
...

Overall Statistics:
- ✅ Files Passed: [N]
- ⚠️ Files with Issues: [N]
- ❌ Files Failed: [N]

Total Issues Found:
- 🔴 Critical: [N]
- 🟡 Major: [N]
- 🟢 Minor: [N]

All todo items completed: ✅

Next Step: Proceed to Step 4 - Final Reporting

---
```

**🤖 AI Action**: Append this report to the main review file

---

### Step 4: Final Reporting

#### 4.1 Generate Overall Branch Summary

**Action**: Create a comprehensive summary of the entire branch review.

**Report Sections**:

**4.1.1 Commit Overview**

- Total commits reviewed: [N]
- Commit list with messages
- Date range of commits

**4.1.2 Files Overview**

- Total files reviewed: [N]
- Files by category:
  - Components: [N]
  - Hooks: [N]
  - Queries: [N]
  - Types: [N]
  - Other: [N]

**4.1.3 Review Results**

- ✅ Files passed: [N]
- ⚠️ Files passed with issues: [N]
- ❌ Files failed: [N]

**4.1.4 Issue Summary**

- Critical issues: [N]
- Major issues: [N]
- Minor issues: [N]

**Verification Checklist**:

- [ ] All metrics calculated correctly
- [ ] Commit count matches Step 1.1
- [ ] File count matches Step 1.2
- [ ] Issue counts match Step 3.2 findings
- [ ] Summary is clear and actionable

**🤖 AI Report Output (MANDATORY)**:

Output the following report AND append it to the main review file:

```
📋 Step 4.1 Complete - Overall Branch Summary

Status: ✅ Complete
Branch: [branch-name]
Comparing Against: staging

Commit Overview:
- Total commits reviewed: [N]
- Commits by [author-name]
- Date range: [earliest] to [latest]

Files by Category:
- Components: [N]
- Hooks: [N]
- Queries: [N]
- Types: [N]
- Schemas: [N]
- Config: [N]
- Other: [N]

Review Results:
- ✅ Files passed: [N]
- ⚠️ Files passed with issues: [N]
- ❌ Files failed: [N]

Issue Summary:
- 🔴 Critical issues: [N]
- 🟡 Major issues: [N]
- 🟢 Minor issues: [N]

Next Step: Proceed to 4.2 - Create Fix Todo List

---
```

**🤖 AI Action**: Append this report to the main review file

---

#### 4.2 Generate Action Commands

⚠️ **IMPORTANT: Generate executable Cursor commands for automatic fixes**

**Action**: For EACH file with issues (Critical, Major, or Minor), generate a dedicated action command file.

**File Naming**: `.cursor/commands/action-[filename-slug]-[timestamp].md`

- Convert file path to slug: replace `/` with `-`, remove extensions
- Example: `app/[locale]/playlists/page.tsx` → `action-app-locale-playlists-page-20251014-153045.md`

**Command Template** (for each file):

````markdown
# Fix: [filename]

## Context

- **File**: `[full-file-path]`
- **Review Date**: [date]
- **Issues Found**: [N] ([N] Critical, [N] Major, [N] Minor)
- **Branch**: [branch-name]
- **Review Report**: `.cursor/reviews/review-branch-[timestamp].md`

---

## Issues to Fix

### 🔴 Critical Issues

#### Issue 1: [Issue Title]

- **Line**: [N]
- **Severity**: Critical
- **Description**: [detailed description]
- **Current Code**:
  ```[language]
  [current code snippet]
  ```
````

- **Problem**: [what's wrong]
- **Expected Behavior**: [what should happen]

**Fix Instructions**:

1. [Step-by-step fix instruction]
2. [Next step]
3. [Final step]

**Expected Result**:

```[language]
[fixed code snippet]
```

---

### 🟡 Major Issues

[Same structure as Critical]

---

### 🟢 Minor Issues

[Same structure, but with "Suggestion" instead of "Fix Instructions"]

---

## Fix Checklist

After applying fixes, verify:

- [ ] All critical issues resolved
- [ ] All major issues resolved
- [ ] Code follows project architecture standards
- [ ] No new linter errors introduced
- [ ] File compiles without errors
- [ ] Related tests still pass (if applicable)

---

## Acceptance Criteria

- ✅ All critical issues must be fixed
- ✅ All major issues must be fixed
- ⚠️ Minor issues are optional improvements

---

## Related Files

[If fixes impact other files, list them here]

---

## Command Execution

To fix this file automatically:

1. Open the file: `[file-path]`
2. Review each issue above
3. Apply the fixes in order (Critical → Major → Minor)
4. Run linter to verify
5. Mark this action command as complete

```

**Verification Checklist**:
- [ ] One action command per file with issues
- [ ] Each command is self-contained and actionable
- [ ] All issues from that file included
- [ ] Issues sorted by severity
- [ ] Code snippets included for context
- [ ] Step-by-step fix instructions provided

**Completion Criteria**:
- ✅ Action commands created for all files with issues
- ✅ Commands saved in `.cursor/commands/`
- ✅ All issues from Step 3 included

**🤖 AI Report Output (MANDATORY)**:

1. Append this summary to the main review file:

```

📋 Step 4.2 Complete - Action Commands Generated

Status: ✅ Complete
Total Files with Issues: [N]
Total Action Commands Created: [N]

Action Commands by Severity:

- 🔴 Files with Critical issues: [N]
- 🟡 Files with Major issues: [N]
- 🟢 Files with Minor issues only: [N]

Generated Commands:

1. .cursor/commands/action-[file1-slug]-[timestamp].md
2. .cursor/commands/action-[file2-slug]-[timestamp].md
   ...

Next Step: Proceed to 4.3 - Final Report

---

````

2. For EACH file with issues, create an action command file using the template above

**🤖 AI Actions (MANDATORY)**:
- Append summary to main review file
- Create ONE action command file per file with issues
- Save each action command to `.cursor/commands/action-[filename-slug]-[timestamp].md`
- Use the command template provided above
- Include all issues for that specific file
- Provide step-by-step fix instructions

---

#### 4.3 Review Completion Report

⚠️ **IMPORTANT: This is the COMPREHENSIVE FINAL REPORT for the user**

**Action**: Generate final report with recommendations and next steps.

**Report Template**:
```markdown
# Branch Review Complete - [Branch Name]

## Summary
Reviewed **[N] commits** with **[N] files** modified.

## Results
- ✅ **[N] files** passed all checks
- ⚠️ **[N] files** passed with minor issues
- ❌ **[N] files** require fixes before merge

## Critical Actions Required
[List critical issues that block merge]

## Recommendations
1. Address all critical issues immediately
2. Review and fix major issues before merge
3. Create follow-up tickets for minor improvements

## Merge Readiness
- [ ] No critical issues remain
- [ ] All major issues addressed or documented
- [ ] Code follows Studio v2 architecture
- [ ] Tests passing (if applicable)
- [ ] Documentation updated

**Verdict**: ✅ Ready to Merge / ⚠️ Ready with Caveats / ❌ Not Ready

## Next Steps
[Specific actions to take based on findings]
````

**Verification Checklist**:

- [ ] Report is comprehensive and accurate
- [ ] All critical issues highlighted
- [ ] Merge readiness clearly stated
- [ ] Next steps are actionable
- [ ] Report saved/documented

**Completion Criteria**:

- ✅ Final report generated
- ✅ All stakeholders can understand findings
- ✅ Clear path forward established

**🤖 AI FINAL OUTPUT TO USER (MANDATORY - MOST IMPORTANT)**:

1. Append the final report to the main review file
2. Display final output using appropriate format:

---

### Format A: ALL FILES PASSED (No issues found)

Use this concise format when all files passed with 0 issues:

```markdown
═══════════════════════════════════════════════════════════════
✅ BRANCH REVIEW - ALL CLEAR
═══════════════════════════════════════════════════════════════

## 📊 Review Summary

**Branch**: [branch-name]  
**Comparing Against**: staging  
**Author**: [author-name]  
**Commits**: [N]  
**Files Reviewed**: [N]  
**Status**: ✅ All files passed  
**Issues Found**: 0 (0 Critical, 0 Major, 0 Minor)

**Main Review Report**: `.cursor/reviews/review-branch-[timestamp].md`

---

## ✅ VERDICT: Ready to Merge

All files meet project architecture standards. No fixes required.

**Next Steps**:

1. Merge to staging when ready
2. All code quality standards met

---

## 📁 Files Reviewed

[List all files]

1. ✅ [file-path]
2. ✅ [file-path]
   ...

---

## 📝 Commits Reviewed

1. [sha] - [message]
2. [sha] - [message]
   ...

═══════════════════════════════════════════════════════════════
END OF REVIEW
═══════════════════════════════════════════════════════════════
```

---

### Format B: ISSUES FOUND (Critical, Major, or Minor)

Use this detailed format when issues exist:

```markdown
═══════════════════════════════════════════════════════════════
🎯 BRANCH REVIEW - ACTION REQUIRED
═══════════════════════════════════════════════════════════════

## 📊 Review Summary

**Branch**: [branch-name]  
**Comparing Against**: staging  
**Author**: [author-name]  
**Commits**: [N]  
**Total Files Reviewed**: [N]

### Results

- ✅ **[N] files** passed all checks
- ⚠️ **[N] files** have issues ([total-issues] issues)

### Issues by Severity

- 🔴 Critical: [N] (MUST FIX BEFORE MERGE)
- 🟡 Major: [N] (Should fix before merge)
- 🟢 Minor: [N] (Optional improvements)

**Main Review Report**: `.cursor/reviews/review-branch-[timestamp].md`

---

## 🛠️ ACTION COMMANDS GENERATED

[N] action command(s) created for automatic fixes:

### 🔴 Critical Priority

1. `.cursor/commands/action-[file1-slug]-[timestamp].md`
   - File: `[file-path]`
   - Issues: [N] Critical, [N] Major, [N] Minor

### 🟡 Major Priority

2. `.cursor/commands/action-[file2-slug]-[timestamp].md`
   - File: `[file-path]`
   - Issues: [N] Major, [N] Minor

### 🟢 Minor Priority Only

3. `.cursor/commands/action-[file3-slug]-[timestamp].md`
   - File: `[file-path]`
   - Issues: [N] Minor

**How to use**: Open any action command file and follow the fix instructions.

---

## 🎯 VERDICT

**Status**: [⚠️ Ready with Caveats / ❌ Not Ready to Merge]

**Required Actions**:

1. Fix all 🔴 Critical issues (blocks merge)
2. Fix 🟡 Major issues (recommended before merge)
3. 🟢 Minor issues are optional

**After Fixes**:

- Re-run this review to verify fixes
- Merge when all critical/major issues are resolved

---

## 📁 Files Reviewed

1. ✅ [file-path] - Pass
2. ⚠️ [file-path] - Issues ([N] issues)
   → Action: `.cursor/commands/action-[slug]-[timestamp].md`
3. ❌ [file-path] - Failed ([N] Critical)
   → Action: `.cursor/commands/action-[slug]-[timestamp].md`
   ...

---

## 📝 Commits Reviewed

1. [sha] - [message]
2. [sha] - [message]
   ...

═══════════════════════════════════════════════════════════════
END OF REVIEW
═══════════════════════════════════════════════════════════════
```

---

**🤖 AI Actions**:

- Determine which format to use based on total issues found
- If 0 issues: Use Format A (concise)
- If any issues: Use Format B (detailed)
- Append appropriate format to main review file
- Display to user
- Ensure all files are properly saved and accessible

---

## Workflow Verification

**Before Starting**:

- [ ] On correct branch
- [ ] Staging branch is up to date
- [ ] Git user configured correctly

**After Pre-Step**:

- [ ] All previous review files cleaned up
- [ ] All previous action commands cleaned up
- [ ] Ready for fresh review session

**After Step 1**:

- [ ] Commits identified and listed
- [ ] Files extracted and validated
- [ ] Todo list created

**After Step 2**:

- [ ] Checklist understood and available
- [ ] Ready to apply to each file

**After Step 3**:

- [ ] All files reviewed
- [ ] Issues documented with severity
- [ ] Summaries generated

**After Step 4**:

- [ ] Overall summary complete
- [ ] Fix list created
- [ ] Final report delivered
- [ ] Next steps clear

---

## Notes

- This workflow is designed to be executed by AI assistance
- Each step builds on the previous one
- Do not skip verification checklists
- Document all findings thoroughly
- Prioritize critical issues
