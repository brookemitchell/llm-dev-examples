# Refactor Code

## Purpose

Improve code quality, readability, and maintainability without changing external behavior. This is about making the code better for humans while preserving all functionality.

**Context**: Code is read 10x more than it's written. Refactoring reduces cognitive load, making future changes faster and safer. It's an investment in long-term velocity.

## CRITICAL Rules

Before you start, understand these constraints:

1. **NEVER rewrite from scratch without permission**
   - Refactoring = incremental improvement
   - Rewriting = starting over (much riskier)
   - If you want to rewrite, STOP and ask permission

2. **Behavior must be identical**
   - All tests must still pass
   - No changes to inputs/outputs
   - No new features sneaking in

3. **Make smallest reasonable changes**
   - One improvement at a time when possible
   - Match existing code style
   - Don't change unrelated code

**WHY**: Small, focused refactorings are low-risk and easy to review

## Instructions

Work through these refactoring categories systematically. Use extended thinking to ensure each change truly improves the code.

### 1. Readability & Naming

**Make the code tell its own story**:

- **Names reveal intent**: `getUserDataFromApi()` not `getData()`
- **Names are searchable**: `MAX_RETRY_COUNT` not `5`
- **Names match domain**: Use terms from the business/product
- **No abbreviations**: `customerAddress` not `custAddr` (unless universal like `id`, `url`)
- **Boolean names**: `isActive`, `hasPermission`, `canDelete` (yes/no questions)

Example:
```typescript
// Before
function process(d: any) {
  const r = d.map(x => x.val * 2)
  return r
}

// After
function doubleProductPrices(products: Product[]): number[] {
  return products.map(product => product.price * 2)
}
```

**WHY**: Clear names eliminate the need for comments and reduce mental translation

### 2. Eliminate Duplication

**DRY (Don't Repeat Yourself)**, but don't over-abstract:

- Extract repeated code blocks into functions
- Create shared utilities for common patterns
- Use loops/maps instead of copy-paste logic
- BUT: Don't abstract until you have 3+ instances (Rule of Three)

Example:
```typescript
// Before: Duplication
const activeUsers = users.filter(u => u.status === 'active' && u.verified)
const activeAdmins = admins.filter(a => a.status === 'active' && a.verified)

// After: Extracted
const isActiveAndVerified = (user) => user.status === 'active' && user.verified
const activeUsers = users.filter(isActiveAndVerified)
const activeAdmins = admins.filter(isActiveAndVerified)
```

**WHY**: Duplication = 2x the bugs when logic changes

### 3. Simplify Complex Logic

**Reduce cognitive load**:

- **Extract conditional logic**: `if (hasPermission(user))` not `if (user.role === 'admin' || user.permissions.includes('write'))`
- **Guard clauses**: Early returns instead of deep nesting
- **One level of abstraction per function**: High-level steps, not mixing concerns
- **Reduce cyclomatic complexity**: Aim for <10 branches per function

Example:
```typescript
// Before: Nested
function processOrder(order) {
  if (order) {
    if (order.isPaid) {
      if (order.items.length > 0) {
        // process
      }
    }
  }
}

// After: Guard clauses
function processOrder(order) {
  if (!order) return
  if (!order.isPaid) return
  if (order.items.length === 0) return
  
  // process (at the same indentation level as validation)
}
```

**WHY**: Flat code is easier to follow than deeply nested code

### 4. Improve Structure

**Organize code by what it does**:

- **Extract functions**: Each function does one thing
- **Extract classes/modules**: Group related functions
- **Dependency injection**: Pass dependencies instead of hard-coding them
- **Separate concerns**: Keep I/O, business logic, and presentation separate

SOLID Principles (in plain language):
- **S**ingle Responsibility: One reason to change
- **O**pen/Closed: Easy to extend, hard to break
- **L**iskov Substitution: Subtypes work like their parent types
- **I**nterface Segregation: Small, focused interfaces
- **D**ependency Inversion: Depend on abstractions, not concrete implementations

**WHY**: Well-structured code guides you where to make changes

### 5. Enhance Type Safety

**Let the compiler catch bugs**:

- Add type annotations where missing
- Replace `any` with specific types
- Use union types: `type Status = 'pending' | 'active' | 'closed'`
- Use `unknown` instead of `any` when type is truly unknown
- Make impossible states unrepresentable

Example:
```typescript
// Before
function fetchUser(id): any {
  // ...
}

// After
interface User {
  id: string
  name: string
  email: string
}

function fetchUser(id: string): Promise<User | null> {
  // ...
}
```

**WHY**: Types are documentation that the compiler enforces

### 6. Improve Error Handling

**Make errors explicit and actionable**:

- Use specific error types, not generic `Error`
- Include context in error messages
- Don't swallow errors (empty catch blocks)
- Fail fast: validate inputs early
- Use Result types for expected failures

Example:
```typescript
// Before
function parseConfig(data) {
  try {
    return JSON.parse(data)
  } catch {
    return {}
  }
}

// After
class ConfigParseError extends Error {
  constructor(message: string, public readonly cause: Error) {
    super(message)
  }
}

function parseConfig(data: string): Config {
  try {
    return JSON.parse(data)
  } catch (error) {
    throw new ConfigParseError(
      'Failed to parse configuration file',
      error
    )
  }
}
```

**WHY**: Clear errors speed up debugging

## What NOT to Refactor

Sometimes "ugly" code is actually better:

- **Performance-critical code**: Sometimes less elegant is faster
- **Well-tested legacy code**: If it ain't broke and changing is risky
- **Temporary code**: Marked with TODO/FIXME for removal
- **External interface constraints**: Can't change APIs others depend on

**When in doubt, ask yourself**: "Does this change make future changes easier?" If no, skip it.

## Output Format

For each refactoring, explain:

```markdown
## Refactorings Applied

### 1. Extracted validation logic

**File**: `users.ts:45-60`

**Before**:
```typescript
[original code]
```

**After**:
```typescript
[refactored code]
```

**Improvement**: Reduced duplication, validation logic now reusable in 3 places

**Impact**: 
- Cyclomatic complexity: 15 → 8
- Lines of code: 45 → 30
- Duplicated blocks: 3 → 0

### 2. Renamed for clarity

[etc...]
```

## Verification Checklist

After refactoring:
- [ ] All existing tests still pass
- [ ] No changes to function inputs/outputs
- [ ] No new features added
- [ ] Code is more readable than before
- [ ] Duplication reduced
- [ ] Complexity metrics improved
- [ ] Type safety enhanced
- [ ] Changes focused and minimal
- [ ] Existing code style preserved
