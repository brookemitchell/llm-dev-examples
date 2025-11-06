---
name: research
description: Deep dive into codebase architecture, implementation patterns, and improvement opportunities with structured analysis
arguments:
  - name: query
    description: What to research (feature, component, pattern, or specific question)
    required: true
  - name: scope
    description: Limit analysis to specific directory or file pattern
    required: false
  - name: depth
    description: Analysis depth (shallow, normal, deep, comprehensive)
    required: false
  - name: output
    description: Save report to file instead of displaying in chat
    required: false
  - name: format
    description: Output format (markdown, json, checklist)
    required: false
  - name: compare
    description: Compare current implementation with specified approach or standard
    required: false
  - name: focus
    description: Specific aspect to focus on (architecture, performance, security, testing, patterns, dependencies)
    required: false
---

# Research Command

## What this command does

The research command is your comprehensive tool for understanding, analyzing, and improving your codebase. It goes beyond basic code reading to provide structured insights into how systems work, why they're designed that way, and how they can be improved.

**Use it when you need to:**

- **Understand** how features, components, or patterns work
- **Discover** hidden issues in code quality, performance, or security
- **Map** dependencies, data flows, and system interactions
- **Compare** implementations against best practices or alternative approaches
- **Plan** refactorings with impact analysis and risk assessment
- **Document** complex systems with auto-generated architecture diagrams
- **Onboard** to unfamiliar codebases quickly and systematically

## Research Methodologies

### 1. Feature Analysis

Understand how a specific feature works from user action to data persistence.

**What it traces:**

- Entry points (API endpoints, CLI commands, event handlers)
- Control flow through middleware and handlers
- Data transformations and validation
- Database interactions and queries
- External service calls
- Error handling paths
- Edge cases and boundary conditions

**Example queries:**

```bash
/research how does form submission work?
/research trace the patient registration flow
/research map the authentication and authorization flow
```

### 2. Component Analysis

Deep dive into a specific package, module, or service.

**What it examines:**

- Public API and exported interfaces
- Internal implementation patterns
- Dependencies (incoming and outgoing)
- State management approach
- Error handling strategy
- Test coverage and quality
- Documentation completeness
- Coupling and cohesion metrics

**Example queries:**

```bash
/research analyze internal/forms package
/research review cmd/server component design
/research assess internal/middleware architecture
```

### 3. Pattern Analysis

Identify and evaluate implementation patterns across the codebase.

**What it identifies:**

- Consistent patterns (good practices being followed)
- Inconsistent patterns (areas of divergence)
- Anti-patterns (problematic implementations)
- Missing patterns (opportunities for standardization)
- Evolution of patterns over time

**Example queries:**

```bash
/research analyze error handling patterns
/research review dependency injection patterns
/research identify testing patterns and gaps
/research map database access patterns
```

### 4. Dependency Analysis

Map relationships between components and external dependencies.

**What it maps:**

- Import graphs and dependency trees
- Circular dependencies
- Tight coupling points
- Interface boundaries
- External library usage
- Version compatibility
- Upgrade impact analysis

**Example queries:**

```bash
/research map dependencies for internal/forms
/research find circular dependencies
/research analyze third-party library usage
/research assess impact of upgrading database driver
```

### 5. Performance Analysis

Identify bottlenecks and optimization opportunities.

**What it finds:**

- Algorithmic complexity issues (O(n²) loops, etc.)
- Database N+1 query problems
- Memory allocation hotspots
- Unnecessary data copying
- Missing caching opportunities
- Inefficient data structures
- Resource leak risks

**Example queries:**

```bash
/research find performance bottlenecks in form rendering
/research analyze database query efficiency
/research identify memory allocation issues
/research review caching strategy
```

### 6. Security Analysis

Discover security vulnerabilities and risks.

**What it checks:**

- Input validation and sanitization
- SQL injection vulnerabilities
- XSS and CSRF protection
- Authentication and authorization gaps
- Secret management
- Data exposure risks
- Dependency vulnerabilities

**Example queries:**

```bash
/research security review of API endpoints
/research check for SQL injection vulnerabilities
/research analyze authentication implementation
/research review access control patterns
```

### 7. Test Analysis

Assess test coverage and quality.

**What it evaluates:**

- Test coverage metrics (line, branch, edge cases)
- Test quality (assertions, edge cases, error paths)
- Missing test scenarios
- Test maintainability
- Test performance
- Integration vs unit test balance
- Mock usage patterns

**Example queries:**

