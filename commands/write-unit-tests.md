# Write Unit Tests

## Purpose

Create comprehensive, maintainable unit tests that document behavior and catch regressions. Good tests are the best documentation of what code actually does.

**Context**: Tests enable confident refactoring, prevent bugs from returning, and serve as executable specifications. They're an investment that pays dividends every time you make changes.

## Instructions

Write tests that thoroughly cover the code's behavior while remaining maintainable. Focus on testing outcomes, not implementation details.

### 1. Understand What You're Testing

Before writing tests, read and understand the code:

- What is the public API (exported functions/classes)?
- What are the expected inputs and outputs?
- What edge cases exist?
- What error conditions should be handled?
- What are the dependencies?

**WHY**: You can't test what you don't understand

### 2. Follow TDD Principles (When Possible)

If code doesn't exist yet (ideal):

1. Write failing test for desired behavior
2. Write minimal code to make it pass
3. Refactor while keeping tests green
4. Repeat

If code already exists:

- Still write tests before modifying
- Tests document current behavior (even if flawed)

**WHY**: TDD catches bugs earlier and creates better designed code

### 3. Structure Tests Well

Use the **Arrange-Act-Assert** pattern:

```typescript
test("calculateDiscount applies percentage correctly", () => {
  // Arrange: Set up test data
  const price = 100;
  const discountPercent = 20;

  // Act: Execute the function
  const result = calculateDiscount(price, discountPercent);

  // Assert: Verify the outcome
  expect(result).toBe(80);
});
```

**Test naming**: Use descriptive names that explain the scenario

- Good: `test('throws error when price is negative')`
- Bad: `test('test1')`

**Test organization**: Group related tests

```typescript
describe("calculateDiscount", () => {
  describe("with valid inputs", () => {
    // happy path tests
  });

  describe("with invalid inputs", () => {
    // error case tests
  });
});
```

**WHY**: Well-structured tests are easier to read and maintain

### 4. Write Tests for These Scenarios

**Happy Path**: Normal, expected usage

```typescript
test("successfully creates user with valid data", () => {
  const user = createUser({ name: "Alice", email: "alice@example.com" });
  expect(user.name).toBe("Alice");
});
```

**Edge Cases**: Boundary conditions, empty inputs, maximum values

```typescript
test("handles empty array", () => {
  expect(sumArray([])).toBe(0);
});

test("handles single element", () => {
  expect(sumArray([5])).toBe(5);
});
```

**Error Conditions**: Invalid inputs, violated preconditions

```typescript
test("throws when email is invalid", () => {
  expect(() => createUser({ name: "Alice", email: "invalid" })).toThrow(
    "Invalid email format"
  );
});
```

**Integration Points**: How it interacts with dependencies

```typescript
test("calls API with correct parameters", async () => {
  const mockApi = jest.fn().mockResolvedValue({ id: 1 });
  await saveUser(mockApi, userData);
  expect(mockApi).toHaveBeenCalledWith("/users", userData);
});
```

**WHY**: Comprehensive scenarios catch bugs early

### 5. Handle Dependencies Correctly

**Mock external dependencies** (APIs, databases, file system):

```typescript
// Good: Mock the dependency
jest.mock("./api");
test("fetches user data", async () => {
  api.getUser.mockResolvedValue({ id: 1, name: "Alice" });
  const user = await fetchUserData(1);
  expect(user.name).toBe("Alice");
});
```

**Don't mock what you're testing**:

```typescript
// Bad: Mocking the function under test
const mockCalculate = jest.fn().mockReturnValue(100);
expect(mockCalculate(50, 50)).toBe(100); // This tests the mock, not the code!
```

**Use test doubles appropriately**:

- **Stub**: Returns pre-defined data
- **Mock**: Records how it was called
- **Spy**: Wraps real implementation to observe calls
- **Fake**: Working implementation (simpler than real thing)

**WHY**: Tests should be isolated and repeatable

### 6. Write Maintainable Tests

**Keep tests focused**: One concept per test

