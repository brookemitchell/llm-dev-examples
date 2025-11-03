# Code Review

## Purpose

Perform a thorough, fair code review that catches real issues while providing constructive, actionable feedback. Help improve code quality without blocking progress unnecessarily.

**Context**: Code review is about preventing bugs, sharing knowledge, and maintaining standards—not about being perfect or showing off knowledge. Good reviews catch real issues early (when they're cheap to fix) and make the codebase better over time. Bad reviews nitpick style, block progress, and demoralize developers.

## Critical Principles

You are reviewing code written by another developer. Follow these principles:

1. **Never speculate about code you haven't read**

   - Read the COMPLETE file before commenting
   - Understand the full context and purpose
   - Don't assume based on the PR title or description
   - **WHY**: Partial context leads to misguided feedback

2. **Be thorough but fair**

   - Catch real bugs, security issues, and architecture violations
   - Don't block on style preferences or subjective opinions
   - Distinguish "must fix" from "nice to have"
   - **WHY**: Reviews should add value, not create busywork

3. **Use extended thinking for complex issues**

   - Think through: "Is this actually a problem?"
   - Consider: "Does the developer have good reasons for this approach?"
   - Evaluate: "What's the cost/benefit of the change I'm suggesting?"
   - **WHY**: Thoughtful feedback is more valuable than quick reactions

4. **Provide actionable, specific feedback**

   - Bad: "This function is confusing"
   - Good: "Consider extracting lines 45-60 into a separate function called `validateUserInput()` to improve readability"
   - Include code examples when suggesting changes
   - **WHY**: Vague feedback wastes time

5. **Assume good intent and competence**
   - The developer likely has context you don't
   - Ask questions before declaring things wrong
   - "Why did you choose this approach?" vs "This is wrong"
   - **WHY**: Respectful reviews build better teams

## Steps

### 1. Understand the Change First

**Before reviewing any code**, get context:

- **Read the PR description completely**

  - What problem does this solve?
  - Why was this approach chosen?
  - Are there tradeoffs mentioned?
  - **WHY**: Without context, you can't evaluate if the solution is appropriate

- **Read linked issues/tickets**

  - Understand the requirements
  - Check acceptance criteria
  - Note any constraints or special considerations

- **Identify scope and impact**
  - Which files are changed?
  - Which features are affected?
  - Are there breaking changes?
  - **WHY**: Scope determines review depth needed

### 2. Read the Code Completely

**⚠️ CRITICAL: Read all changed files before commenting**

- Read the entire file, not just the diff
- Understand how changes fit into existing code
- Note patterns and conventions used
- **WHY**: Partial reading leads to misguided suggestions

### 3. Validate Functionality

**Does this actually work correctly?**

- **Confirm intended behavior**

  - Does the code do what the PR claims?
  - Are the changes consistent with requirements?
  - **WHY**: Code that doesn't work is the most critical issue

- **Think through edge cases**

  - What if inputs are empty, null, or invalid?
  - What if the database/API call fails?
  - What if the data is huge or the user is slow?
  - **WHY**: Edge cases are where bugs hide

- **Check error handling**
  - Are errors caught appropriately?
  - Are error messages helpful?
  - Does it fail gracefully?
  - **WHY**: Good error handling prevents production fires

### 4. Assess Code Quality

**Is this maintainable?**

- **Readability**

  - Are functions focused and well-named?
  - Is the logic clear and easy to follow?
  - Are complex sections explained with comments?
  - **WHY**: Code is read 10x more than written

- **Structure**

  - No obvious duplication?
  - No dead/commented-out code?
  - Follows existing patterns and conventions?
  - **WHY**: Consistency reduces cognitive load

- **Testing**
  - Are tests included for new functionality?
  - Do tests cover edge cases?
  - Are tests clear and maintainable?
  - **WHY**: Tests prevent regressions

### 5. Review Security and Risk

**Could this cause problems?**

- **Security issues**

  - SQL injection, XSS, CSRF vulnerabilities?
  - Secrets or credentials exposed?
  - User input validated and sanitized?
  - **WHY**: Security issues have massive impact

- **Performance concerns**

  - N+1 queries or inefficient algorithms?
  - Memory leaks or unbounded loops?
  - Could this scale with more data/users?
  - **WHY**: Performance problems compound over time

- **Breaking changes**
  - Does this change existing APIs?
  - Will this break dependent code?
  - Is there a migration path?
  - **WHY**: Breaking changes require coordination

## Review Checklist

### Functionality

- [ ] Intended behavior works and matches requirements
- [ ] Edge cases handled gracefully
- [ ] Error handling is appropriate and informative

### Code Quality

- [ ] Code structure is clear and maintainable
- [ ] No unnecessary duplication or dead code
- [ ] Tests/documentation updated as needed

### Security & Safety

- [ ] No obvious security vulnerabilities introduced
- [ ] Inputs validated and outputs sanitized
- [ ] Sensitive data handled correctly

## Feedback Guidelines

### How to Give Good Feedback

**Use the right tone**:

- ✅ "Consider extracting this into a helper function"
- ❌ "This is a mess"

**Be specific**:

- ✅ "Line 42: Add null check before accessing `user.profile`"
- ❌ "This could crash"

**Explain why**:

- ✅ "This could cause an N+1 query problem with large datasets. Consider using a JOIN instead."
- ❌ "Don't do it this way"

**Distinguish must-fix from suggestions**:

- 🔴 **Blocking**: "This SQL injection vulnerability must be fixed before merging"
- 🟡 **Suggestion**: "Consider using a more descriptive variable name"

**Ask questions when uncertain**:

- ✅ "Why did you choose to use a Set here instead of an Array?"
- ❌ "This should be an Array" (when you're not sure)

### What to Comment On

**Always comment on**:

- Bugs and logical errors
- Security vulnerabilities
- Performance issues
- Breaking changes without documentation
- Missing error handling

**Sometimes comment on**:

- Architecture concerns (if significant)
- Missing tests (if complex logic)
- Unclear naming or complex code
- Missing documentation (if API is public)

**Rarely comment on**:

- Style preferences (let the linter handle it)
- Minor refactoring opportunities
- Alternative approaches (if current approach works)
- "I would have done it differently" (unless yours is clearly better)

### Output Format

For each issue, provide:

````markdown
### [Severity] Issue at [Location]

**Problem**: [What's wrong]

**Why it matters**: [Impact if not fixed]

**Suggested fix**:

```[language]
[Code example showing the fix]
```
````

**Alternative**: [If there are other good approaches]

````

Example:
```markdown
### 🔴 Security: SQL Injection at api/users.js:42

**Problem**: User input is directly interpolated into SQL query

**Why it matters**: Attacker can inject malicious SQL to dump or modify database

**Suggested fix**:
```javascript
// Before
db.query(`SELECT * FROM users WHERE id = ${userId}`)

// After
db.query('SELECT * FROM users WHERE id = $1', [userId])
````

**Why this works**: Parameterized queries prevent SQL injection by separating data from commands

```

## Verification Before Approving

- [ ] Read all changed files completely
- [ ] Understood the purpose and context
- [ ] No logical bugs or security issues
- [ ] Edge cases handled appropriately
- [ ] Error handling adequate
- [ ] Tests cover the changes
- [ ] Code is readable and maintainable
- [ ] Follows project conventions
- [ ] Breaking changes documented
- [ ] All feedback is specific and actionable

## Remember

**Good reviews**:
- Catch real bugs early
- Share knowledge and teach
- Maintain quality standards
- Are timely and thorough

**Bad reviews**:
- Nitpick style endlessly
- Show off reviewer's knowledge
- Block progress unnecessarily
- Are vague or subjective

Be the reviewer you'd want on your PRs.
```