```bash
/research assess test coverage for internal/forms
/research identify missing test scenarios
/research review test quality and patterns
/research analyze integration test strategy
```

### 8. Impact Analysis

Understand the consequences of proposed changes.

**What it determines:**

- Which components will be affected
- Breaking change risks
- Required updates across codebase
- Migration effort estimation
- Rollback strategy
- Testing requirements

**Example queries:**

```bash
/research impact of changing form validation API
/research what breaks if we refactor middleware?
/research assess risk of database schema change
/research plan migration from old auth system
```

## Depth Levels

### Shallow (Quick Overview)

- **Time:** 2-5 minutes
- **Scope:** High-level structure and obvious issues
- **Output:** Brief summary with key findings
- **Best for:** Initial exploration, sanity checks

### Normal (Standard Analysis)

- **Time:** 5-15 minutes
- **Scope:** Thorough analysis of main paths and common patterns
- **Output:** Detailed report with code examples
- **Best for:** Most research tasks, feature understanding

### Deep (Comprehensive Review)

- **Time:** 15-30 minutes
- **Scope:** Exhaustive analysis including edge cases and alternatives
- **Output:** Complete report with diagrams and comparisons
- **Best for:** Complex systems, major refactorings

### Comprehensive (Full Audit)

- **Time:** 30+ minutes
- **Scope:** Complete system analysis with all dependencies
- **Output:** Full documentation package with action plan
- **Best for:** Onboarding, architectural decisions, major migrations

## Output Structure

All research reports follow this structured format:

```markdown
# Research Report: <Topic>

**Date:** YYYY-MM-DD
**Scope:** <files/packages analyzed>
**Depth:** <analysis level>

## Executive Summary

3-5 sentence overview: What was researched, key findings, critical issues, primary recommendation

## Current Implementation

### Architecture Overview

- High-level system design
- Component relationships (with diagram if complex)
- Key design decisions

### Data Flow

- Request/response path
- Data transformations
- State changes
- External interactions

### Code Organization

- Package structure
- File layout
- Key types and interfaces
- Entry points

### Implementation Details

- Core algorithms and logic
- Important patterns used
- State management approach
- Error handling strategy

## Analysis

### Strengths

- What's working well
- Good patterns being followed
- Well-designed aspects

### Weaknesses

- Issues found (prioritized by severity)
- Technical debt
- Code smells
- Anti-patterns

### Specific Issues

Detailed list with:

- Location (file:line)
- Problem description
- Impact (high/medium/low)
- Example code
- Recommended fix

### Metrics

- Complexity scores
- Coupling/cohesion measures
- Test coverage
- Performance characteristics

## Improvement Opportunities

### High Priority

Critical issues requiring immediate attention

### Medium Priority

Important improvements for next iteration

### Low Priority

Nice-to-haves and polish

For each opportunity:

- Clear description
- Current vs proposed approach (with code)
- Benefits
- Estimated effort
- Risks

## Alternative Approaches

### Option 1: <Name>

- Description
- Pros/cons
- Tradeoffs
- Example implementation

### Option 2: <Name>

- Description
- Pros/cons
- Tradeoffs
- Example implementation

### Comparison Matrix

Side-by-side comparison of all options

## Recommended Solution

### Chosen Approach

Why this option is best for this codebase

### Implementation Plan

1. Phase 1 - Preparation
2. Phase 2 - Core changes
3. Phase 3 - Migration/cleanup
4. Phase 4 - Validation

### Code Examples

Concrete examples of the recommended changes

### Testing Strategy

How to validate the changes

### Rollback Plan

How to revert if issues arise

## Dependencies & Impact

### Affected Components

- List of packages/files that need changes
- Impact level for each

### Breaking Changes

- What will break
- Migration path

### Risk Assessment

- High/medium/low risks
- Mitigation strategies

## Next Steps

### Immediate Actions

[ ] Specific, actionable tasks in priority order

### Follow-up Research

[ ] Additional research needed before implementing

### Success Criteria

How to measure if improvements worked

## References

- Related files and documentation
- External resources
- Similar patterns in codebase
```

## Advanced Features

### Focus Areas

Narrow research to specific aspects:

```bash
/research internal/forms --focus architecture
/research form validation --focus performance
/research API handlers --focus security
/research internal/db --focus testing
/research middleware package --focus patterns
/research entire codebase --focus dependencies
```

### Comparison Mode

Compare against standards or alternatives:

