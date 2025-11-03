# Add Documentation

## Purpose

Create clear, useful documentation that helps developers understand and use code correctly. Good documentation reduces onboarding time, prevents misuse, and answers questions before they're asked.

**Context**: Documentation is NOT about describing what the code does (the code already does that). It's about explaining WHY it exists, WHEN to use it, HOW to use it correctly, and WHAT to watch out for. Write for the developer who will use this 6 months from now (probably you).

## Critical Principles

1. **Start with WHY before WHAT**

   - Bad: "This function validates user input"
   - Good: "We validate all user input here to prevent SQL injection and XSS attacks. This is the single point of validation for all API endpoints."
   - **WHY**: Understanding purpose helps developers make better decisions

2. **Show, don't just tell**

   - Include working code examples
   - Show common use cases
   - Demonstrate error handling
   - **WHY**: Examples are worth a thousand words

3. **Document the gotchas**

   - What are the edge cases?
   - What mistakes do people make?
   - What needs to happen before/after?
   - **WHY**: Preventive documentation saves debugging time

4. **Keep it current**
   - Update docs when code changes
   - Remove outdated information
   - Don't say "recently refactored" (says when)
   - **WHY**: Wrong documentation is worse than no documentation

## Steps

### 1. Read and Understand the Code First

⚠️ **CRITICAL: Never document code you haven't read completely**

- Read the full implementation
- Understand the context and dependencies
- Note any non-obvious design decisions
- **WHY**: You can't document what you don't understand

### 2. Write the Overview (The WHY)

**Purpose**: Why does this exist?

```markdown
## User Authentication Service

This service handles all user authentication and session management for the application.
We centralize authentication here to ensure consistent security policies across all
entry points (web, mobile API, admin panel) and to make it easier to add new auth
methods (OAuth, SSO) in the future.

**Security Note**: All passwords are hashed with bcrypt (cost factor 12) before storage.
Never log or transmit plain-text passwords.
```

**WHY this matters**: Helps developers understand when to use it and when not to

### 3. Document the API (The WHAT and HOW)

**For each public function/class/endpoint**:

````typescript
/**
 * Authenticates a user with email and password.
 *
 * @param email - User's email address (must be lowercase and validated)
 * @param password - Plain-text password (will be hashed for comparison)
 * @param options - Optional settings
 * @param options.rememberMe - If true, session expires in 30 days instead of 24 hours
 * @param options.ipAddress - Client IP for security logging
 *
 * @returns Authentication token and user profile
 *
 * @throws {ValidationError} If email/password format is invalid
 * @throws {AuthenticationError} If credentials are incorrect (after rate limiting)
 * @throws {AccountLockedError} If account is locked due to failed attempts
 *
 * @example
 * ```typescript
 * try {
 *   const { token, user } = await authenticate(
 *     'user@example.com',
 *     'password123',
 *     { rememberMe: true, ipAddress: req.ip }
 *   )
 *   res.cookie('auth_token', token, { httpOnly: true, secure: true })
 * } catch (error) {
 *   if (error instanceof AuthenticationError) {
 *     return res.status(401).json({ error: 'Invalid credentials' })
 *   }
 *   throw error
 * }
 * ```
 *
 * @remarks
 * - Implements rate limiting: 5 attempts per 15 minutes per IP
 * - Accounts lock after 10 failed attempts (requires admin unlock)
 * - All auth attempts are logged to security audit log
 *
 * @see {@link validatePassword} for password requirements
 * @see {@link unlockAccount} for unlocking locked accounts
 */
async function authenticate(
  email: string,
  password: string,
  options?: AuthOptions
): Promise<AuthResult>;
````

**WHY this level of detail**: Developers can use it correctly without reading the implementation

### 4. Document Important Design Decisions

**Architecture/Implementation Notes**:

```markdown
## Design Decisions

### Why we use JWT instead of sessions

We chose JWT tokens over server-side sessions because:

- Enables horizontal scaling without sticky sessions
- Mobile clients can store tokens easily
- Reduces database load (no session lookups)

Trade-offs:

- Can't instantly revoke tokens (they're valid until expiry)
- Tokens can grow large with many claims
- Solution: Keep tokens short-lived (24h) and use refresh tokens

### Why password reset uses email-only flow

We don't ask security questions or allow SMS reset because:

- Email is the most secure channel we can rely on
- Security questions are often guessable
- SMS can be intercepted (SIM swapping attacks)

Reference: OWASP Authentication Cheat Sheet
```

