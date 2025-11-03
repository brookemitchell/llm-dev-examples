# Run All Tests and Fix Failures

## Purpose

Get the test suite green by systematically identifying, diagnosing, and fixing test failures. A passing test suite is essential for confident deployments and prevents regressions.

**Context**: Test failures are expensive—they block deployments, slow down development, and erode confidence in the test suite. The goal is not just to make tests pass, but to ensure they're testing the right things and catching real bugs. Don't hack fixes that make tests pass without actually fixing the underlying issues.

## Critical Principles

1. **Understand WHY the test is failing before fixing it**

   - Read the test code and understand what it's testing
   - Read the error message completely
   - Check what changed recently that might have caused it
   - **WHY**: Blindly making tests pass can hide real bugs

2. **Never make tests pass by weakening them**

   - Bad: Increase timeout from 100ms to 10s because test is slow
   - Good: Fix the performance issue, keep timeout strict
   - Bad: Remove assertion that's failing
   - Good: Fix code so assertion passes
   - **WHY**: Weak tests don't catch bugs

3. **Fix the root cause, not the symptom**

   - Test fails intermittently? → Fix the race condition, don't retry
   - Test fails after code change? → Fix the code or update the test appropriately
   - Test fails in CI but not locally? → Fix the environment assumption
   - **WHY**: Symptom fixes come back to haunt you

4. **One test at a time, verify after each fix**
   - Don't batch-fix 10 tests then re-run
   - Fix one, verify it passes, move to next
   - **WHY**: Prevents cascading mistakes

## Steps

### 1. Run the Full Test Suite

**Execute all tests and capture output**:

```bash
# Run with verbose output
npm test -- --verbose > test-output.txt 2>&1

# Or for specific test types
npm run test:unit
npm run test:integration
npm run test:e2e

# Note: Run ALL tests, not just changed files
# (Changes in one place can break tests elsewhere)
```

**Collect information**:

- How many tests total?
- How many failed?
- Which tests failed?
- What are the error messages?

### 2. Analyze and Categorize Failures

**For each failure, determine the category**:

**A. Recent regressions** (tests that passed before recent changes)

```
Priority: 🔴 CRITICAL
Likely cause: Your recent changes broke existing functionality
Action: Fix the code or update the test if requirements changed
```

**B. Flaky tests** (pass sometimes, fail sometimes)

```
Priority: 🟡 HIGH
Likely cause: Race conditions, timing issues, shared state, external dependencies
Action: Make test deterministic, fix concurrency bugs
```

**C. Environment-specific failures** (fail in CI, pass locally)

```
Priority: 🟡 HIGH
Likely cause: Different OS, timezone, environment variables, missing dependencies
Action: Make tests portable, document dependencies
```

**D. Pre-existing failures** (were already failing)

```
Priority: 🟢 MEDIUM
Likely cause: Technical debt, incomplete features, known bugs
Action: Fix or skip with clear TODO
```

### 3. Fix Failures Systematically

**For each test failure**:

#### Step A: Read the Test

⚠️ **CRITICAL: Read the actual test code before changing anything**

```javascript
// Understand WHAT the test is testing
test("user can update profile with valid data", async () => {
  // Arrange: Setup
  const user = await createTestUser({ email: "test@example.com" });
  const newData = { name: "John Doe", age: 30 };

  // Act: Execute
  const result = await updateUserProfile(user.id, newData);

  // Assert: Verify
  expect(result.name).toBe("John Doe");
  expect(result.age).toBe(30);
  expect(result.email).toBe("test@example.com"); // Email unchanged
});
```

- What is the test verifying?
- What setup is required?
- What are the assertions checking?
- **WHY**: You can't fix what you don't understand

#### Step B: Understand the Failure

**Read the error message completely**:

```
Example error:
  Expected: "John Doe"
  Received: undefined

  at Object.<anonymous> (test/user.test.js:42:23)
```

**Ask**:

- What was expected vs what was received?
- At what line did it fail?
- Is there a stack trace showing the path?
- **WHY**: Error messages contain critical information

#### Step C: Investigate the Cause

```javascript
// Add debugging if needed
test("user can update profile with valid data", async () => {
  const user = await createTestUser({ email: "test@example.com" });
  const newData = { name: "John Doe", age: 30 };

  const result = await updateUserProfile(user.id, newData);

  console.log("Result:", JSON.stringify(result, null, 2)); // Debug output

  expect(result.name).toBe("John Doe");
});
```

**Common causes**:

- Function changed its return type
- Database/mock not setup correctly
- Async operation not awaited
- Environment variable missing
- Race condition

#### Step D: Apply the Correct Fix

**Fix the code (if test is correct)**:

```javascript
// ❌ Bad: Function returns undefined instead of updated user
async function updateUserProfile(userId, data) {
  await db.users.update(userId, data);
  // Missing: return the updated user
}

// ✅ Good: Return the updated user
async function updateUserProfile(userId, data) {
  await db.users.update(userId, data);
  return await db.users.findById(userId); // Return updated user
}
```

