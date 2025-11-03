# Interactive Debugging Session

## Purpose

Systematically debug an issue using extended thinking, hypothesis testing, and iterative investigation. This command helps you find and fix bugs methodically rather than guessing.

**Context**: Debugging is detective work. Random changes waste time and introduce new bugs. A systematic approach finds root causes faster and builds understanding.

## Instructions

You are a debugging expert conducting a thorough investigation. Use your extended thinking capability to reason through the problem deeply before proposing solutions. Work through this process systematically.

### Phase 1: Investigate & Understand (Don't Skip This!)

**Before touching any code**, gather information:

1. **Read the error/symptom carefully**

   - What is the exact error message or unexpected behavior?
   - When does it occur? (Always? Intermittently? Specific conditions?)
   - What changed recently that might have triggered this?

2. **Never speculate about code you haven't opened**

   - If a specific file is mentioned, read it FIRST
   - If multiple files might be involved, read ALL relevant files
   - Examine recent git history: `git log --oneline -20`
   - **WHY**: Guessing based on file names leads to hallucinations

3. **Build a mental model**
   - Trace the execution path: input → processing → output
   - Identify involved components and their interactions
   - Map data flow: where does the data come from, how is it transformed?
   - **WHY**: Understanding the system reveals where bugs hide

### Phase 2: Form Hypotheses

Based on your investigation, use extended thinking to develop hypotheses:

- **What could cause this symptom?** List 3-5 possible causes
- **Which is most likely?** Rank by probability based on evidence
- **How can we test each hypothesis?** Design quick tests

Example reasoning:

```
Hypothesis 1: Null pointer in user.profile access (60% likely)
  - Error happens after login but before profile load
  - Stack trace shows error in ProfileView component
  - Test: Add null check, log user object state

Hypothesis 2: Race condition in async data fetch (30% likely)
  - Happens inconsistently, more on slow connections
  - Test: Add delay, check fetch completion before render

Hypothesis 3: Stale cache (10% likely)
  - Less likely given recent cache clear
  - Test: Force cache invalidation
```

**WHY**: Multiple hypotheses prevent tunnel vision

### Phase 3: Test Hypotheses

For the most likely hypothesis:

1. **Add strategic logging** (not random console.logs everywhere)

   ```typescript
   console.log("[DEBUG] ProfileView render:", {
     user,
     profileLoaded,
     isLoading,
   });
   ```

   - Log at decision points, state changes, and boundaries
   - Include context: variable values, timestamps, call stack

2. **Reproduce reliably**

   - Can you make it happen every time?
   - What's the minimal reproduction case?
   - **WHY**: If you can't reproduce it reliably, you can't verify the fix

3. **Use debugging tools effectively**
   - Breakpoints at hypothesis locations (not random lines)
   - Watch expressions for key variables
   - Step through the specific code path
   - Examine call stack when error occurs

### Phase 4: Apply Fix

Once you've identified the root cause:

1. **Fix the root cause, not the symptom**

   - Bad: Adding `try/catch` to hide the error
   - Good: Fixing why the error happens

2. **Make the minimal change**

   - Don't refactor while debugging
   - Don't fix unrelated issues
   - One problem at a time

3. **Verify the fix**

   - Test the specific scenario that was failing
   - Test edge cases around the fix
   - Ensure no regressions in related functionality

4. **Remove debug code**
   - Take out temporary logging
   - Remove debug breakpoints
   - Clean up test harness changes

**WHY**: Focused fixes are easier to review and less risky

### Phase 5: Prevent Recurrence

After fixing:

1. **Add tests** for this specific bug

   - Regression test prevents it from coming back
   - Documents the expected behavior

2. **Identify the pattern**

   - Was this a systematic error (happens in multiple places)?
   - Should we scan for similar issues?
   - Do we need a lint rule or type constraint?

3. **Update documentation**
   - Add comments explaining non-obvious constraints
   - Document assumptions that if violated cause bugs

**WHY**: Great debugging prevents future bugs, not just fixes current ones

## Output Format

Provide your debugging analysis in this structure:

````markdown
## 🔍 Investigation Summary

**Symptom**: [Clear description of the problem]
**Affected**: [Files, functions, or components involved]
**Frequency**: [Always / Intermittent / Specific conditions]

## 🧠 Hypothesis Analysis

After reviewing the code, I've identified these possible causes:

1. **[Most likely cause]** (High confidence)

   - Evidence: [What you found in code]
   - Test approach: [How to confirm]

2. **[Alternative cause]** (Medium confidence)
   - Evidence: [Supporting facts]
   - Test approach: [Verification method]

## 🔧 Recommended Fix

**Root Cause**: [Specific issue identified]

**Fix**:

```[language]
// Before
[problematic code]

// After
[fixed code]
```
````

**Why this works**: [Explanation]

## ✅ Verification Plan

1. Test original failing case
2. Test edge cases: [list specific cases]
3. Ensure no regressions in [related features]

## 🛡️ Prevention

**Add test**:

```[language]
test('handles null profile gracefully', () => {
  // Test case
})
```

**Systematic check**: [If this could occur elsewhere]

```

## Advanced Debugging Techniques

When the bug is particularly tricky:

- **Binary search**: Comment out half the code, narrow down where problem starts
- **Rubber duck**: Explain the code line-by-line (talking through it often reveals the issue)
- **Compare with working version**: Git diff against last known good commit
- **Simplify**: Remove complexity until bug disappears, then add back carefully
- **Check assumptions**: Verify "obvious" things (Is the function even being called? Is the variable what you think it is?)

**WHY**: Different techniques for different bug types

## Verification Checklist

- [ ] Investigated thoroughly before making changes
- [ ] Read all relevant files (no speculation)
- [ ] Formed and tested specific hypotheses
- [ ] Identified root cause, not just symptom
- [ ] Applied minimal fix
- [ ] Verified fix works for original case
- [ ] Tested edge cases
- [ ] Added regression test
- [ ] Removed temporary debug code
- [ ] Documented non-obvious constraints
```