```typescript
// Bad: Testing multiple things
test("user creation", () => {
  const user = createUser(data);
  expect(user.name).toBe("Alice");
  expect(user.email).toBe("alice@example.com");
  expect(user.isActive).toBe(false);
  expect(validateUser(user)).toBe(true); // Different concern!
});

// Good: Separate tests
test("creates user with provided data", () => {
  const user = createUser(data);
  expect(user).toMatchObject({ name: "Alice", email: "alice@example.com" });
});

test("newly created users are inactive by default", () => {
  const user = createUser(data);
  expect(user.isActive).toBe(false);
});
```

**Make tests independent**: Each test should run in isolation

```typescript
// Bad: Tests depend on execution order
let user;
test("creates user", () => {
  user = createUser(data);
});
test("user has correct name", () => {
  expect(user.name).toBe("Alice"); // Breaks if first test doesn't run!
});

// Good: Each test is self-contained
test("creates user", () => {
  const user = createUser(data);
  expect(user).toBeDefined();
});
test("created user has correct name", () => {
  const user = createUser(data);
  expect(user.name).toBe("Alice");
});
```

**Use test helpers for setup**:

```typescript
// Extract common setup
function createTestUser(overrides = {}) {
  return createUser({
    name: "Test User",
    email: "test@example.com",
    ...overrides,
  });
}

test("user validation", () => {
  const user = createTestUser({ email: "invalid" });
  // ...
});
```

**WHY**: Maintainable tests don't become a burden

### 7. Avoid Common Testing Anti-Patterns

❌ **Testing implementation details**:

```typescript
// Bad: Test knows about internal structure
test("sets loading flag", () => {
  component._isLoading = true; // Testing internal state
  expect(component._isLoading).toBe(true);
});

// Good: Test observable behavior
test("shows loading spinner while fetching", () => {
  component.fetchData();
  expect(screen.getByRole("status")).toBeInTheDocument();
});
```

❌ **Tests that require too much setup**:

- If a test needs 50 lines of setup, the code is probably too coupled
- Extract setup into factories or use builder pattern

❌ **Flaky tests**:

- Avoid timing dependencies (use fake timers)
- Don't depend on external services
- Don't use random data without seeding

❌ **Testing the framework**:

```typescript
// Bad: Testing React itself
test("useState works", () => {
  const [count, setCount] = useState(0);
  setCount(1);
  expect(count).toBe(0); // This tests React, not your code!
});
```

**WHY**: Anti-patterns make tests brittle and expensive

## Output Format

Generate test file with:

```typescript
import { functionToTest } from "./module";
import { mockDependency } from "./mocks";

describe("ModuleName", () => {
  describe("functionToTest", () => {
    test("handles normal case correctly", () => {
      // Arrange
      const input = "test";

      // Act
      const result = functionToTest(input);

      // Assert
      expect(result).toBe("expected");
    });

    test("throws error for invalid input", () => {
      expect(() => functionToTest(null)).toThrow("Input cannot be null");
    });

    test("handles edge case: empty string", () => {
      const result = functionToTest("");
      expect(result).toBe("");
    });
  });
});
```

Include:

1. Proper imports and setup
2. Clear test descriptions
3. Arrange-Act-Assert structure
4. Both happy and sad paths
5. Edge cases
6. Mocked dependencies where needed

## Test Coverage Guidelines

Aim for these coverage levels:

- **Critical paths**: 100% (authentication, payment, data integrity)
- **Business logic**: 90%+ (core features, domain logic)
- **Utility functions**: 80%+ (helpers, formatters)
- **UI components**: 70%+ (user-facing functionality)
- **Glue code**: Lower priority (simple wiring between components)

**WHY**: Focus effort where bugs have highest impact

## Verification Checklist

- [ ] All public functions/methods tested
- [ ] Happy path covered
- [ ] Edge cases covered (empty, null, boundaries)
- [ ] Error conditions tested
- [ ] Dependencies mocked appropriately
- [ ] Tests are independent and can run in any order
- [ ] Tests are deterministic (no randomness or timing issues)
- [ ] Test names clearly describe what's being tested
- [ ] Tests follow Arrange-Act-Assert pattern
- [ ] No testing implementation details
- [ ] Tests run fast (< 1 second per test file)
- [ ] All tests pass consistently