**Update the test (if code changed intentionally)**:

```javascript
// If updateUserProfile now returns just {success: true}
// Update test to match new behavior:
test("user can update profile with valid data", async () => {
  const user = await createTestUser({ email: "test@example.com" });
  const newData = { name: "John Doe", age: 30 };

  const result = await updateUserProfile(user.id, newData);

  // Update assertions to match new return type
  expect(result.success).toBe(true);

  // Verify update actually happened
  const updatedUser = await db.users.findById(user.id);
  expect(updatedUser.name).toBe("John Doe");
});
```

#### Step E: Fix Flaky Tests

**Common flaky test patterns and fixes**:

**❌ Race condition**:

```javascript
// Bad: Assumes async operation finishes immediately
test("updates counter", async () => {
  incrementCounterAsync();
  expect(counter).toBe(1); // Fails randomly
});
```

**✅ Wait for async operations**:

```javascript
// Good: Actually wait for completion
test("updates counter", async () => {
  await incrementCounterAsync(); // Wait for it
  expect(counter).toBe(1);
});
```

**❌ Shared state between tests**:

```javascript
// Bad: Tests affect each other
let sharedCounter = 0;

test("increments counter", () => {
  sharedCounter++;
  expect(sharedCounter).toBe(1); // Fails if other test ran first
});
```

**✅ Isolate test state**:

```javascript
// Good: Each test gets fresh state
test("increments counter", () => {
  let counter = 0; // Fresh state
  counter++;
  expect(counter).toBe(1);
});

// Or use beforeEach
beforeEach(() => {
  sharedCounter = 0; // Reset before each test
});
```

**❌ Timing assumptions**:

```javascript
// Bad: Assumes operation takes < 100ms
test("fetches data quickly", async () => {
  const start = Date.now();
  await fetchData();
  expect(Date.now() - start).toBeLessThan(100); // Flaky
});
```

**✅ Test behavior, not timing**:

```javascript
// Good: Test that it works, not how fast
test("fetches data successfully", async () => {
  const data = await fetchData();
  expect(data).toBeDefined();
  expect(data.users).toBeInstanceOf(Array);
});
```

#### Step F: Verify Fix

```bash
# Run the specific test you fixed
npm test -- user.test.js

# Run it multiple times to check for flakiness
for i in {1..10}; do npm test -- user.test.js || break; done

# Run the full suite to ensure no regressions
npm test
```

### 4. Handle Pre-Existing Failures

If tests were already failing (technical debt):

**Option A: Fix them** (preferred)

**Option B: Skip with a clear TODO**

```javascript
// Temporarily skip failing test with ticket
test.skip("user can export data as CSV", async () => {
  // TODO(JIRA-1234): Fix CSV export encoding issue
  // Skipped because: UTF-8 characters are incorrectly encoded
  // Timeline: Fix scheduled for Sprint 23
});
```

**Option C: Delete dead tests**

```javascript
// If feature was removed, delete the test
// Don't leave broken tests for removed features
```

## Anti-Patterns to Avoid

❌ **Increasing timeouts to make slow tests pass**

```javascript
// Bad: Hiding performance issues
test("loads dashboard", async () => {
  await page.goto("/dashboard", { timeout: 60000 }); // Was 5000
});
```

❌ **Removing failing assertions**

```javascript
// Bad: Making test useless
test("validates email", () => {
  validateEmail("invalid-email");
  // expect(result.isValid).toBe(false) // <- Removed because it failed
});
```

❌ **Adding random sleeps**

```javascript
// Bad: Flaky fix
test("updates UI", async () => {
  await updateData();
  await sleep(1000); // Hope it finishes in 1s
  expect(ui.text).toBe("Updated");
});
```

❌ **Mocking everything to make tests pass**

```javascript
// Bad: Test doesn't test anything real
test("processes payment", async () => {
  jest.mock("./payment-service"); // Mock to avoid failure
  await processPayment(order);
  expect(true).toBe(true); // Useless assertion
});
```

## Verification Checklist

- [ ] All tests run (unit, integration, e2e)
- [ ] Captured complete error output
- [ ] Categorized failures (regression/flaky/environment/existing)
- [ ] Read each failing test to understand intent
- [ ] Investigated root cause (not just symptom)
- [ ] Applied correct fix (code fix or test update)
- [ ] Did not weaken tests to make them pass
- [ ] Verified each fix works (ran multiple times if flaky)
- [ ] Full test suite is green
- [ ] Documented any skipped tests with clear TODOs

## Remember

**Good test fixing**:

- Understands WHY the test failed
- Fixes root cause, not symptoms
- Maintains or improves test quality
- Makes tests more reliable
- One at a time, verified after each

**Bad test fixing**:

- Weakens tests to make them pass
- Adds sleeps/timeouts to hide issues
- Removes assertions that are failing
- Batches changes without verification
- Leaves tests flaky
