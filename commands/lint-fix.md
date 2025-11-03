# Lint and Fix Code

## Purpose

Run linters, identify issues, and apply fixes to ensure code meets project standards. This command handles both automated fixes and manual corrections for issues that require human judgment.

**Context**: Clean, consistent code is easier to maintain, review, and debug. Linting catches bugs early and enforces team standards, reducing technical debt.

## Instructions

Execute the project's linting tools and systematically fix all issues. Be thorough but minimal—only change what the linter flags, don't refactor beyond that scope.

### 1. Execute Linters

Run the project's standard linting tools with autofix enabled:

```bash
# Try these common commands (use what's configured in package.json/pyproject.toml):
npm run lint:fix
# or
npx eslint --fix .
# or
black . && flake8
# or
cargo clippy --fix
```

**WHY**: Autofix handles 80% of issues instantly (formatting, imports, simple style)

### 2. Analyze Remaining Issues

After autofix, capture errors/warnings that need manual attention:

- Parse linter output for unfixed issues
- Group by severity: errors (must fix) vs warnings (should fix)
- Identify patterns (repeated issue = systemic problem)

**WHY**: Manual fixes require understanding context and intent

### 3. Apply Manual Fixes

For each remaining issue, use your reasoning to:

- **Understand the rule**: Why does this rule exist?
- **Fix minimally**: Change only what's needed
- **Preserve intent**: Don't alter functionality
- **Stay idiomatic**: Match surrounding code style

Common manual fixes:

- **Unused variables**: Remove if truly unused, or prefix with `_` if intentionally unused
- **Complexity warnings**: Simplify logic or extract functions
- **Type issues**: Add proper type annotations
- **Best practices**: Apply team conventions

**WHY**: These require judgment that autofix can't provide

### 4. Handle Edge Cases

Some linter rules may conflict with project needs:

- **Too strict**: Add inline suppression with comment explaining why
- **False positive**: Same as above, document the exception
- **Configuration issue**: Note for team discussion, don't auto-suppress

Example suppression:

```typescript
// eslint-disable-next-line @typescript-eslint/no-explicit-any
// Reason: Third-party library types are incomplete
const data: any = externalLibrary.getData();
```

**WHY**: Blind suppression hides real issues; documented exceptions are transparent

## Output Format

After fixing, provide:

1. **Summary**: Total issues found, fixed, remaining
2. **Autofix changes**: What was automatically corrected
3. **Manual changes**: What you fixed and why
4. **Suppressions**: Any rules suppressed with justification
5. **Recommendations**: Patterns to address systematically

Example:

```markdown
## Lint Results

**Total issues**: 24
**Auto-fixed**: 18 (formatting, imports, spacing)
**Manually fixed**: 5
**Suppressed**: 1 (documented)

### Manual Fixes Applied

1. **Removed unused import** (`utils.ts:3`)
   - `import { deprecated } from './old'` was never used
2. **Simplified complex function** (`logic.ts:45-60`)
   - Extracted validation into `validateInput()` to reduce cyclomatic complexity
3. **Added type annotation** (`api.ts:12`)
   - `const response` → `const response: ApiResponse` for type safety

### Suppressed Rules

1. **`no-explicit-any` at `adapter.ts:5`**
   - Reason: Third-party library has incomplete types, documented in ADR-042
```

## Special Instructions

- **Never commit with linting errors** (errors block, warnings can pass if documented)
- **Don't change behavior** - this is styling only
- **Match existing patterns** - be consistent with surrounding code
- **Run tests after** - ensure no regressions from changes

## Verification Checklist

- [ ] Linter executed with latest config
- [ ] Autofix results applied and reviewed
- [ ] All errors fixed (no exceptions)
- [ ] Warnings addressed or suppressed with reasons
- [ ] No new issues introduced
- [ ] Code still compiles and tests pass
- [ ] Changes are minimal and focused
