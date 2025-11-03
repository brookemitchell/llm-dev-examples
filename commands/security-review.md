# Security Review & Audit

## Purpose

Perform a comprehensive security review to identify and fix vulnerabilities. This command combines both quick security checks and deep security audits.

**Context**: Security issues can lead to data breaches, unauthorized access, and compliance violations. This review helps catch vulnerabilities before they reach production.

## Instructions

You are conducting a thorough security review of the codebase. Take your time to think through each security domain systematically. Use extended thinking to reason about potential attack vectors and edge cases.

### 1. Authentication & Authorization

- Verify authentication mechanisms are robust and follow industry standards
- Check authorization controls: are permissions properly enforced at every layer?
- Review session/token management: proper expiration, secure storage, rotation
- Password handling: bcrypt/argon2 usage, no plaintext storage, proper policies
- **WHY**: Broken authentication is the #1 OWASP vulnerability

### 2. Input Validation & Injection Prevention

- Identify SQL/NoSQL injection points: use parameterized queries everywhere
- XSS vulnerabilities: proper output encoding, CSP headers
- CSRF protection: tokens on state-changing operations
- Command injection: never pass user input to shell commands
- Path traversal: validate and sanitize file paths
- **WHY**: Injection attacks allow attackers to execute arbitrary code

### 3. Data Protection

- Sensitive data encrypted at rest (database, files) and in transit (TLS)
- No secrets in logs, error messages, or client-side code
- API responses: don't leak internal structure, IDs, or sensitive fields
- Secrets management: use vault/env vars, never hardcode
- **WHY**: Data breaches have massive legal and reputation costs

### 4. Dependency & Infrastructure Security

- Run dependency audit: `npm audit`, `pip-audit`, `cargo audit`
- Check for known CVEs in dependencies
- HTTPS everywhere: proper TLS config, certificate validation
- Security headers: CSP, HSTS, X-Frame-Options, etc.
- CORS: restrictive policies, no wildcard origins in production
- Environment variables: proper separation dev/staging/prod
- **WHY**: 80% of breaches involve vulnerable dependencies

### 5. Code-Level Security Patterns

- No `eval()` or dynamic code execution with user input
- Proper error handling: don't expose stack traces to users
- Rate limiting on sensitive endpoints
- File uploads: validate type, size, scan for malware
- Deserialization: never deserialize untrusted data
- **WHY**: These are common attack surfaces often overlooked

## Output Format

For each security issue found, provide:

1. **Severity**: Critical / High / Medium / Low
2. **Issue**: Clear description of the vulnerability
3. **Location**: File, line number, code snippet
4. **Attack Vector**: How could this be exploited?
5. **Fix**: Specific code changes with examples
6. **Prevention**: How to avoid this in the future

## Example Output

````markdown
### 🔴 Critical: SQL Injection in User Query

**Location**: `api/users.js:42`
**Code**:

```javascript
db.query(`SELECT * FROM users WHERE id = ${userId}`);
```
````

**Attack Vector**: Attacker can inject SQL by passing `userId=1 OR 1=1--` to dump all users

**Fix**:

```javascript
db.query("SELECT * FROM users WHERE id = $1", [userId]);
```

**Prevention**: Always use parameterized queries, never string interpolation for SQL

```

## Verification Checklist

After review:
- [ ] All Critical issues documented with fixes
- [ ] High/Medium issues identified
- [ ] Code examples provided for each fix
- [ ] Dependencies updated to patch known CVEs
- [ ] Security headers configured
- [ ] No hardcoded secrets found
- [ ] Input validation comprehensive
- [ ] Authentication/authorization solid

## Advanced Analysis

Use your extended thinking capability to:
- Consider the entire attack surface, not just individual vulnerabilities
- Think about how vulnerabilities could be chained together
- Evaluate defense-in-depth: what happens if one layer fails?
- Consider both technical and business impact of each vulnerability
```