```bash
/research error handling --compare "Go best practices"
/research architecture --compare "clean architecture"
/research auth implementation --compare "OAuth 2.0 spec"
/research current testing --compare "testing pyramid pattern"
```

### Incremental Research

Build on previous research sessions:

```bash
/research middleware --depth shallow
# Review findings, then go deeper
/research middleware authentication --depth deep
# Focus on specific issue found
/research middleware auth token validation --depth comprehensive
```

### Multi-Scope Research

Research across multiple related areas:

```bash
/research form rendering and validation flow
/research database access patterns in handlers and services
/research error handling in API and middleware layers
```

## Common Research Patterns

### 1. Feature Onboarding

Understanding a new feature quickly:

```bash
# Step 1: High-level overview
/research patient appointment feature --depth shallow

# Step 2: Detailed implementation
/research appointment scheduling logic --depth normal

# Step 3: Edge cases and issues
/research appointment validation and error handling --depth deep
```

### 2. Pre-Refactor Analysis

Before making major changes:

```bash
# Step 1: Understand current state
/research internal/forms architecture --depth normal

# Step 2: Identify issues
/research internal/forms --focus performance,security,testing

# Step 3: Plan changes
/research internal/forms refactor --compare "better alternative" --depth deep

# Step 4: Impact assessment
/research impact of forms API changes
```

### 3. Bug Investigation

Deep dive into a specific issue:

```bash
# Step 1: Understand the feature
/research form submission flow --depth normal

# Step 2: Analyze specific problem area
/research form validation error handling --depth deep --focus security

# Step 3: Find all related issues
/research validation patterns across codebase --depth normal
```

### 4. Performance Optimization

Finding and fixing bottlenecks:

```bash
# Step 1: Broad scan
/research entire codebase --focus performance --depth shallow

# Step 2: Drill into problem areas
/research database queries in handlers --focus performance --depth deep

# Step 3: Validate solutions
/research query optimization strategies --compare "best practices"
```

### 5. Security Audit

Comprehensive security review:

```bash
# Step 1: Authentication/authorization
/research auth system --focus security --depth deep

# Step 2: Data handling
/research user input handling --focus security --depth normal

# Step 3: Dependencies
/research third-party libraries --focus security

# Step 4: Full audit
/research entire API surface --focus security --depth comprehensive
```

### 6. Test Coverage Gap Analysis

Improving test quality:

```bash
# Step 1: Current coverage
/research test coverage --depth normal

# Step 2: Identify gaps
/research missing test scenarios in internal/forms

# Step 3: Pattern analysis
/research testing patterns --compare "testing best practices"
```

### 7. Architectural Review

Understanding system design:

```bash
# Step 1: Component map
/research codebase architecture --depth normal --output architecture-map.md

# Step 2: Dependency analysis
/research component dependencies --depth deep

# Step 3: Design patterns
/research architectural patterns --compare "Go best practices"
```

## Output Options

### Save to File

```bash
/research forms package --output research/forms-analysis.md
/research architecture --output docs/architecture-review.md --depth comprehensive
```

### Format Selection

```bash
/research API layer --format markdown     # Detailed report (default)
/research security issues --format json   # Machine-readable for tools
/research refactor plan --format checklist # Action-oriented task list
```

### Checklist Format

Perfect for action planning:

```markdown
## High Priority Issues

- [ ] Fix SQL injection in form handler (internal/handlers/form.go:45)
- [ ] Add authentication check to admin endpoint (internal/api/admin.go:12)
- [ ] Implement input validation (internal/forms/validator.go:89)

## Medium Priority Issues

- [ ] Improve error messages (multiple files)
- [ ] Add missing tests for edge cases (internal/forms/form_test.go)
- [ ] Refactor duplicate validation logic (internal/forms/\*.go)

## Low Priority Issues

- [ ] Add documentation for public API (internal/forms/form.go)
- [ ] Consider caching for form templates (internal/forms/renderer.go:34)
```

## Integration with Other Commands

### Research → Code Review

```bash
# Research identifies issues
/research internal/middleware --focus security
# Output suggests specific files need review
/code-review --target main
```

### Research → Style Review

```bash
# Research finds inconsistent patterns
/research error handling patterns
# Style review ensures new code follows standards
/style-review --target main
```

### Research → Implementation

```bash
# Research with output generates implementation plan
/research improve form validation --depth deep --format checklist --output validation-plan.md
# Follow checklist to implement improvements
```

## Tips and Best Practices

### Research Strategy

1. **Start Broad, Then Narrow**

   - Begin with shallow depth to map the territory
   - Drill deeper into interesting or problematic areas
   - Use focused research for specific issues

