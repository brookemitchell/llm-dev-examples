# Add Error Handling

## Purpose

Implement comprehensive, thoughtful error handling that makes code robust, debuggable, and user-friendly. Transform unreliable code that crashes on edge cases into production-ready code that handles failures gracefully.

**Context**: Error handling is NOT about adding try-catch blocks everywhere. It's about anticipating what can go wrong, deciding how to handle each failure mode, and ensuring users/operators get helpful information when things fail. Good error handling prevents 3am pages and angry users.

## Critical Principles

1. **Anticipate, don't just react**

   - Think through: "What can go wrong here?"
   - Consider: Network failures, invalid input, missing data, full disks, etc.
   - **WHY**: Proactive error handling prevents production fires

2. **Handle errors at the right level**

   - Catch where you can actually do something about it
   - Don't catch just to log and re-throw (unless adding context)
   - Let crashes happen for programming errors in development
   - **WHY**: Error handling at the wrong level adds noise without value

3. **Fail fast for programming errors, gracefully for runtime errors**

   - Programming error (dev's fault): `user.profile.email` when profile is null → Let it crash in dev
   - Runtime error (expected): Network timeout → Handle gracefully with retry
   - **WHY**: Crashes in dev help you find bugs; graceful handling in prod keeps users happy

4. **Make errors actionable**
   - Bad: "Error occurred"
   - Good: "Failed to save user profile: Database connection timeout after 30s. Please try again."
   - **WHY**: Actionable errors help users recover and help you debug

## Steps

### 1. Identify Failure Points

**Read the code and think through what can fail**:

- **External dependencies**

  - Database queries (connection fails, query times out, constraint violation)
  - API calls (network error, timeout, 4xx/5xx responses)
  - File system operations (file doesn't exist, permission denied, disk full)
  - **WHY**: External systems are unreliable and will fail

- **User input**

  - Missing required fields
  - Invalid formats (email, date, JSON, etc.)
  - Out-of-range values (negative age, future birth date)
  - Malicious input (SQL injection, XSS attempts)
  - **WHY**: Users will enter anything, accidentally or maliciously

- **Resource limits**

  - Memory exhaustion (large file uploads, unbounded loops)
  - Timeout exceeded (long-running operations)
  - Rate limits hit (API throttling)
  - **WHY**: Resources are finite

- **Race conditions and timing**
  - Resource deleted between check and use
  - Concurrent modifications
  - Stale data
  - **WHY**: Distributed systems are eventually consistent

### 2. Design Error Handling Strategy

For each failure point, decide the strategy:

**A. Validate and reject early (Fail Fast)**

```javascript
// Good: Validate at the boundary
function createUser(email, age) {
  if (!email || !email.includes("@")) {
    throw new ValidationError("Valid email required");
  }
  if (age < 0 || age > 150) {
    throw new ValidationError("Age must be between 0 and 150");
  }
  // ... rest of logic
}
```

**WHY**: Catch bad input before it corrupts data or causes downstream errors

**B. Retry for transient failures**

```javascript
// Good: Retry network calls with exponential backoff
async function fetchWithRetry(url, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fetch(url);
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      await sleep(Math.pow(2, i) * 1000); // Exponential backoff
    }
  }
}
```

**WHY**: Transient failures (network blips, temporary overload) often succeed on retry

**C. Degrade gracefully for non-critical features**

```javascript
// Good: Continue operation with reduced functionality
async function getUserWithProfile(userId) {
  const user = await db.getUser(userId); // Critical - must succeed

  try {
    user.profileImage = await cdn.getImage(userId); // Non-critical
  } catch (error) {
    logger.warn("Failed to load profile image", { userId, error });
    user.profileImage = DEFAULT_AVATAR; // Fallback
  }

  return user;
}
```

**WHY**: Don't fail the entire operation for non-critical features

**D. Fail loudly for critical errors**

```javascript
// Good: Don't swallow errors you can't handle
async function processPayment(orderId, amount) {
  try {
    return await paymentService.charge(orderId, amount);
  } catch (error) {
    logger.error("Payment failed - IMMEDIATE ATTENTION NEEDED", {
      orderId,
      amount,
      error: error.stack,
    });
    throw new PaymentError(`Payment failed: ${error.message}`, { orderId });
  }
}
```

**WHY**: Critical failures need immediate attention

### 3. Implement Error Handling

**Add proper try-catch blocks**:

```javascript
// ❌ Bad: Catch everything and do nothing
try {
  doComplexStuff();
} catch (e) {
  console.log("error");
}

// ❌ Bad: Catch just to log and re-throw
try {
  doComplexStuff();
} catch (e) {
  console.error(e);
  throw e;
}

// ✅ Good: Catch specific errors and handle appropriately
try {
  await database.query(sql);
} catch (error) {
  if (error.code === "CONNECTION_TIMEOUT") {
    // Retry or queue for later
    await retryQueue.add({ sql, retryCount: 1 });
  } else if (error.code === "UNIQUE_VIOLATION") {
    // User-facing error
    throw new ValidationError("Email already exists");
  } else {
    // Unexpected error - let it bubble with context
    throw new DatabaseError("Query failed", { sql, originalError: error });
  }
}
```

**Add input validation**:

```javascript
// ✅ Good: Validate early and explicitly
function updateUserEmail(userId, newEmail) {
  // Type validation
  if (typeof userId !== "string" || typeof newEmail !== "string") {
    throw new TypeError("userId and newEmail must be strings");
  }

  // Format validation
  if (!isValidEmail(newEmail)) {
    throw new ValidationError("Invalid email format");
  }

  // Business rule validation
  if (isBannedEmail(newEmail)) {
    throw new ValidationError("This email domain is not allowed");
  }

  return db.updateUser(userId, { email: newEmail });
}
```

**Add error context and logging**:

```javascript
// ✅ Good: Log with context for debugging
try {
  await processOrder(orderId);
} catch (error) {
  logger.error("Order processing failed", {
    orderId,
    userId,
    timestamp: new Date().toISOString(),
    error: {
      message: error.message,
      stack: error.stack,
      code: error.code,
    },
    context: {
      retryAttempt: retryCount,
      queueDepth: orderQueue.length,
    },
  });
  throw error;
}
```

### 4. Improve User Experience

**For APIs: Use proper status codes and error responses**:

```javascript
// ✅ Good: Structured error responses
app.post("/api/users", async (req, res) => {
  try {
    const user = await createUser(req.body);
    res.status(201).json(user);
  } catch (error) {
    if (error instanceof ValidationError) {
      res.status(400).json({
        error: "Validation failed",
        message: error.message,
        fields: error.fields, // Which fields failed validation
      });
    } else if (error instanceof ConflictError) {
      res.status(409).json({
        error: "Conflict",
        message: error.message,
      });
    } else {
      logger.error("Unexpected error creating user", { error });
      res.status(500).json({
        error: "Internal server error",
        message: "An unexpected error occurred. Please try again later.",
        requestId: req.id, // For support to trace
      });
    }
  }
});
```

**For UIs: Show helpful error messages**:

```javascript
// ✅ Good: User-friendly error UI
async function handleSubmit() {
  setLoading(true);
  setError(null);

  try {
    await saveProfile(formData);
    showSuccess("Profile updated successfully");
  } catch (error) {
    if (error.code === "NETWORK_ERROR") {
      setError(
        "Unable to connect. Please check your internet connection and try again."
      );
    } else if (error.code === "VALIDATION_ERROR") {
      setError(`Please fix the following: ${error.fields.join(", ")}`);
    } else {
      setError("Something went wrong. Please try again or contact support.");
    }
  } finally {
    setLoading(false);
  }
}
```

### 5. Add Circuit Breakers (for external services)

```javascript
// ✅ Good: Prevent cascading failures
class CircuitBreaker {
  constructor(maxFailures = 5, resetTimeout = 60000) {
    this.failureCount = 0;
    this.maxFailures = maxFailures;
    this.resetTimeout = resetTimeout;
    this.state = "CLOSED"; // CLOSED, OPEN, HALF_OPEN
  }

  async call(fn) {
    if (this.state === "OPEN") {
      throw new Error("Circuit breaker is OPEN - service unavailable");
    }

    try {
      const result = await fn();
      this.onSuccess();
      return result;
    } catch (error) {
      this.onFailure();
      throw error;
    }
  }

  onSuccess() {
    this.failureCount = 0;
    this.state = "CLOSED";
  }

  onFailure() {
    this.failureCount++;
    if (this.failureCount >= this.maxFailures) {
      this.state = "OPEN";
      setTimeout(() => (this.state = "HALF_OPEN"), this.resetTimeout);
    }
  }
}
```

## Anti-Patterns to Avoid

❌ **Empty catch blocks** (swallowing errors)

```javascript
try {
  await doWork();
} catch (e) {
  // Silent failure - impossible to debug
}
```

❌ **Catching without handling**

```javascript
try {
  await doWork();
} catch (e) {
  console.error(e); // Just logging isn't handling
  throw e;
}
```

❌ **Vague error messages**

```javascript
throw new Error("Something went wrong"); // Useless for debugging
```

❌ **Exposing sensitive info in errors**

```javascript
throw new Error(`Query failed: ${sqlQuery}`); // Might leak data
```

❌ **Using errors for control flow**

```javascript
try {
  user = await getUser(id);
} catch (e) {
  user = null; // Use optional chaining or explicit null checks instead
}
```

## Verification Checklist

- [ ] Identified all external dependencies and their failure modes
- [ ] Identified all user inputs and validated them
- [ ] Decided appropriate strategy for each failure point (retry, degrade, fail)
- [ ] Added try-catch only where you can handle errors meaningfully
- [ ] Error messages are actionable and helpful
- [ ] Logging includes enough context to debug issues
- [ ] Errors don't expose sensitive information
- [ ] Critical errors fail loudly, non-critical degrade gracefully
- [ ] APIs return appropriate status codes
- [ ] UI shows user-friendly error messages
- [ ] Implemented retries for transient failures
- [ ] Added circuit breakers for unstable external services
- [ ] Testing error paths (not just happy paths)

## Testing Error Handling

Don't forget to test that errors are handled correctly:

```javascript
// Test validation errors
test("rejects invalid email", async () => {
  await expect(createUser("", "invalid-email")).rejects.toThrow(
    ValidationError
  );
});

// Test retry logic
test("retries on network failure", async () => {
  mockFetch
    .mockRejectedValueOnce(new Error("Network error"))
    .mockRejectedValueOnce(new Error("Network error"))
    .mockResolvedValueOnce({ ok: true });

  const result = await fetchWithRetry("/api/data");
  expect(mockFetch).toHaveBeenCalledTimes(3);
  expect(result.ok).toBe(true);
});

// Test graceful degradation
test("continues without profile image if CDN fails", async () => {
  mockCDN.getImage.mockRejectedValue(new Error("CDN down"));

  const user = await getUserWithProfile("user-123");
  expect(user.profileImage).toBe(DEFAULT_AVATAR);
  expect(user.email).toBeDefined(); // Main data still loaded
});
```

## Remember

**Good error handling**:

- Makes debugging easier (clear messages, good logging)
- Keeps users informed (actionable error messages)
- Prevents cascading failures (circuit breakers, retries)
- Fails fast for programming errors (in development)
- Degrades gracefully for runtime errors (in production)

**Bad error handling**:

- Swallows errors silently
- Shows technical stack traces to users
- Adds try-catch everywhere "just in case"
- Fails the entire operation for non-critical errors
- Makes debugging harder (vague messages, no context)