**WHY this matters**: Helps future developers understand context for changes

### 5. Provide Practical Examples

**Show common use cases**:

```markdown
## Common Use Cases

### Basic Login Flow

\`\`\`typescript
// 1. Validate input
const { email, password } = req.body
if (!email || !password) {
return res.status(400).json({ error: 'Email and password required' })
}

// 2. Authenticate
try {
const { token, user } = await authenticate(email, password, {
rememberMe: req.body.rememberMe,
ipAddress: req.ip
})

// 3. Set secure cookie
res.cookie('auth_token', token, {
httpOnly: true,
secure: process.env.NODE_ENV === 'production',
sameSite: 'strict',
maxAge: user.rememberMe ? 30 _ 24 _ 60 _ 60 _ 1000 : 24 _ 60 _ 60 \* 1000
})

// 4. Return user data
res.json({ user: sanitizeUser(user) })
} catch (error) {
handleAuthError(error, res)
}
\`\`\`

### Protected Route Middleware

\`\`\`typescript
app.get('/api/profile', requireAuth, async (req, res) => {
// req.user is populated by requireAuth middleware
const profile = await getUserProfile(req.user.id)
res.json(profile)
})
\`\`\`

### OAuth Integration

\`\`\`typescript
// Google OAuth callback
app.get('/auth/google/callback', async (req, res) => {
const { code } = req.query
const googleUser = await exchangeCodeForUser(code)

// Link or create account
const user = await findOrCreateOAuthUser({
provider: 'google',
providerId: googleUser.id,
email: googleUser.email,
name: googleUser.name
})

const token = createToken(user)
res.cookie('auth_token', token, { httpOnly: true, secure: true })
res.redirect('/dashboard')
})
\`\`\`
```

### 6. Document Common Mistakes and Gotchas

````markdown
## Common Pitfalls

### ❌ Don't check authentication in individual handlers

```typescript
// BAD: Duplicated auth checks
app.get("/api/profile", (req, res) => {
  const token = req.cookies.auth_token;
  if (!token) return res.status(401).json({ error: "Unauthorized" });
  // ... verify token, fetch user, etc
});
```
````

### ✅ Use middleware for consistent auth

```typescript
// GOOD: Centralized auth
app.get("/api/profile", requireAuth, (req, res) => {
  // req.user is already verified
});
```

### ❌ Don't store passwords in plain text (obviously)

```typescript
// NEVER DO THIS
await db.users.create({ email, password });
```

### ✅ Always hash passwords

```typescript
// CORRECT
const hashedPassword = await bcrypt.hash(password, 12);
await db.users.create({ email, password: hashedPassword });
```

### ⚠️ Remember to rate-limit authentication endpoints

```typescript
// Authentication is a common attack vector
app.use(
  "/auth",
  rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 5, // 5 requests per window
  })
);
```

### ⚠️ Token expiration vs refresh tokens

- Short-lived access tokens (15-60 min): Used for API calls
- Long-lived refresh tokens (days/weeks): Used to get new access tokens
- Never use long-lived access tokens (security risk if leaked)

```

## Output Format

Documentation should be placed in the appropriate location:

1. **Inline code comments**: For function/class/method documentation (JSDoc, docstrings, etc.)
2. **README.md**: For project-level or module-level overview
3. **docs/ folder**: For detailed guides, architecture docs, API references

## Verification Checklist

- [ ] Read and understood the code completely
- [ ] Explained WHY it exists (purpose and context)
- [ ] Documented WHAT it does (functionality)
- [ ] Documented HOW to use it (with examples)
- [ ] Listed all parameters, return values, and exceptions
- [ ] Included practical, working code examples
- [ ] Documented common pitfalls and gotchas
- [ ] Explained important design decisions
- [ ] Documented dependencies and prerequisites
- [ ] No temporal language ("recently changed", "new feature")
- [ ] No obvious information (don't say "this function returns X" if the name is "getX")
- [ ] Checked that examples actually work (run them!)

## Remember

**Good documentation**:
- Answers "why" and "when" (not just "what")
- Shows working examples
- Warns about gotchas
- Is kept up to date
- Helps you ship faster

**Bad documentation**:
- Describes what the code obviously does
- Is out of sync with code
- Has no examples
- Is overly verbose
- Wastes developer time
```