2. **Be Specific in Queries**

   - ✅ "analyze authentication middleware token validation"
   - ❌ "look at auth stuff"

3. **Use Focus Areas Effectively**

   - Combine focus areas: `--focus "performance,security"`
   - Single focus for deep dives: `--focus architecture`

4. **Save Important Research**

   - Use `--output` for reports you'll reference later
   - Organize in `research/` or `docs/` directory
   - Include timestamp in filename

5. **Iterate Based on Findings**

   - First pass reveals structure
   - Second pass targets issues
   - Third pass validates solutions

6. **Compare When Planning Changes**
   - Use `--compare` before major refactors
   - Compare against language best practices
   - Compare with proven design patterns

### Query Patterns

**Feature Understanding:**

```bash
/research how does <feature> work?
/research explain <component> implementation
/research trace <action> from start to finish
```

**Issue Finding:**

```bash
/research find <type> issues in <scope>
/research check for <problem> in <component>
/research identify <pattern> anti-patterns
```

**Planning Changes:**

```bash
/research impact of <change>
/research plan <refactoring>
/research assess <migration> feasibility
```

**Quality Assessment:**

```bash
/research review <component> quality
/research analyze <area> test coverage
/research evaluate <system> maintainability
```

### When to Use Each Depth

- **Shallow:** Daily exploration, quick checks, unfamiliar codebase tour
- **Normal:** Standard feature understanding, regular code review prep, pattern identification
- **Deep:** Pre-refactor analysis, bug investigation, security review, complex feature planning
- **Comprehensive:** Architectural decisions, major migrations, full system audits, team onboarding docs

### Avoiding Common Pitfalls

1. **Don't Research Without Purpose**

   - Have a specific question or goal
   - "I want to understand X so I can Y"

2. **Don't Go Too Deep Too Fast**

   - Start shallow, identify interesting areas
   - Deep dives are expensive - use them wisely

3. **Don't Ignore Context**

   - Consider project goals and constraints
   - Technical perfection isn't always practical

4. **Don't Research in Isolation**

   - Share findings with team
   - Use output files for documentation
   - Convert findings to issues/tasks

5. **Don't Forget to Validate**
   - Research generates hypotheses
   - Test assumptions before implementing changes
   - Measure impact after improvements

## Examples Library

### Example 1: Understanding a Complex Feature

```bash
/research appointment scheduling system --depth normal --output research/appointments.md
```

**Use case:** New team member needs to understand how appointments work
**Output:** Complete feature documentation with diagrams and data flows

### Example 2: Pre-Refactor Safety Check

```bash
/research impact of changing form validation API --depth deep --format checklist
```

**Use case:** Planning to refactor validation, need to know what breaks
**Output:** Checklist of all affected code and required changes

### Example 3: Security Audit

```bash
/research API endpoints --focus security --depth comprehensive --output security-audit.md
```

**Use case:** Quarterly security review of public API
**Output:** Full security assessment with prioritized issues

### Example 4: Performance Investigation

```bash
/research slow dashboard loading --focus performance --depth deep
```

**Use case:** Users reporting slow dashboard, need to find bottleneck
**Output:** Performance analysis with specific optimization recommendations

### Example 5: Pattern Standardization

```bash
/research error handling patterns --compare "Go best practices" --depth normal
```

**Use case:** Want consistent error handling across codebase
**Output:** Gap analysis and migration plan to standard pattern

### Example 6: Test Gap Analysis

```bash
/research internal/forms test coverage --focus testing --depth normal --format checklist
```

**Use case:** Improving test coverage before release
**Output:** Checklist of missing test scenarios

### Example 7: Dependency Upgrade Planning

```bash
/research impact of upgrading postgres driver to v2 --depth deep --output postgres-upgrade.md
```

**Use case:** Want to upgrade major dependency safely
**Output:** Complete impact assessment and migration guide

### Example 8: Code Quality Review

```bash
/research internal/handlers code quality --depth normal
```

**Use case:** Regular code quality check
**Output:** Issues found with prioritized improvements

### Example 9: Architecture Documentation

```bash
/research entire system architecture --depth comprehensive --output docs/architecture.md
```

**Use case:** Creating onboarding documentation
**Output:** Complete architectural overview with diagrams

### Example 10: Quick Issue Scan

```bash
/research recently changed files --focus security,performance --depth shallow
```

**Use case:** Quick check after code review before merge
**Output:** Fast scan for obvious issues in changed code
