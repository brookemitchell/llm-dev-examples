# Fix Compilation Errors

## Purpose

Systematically resolve all compilation errors to get the code building again. Compilation errors prevent deployment and often cascade, so fixing them is urgent.

**Context**: The compiler is your first line of defense. Compilation errors mean the code is broken at a fundamental level—types don't match, dependencies are missing, or syntax is invalid. Fix these before anything else.

## Instructions

Work through compilation errors systematically, starting with the root causes. Don't guess—investigate each error carefully.

### Step 1: Gather All Errors

Run the compiler and capture ALL errors:

```bash
# TypeScript/JavaScript
npx tsc --noEmit

# Rust
cargo build 2>&1 | tee errors.txt

# Python
mypy . --show-error-codes

# Go
go build ./...
```

**WHY**: Some errors mask others. See the full picture first.

### Step 2: Prioritize and Group

**Fix in this order**:

1. **Configuration errors** (tsconfig, package.json, Cargo.toml)
   - These cause widespread failures
   - Example: Wrong module resolution, missing path mappings

2. **Missing dependencies**
   - Import errors for external packages
   - Fix with: `npm install`, `pip install`, `cargo add`

3. **Syntax errors**
   - Malformed code that parser can't understand
   - Usually localized to specific files

4. **Type errors**
   - Type mismatches, missing properties, wrong signatures
   - Often cascade from earlier errors

**Group related errors**:
- Same root cause? Fix once, resolves many
- Same file? Fix together
- Dependency chain? Fix upstream first

**WHY**: Efficient fixing eliminates cascading errors

### Step 3: Investigate Each Error (Don't Guess!)

For each error:

1. **Read the error message carefully**
   ```
   src/api/users.ts:42:15 - error TS2345: Argument of type 'string' 
   is not assignable to parameter of type 'number'.
   ```
   - **File & line**: `users.ts:42:15`
   - **Error code**: `TS2345` (look this up if unclear)
   - **Problem**: Passing string where number expected

2. **Read the actual code** (don't speculate!)
   - Open the file
   - Look at the line mentioned
   - Read surrounding context

3. **Understand WHY it's failing**
   - What type does the compiler expect?
   - What type are we actually providing?
   - Where does this value come from?

**WHY**: Understanding prevents creating new errors while fixing old ones

### Step 4: Apply Fixes Correctly

Common error types and correct fixes:

#### Type Mismatches

```typescript
// Error: Type 'string | undefined' not assignable to 'string'
function greet(name: string) {
  console.log(`Hello, ${name}`)
}
greet(user.name)  // user.name might be undefined

// Fix Option 1: Guard against undefined
if (user.name) {
  greet(user.name)
}

// Fix Option 2: Provide default
greet(user.name ?? 'Guest')

// Fix Option 3: Change signature (if appropriate)
function greet(name: string | undefined) {
  console.log(`Hello, ${name ?? 'Guest'}`)
}
```

**WHY**: Handle the actual data reality, don't just cast away the problem

#### Missing Imports

```typescript
// Error: Cannot find name 'fetchUser'
const user = await fetchUser(id)

// Fix: Add import
import { fetchUser } from './api/users'
const user = await fetchUser(id)
```

**WHY**: Explicit imports make dependencies clear

#### Wrong Property Names

```typescript
// Error: Property 'userEmail' does not exist on type 'User'
console.log(user.userEmail)

// Investigate: What properties DOES User have?
// Maybe it's 'email', not 'userEmail'

// Fix: Use correct property name
console.log(user.email)
```

**WHY**: Typos are easy, but compiler won't guess

#### Undefined Variables

```typescript
// Error: Cannot find name 'config'
const apiUrl = config.apiUrl

// Investigate: Where should 'config' come from?
// - Is it imported? Add import
// - Is it a global? Add type declaration
// - Should it be a parameter? Add to function signature

// Fix: Add missing import
import { config } from './config'
const apiUrl = config.apiUrl
```

**WHY**: All variables must be declared somewhere

#### Missing Function Arguments

```typescript
// Error: Expected 2 arguments, but got 1
calculatePrice(product)

// Check the signature
function calculatePrice(product: Product, taxRate: number): number

// Fix: Provide all required arguments
calculatePrice(product, 0.08)
```

**WHY**: Functions require all parameters for a reason

### Step 5: Avoid Bad Fixes

❌ **Don't use `any` to silence errors**
```typescript
// Bad: Hides the real problem
const data: any = fetchData()

// Good: Fix the types properly
const data: UserData = fetchData()
```

❌ **Don't use `@ts-ignore` without understanding**
```typescript
// Bad: Ignoring error doesn't fix it
// @ts-ignore
const result = brokenFunction()

// Good: Fix the actual issue
const result = fixedFunction()
```

❌ **Don't cast when types actually don't match**
```typescript
// Bad: Lying to the compiler
const id = userId as number  // userId is actually string

// Good: Convert properly
const id = parseInt(userId, 10)
```

❌ **Don't change types to match incorrect usage**
```typescript
// Bad: Weakening types to match buggy code
function getUser(id: string | number) {  // was just 'number'
  // Now accepts strings due to buggy call sites
}

// Good: Fix the call sites to pass numbers
function getUser(id: number) {
  // Correct signature enforced
}
```

**WHY**: Bad fixes create technical debt and hide bugs

### Step 6: Verify the Fix

After each fix:
1. **Rerun the compiler**: Ensure error is gone
2. **Check for new errors**: Your fix might cause cascading changes
3. **Run tests**: Ensure behavior didn't break
4. **Review changes**: Make sure fix makes semantic sense

**WHY**: Compilation success ≠ correct code

## Output Format

For each error fixed, document:

```markdown
## Error 1: Type Mismatch in calculateTotal

**File**: `src/billing/invoice.ts:127`
**Error**: `Argument of type 'string' is not assignable to parameter of type 'number'`

**Root Cause**: `product.price` is a string (from API) but `calculateTotal` expects number

**Fix**:
```typescript
// Before
const total = calculateTotal(product.price)

// After
const total = calculateTotal(parseFloat(product.price))
```

**Verification**: ✅ Compiler passes, tests pass, behavior correct
```

## Special Cases

**When errors come from dependencies**:
- Check for type package: `@types/package-name`
- Update dependency if it has type fixes
- As last resort, declare types yourself

**When errors come from generated code**:
- Regenerate if possible
- Don't manually edit generated files
- Check generator configuration

**When errors seem impossible**:
- Clear build cache: `rm -rf node_modules .tsc-cache dist`
- Reinstall dependencies: `npm clean-install`
- Restart TypeScript server in IDE

**WHY**: Some errors aren't in your code

## Verification Checklist

- [ ] All compilation errors identified and listed
- [ ] Errors prioritized (config → dependencies → syntax → types)
- [ ] Each error investigated (code read, not guessed)
- [ ] Root causes identified
- [ ] Fixes applied correctly (no `any`, no `@ts-ignore` abuse)
- [ ] Compiler runs without errors
- [ ] Tests pass
- [ ] No new errors introduced
- [ ] Changes make semantic sense
