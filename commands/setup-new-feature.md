# Setup New Feature

## Purpose

Set up a new feature systematically with proper planning, architecture, and TDD approach. Start features the right way to avoid costly rework later.

**Context**: Rushing into implementation without planning leads to poorly designed features that are hard to test, maintain, and extend. Taking time upfront to clarify requirements and design architecture pays dividends throughout development. This command helps you start right.

## Critical Principles

1. **Understand the problem before solving it**

   - What user problem are we solving?
   - Why is this feature needed?
   - What's the success criteria?
   - **WHY**: Building the wrong thing wastes time

2. **Design before coding**

   - Think through data models and APIs
   - Consider edge cases and error handling
   - Plan for testing from the start
   - **WHY**: Design issues found early are cheap to fix

3. **Start with tests (TDD)**

   - Write failing tests first
   - Let tests drive the design
   - **WHY**: Tests written after are often incomplete

4. **Break features into small, deployable pieces**
   - Each piece should deliver some value
   - Each piece should be reviewable
   - **WHY**: Big features stall in review and deployment

## Steps

### 1. Clarify Requirements

**Before writing any code, understand what you're building**:

Ask these questions (or get answers from PM/design):

- **What**: What exactly is this feature supposed to do?
- **Who**: Who is the user? What's their context?
- **Why**: Why do they need this? What problem does it solve?
- **How**: How will they use it? What's the user journey?
- **Success**: How do we know if it works? What are the acceptance criteria?

**Document answers**:

```markdown
## Feature: Email Notification Preferences

### Problem

Users receive too many emails and want control over which notifications they receive.
Current state: All users get all notifications (10+ per day).
Desired state: Users choose which notification types to receive.

### Users

- Primary: End users who receive notifications
- Secondary: Support team (fewer complaints about emails)

### Success Criteria

- [ ] Users can see all notification types
- [ ] Users can toggle each notification type on/off
- [ ] Changes take effect immediately
- [ ] Defaults: All notifications enabled for new users
- [ ] Analytics: 60%+ of users customize within first week

### Out of Scope (V1)

- Notification frequency (daily digest vs real-time)
- Per-device preferences (mobile vs email)
- Notification preview/testing
```

**WHY**: Clear requirements prevent building the wrong thing

### 2. Design the Solution

**Plan architecture before coding**:

**A. Data Model**

```markdown
### Database Changes

- Add `notification_preferences` table
  - user_id (FK to users)
  - notification_type (enum: 'comment', 'mention', 'update', 'marketing')
  - enabled (boolean)
  - created_at, updated_at

### Migration Strategy

- Phase 1: Add table (backward compatible)
- Phase 2: Backfill defaults for existing users
- Phase 3: Update notification sending logic to check preferences
```

**B. API Design**

```typescript
// GET /api/users/:userId/notification-preferences
// Returns: { preferences: NotificationPreference[] }

// PATCH /api/users/:userId/notification-preferences
// Body: { notificationType: string, enabled: boolean }
// Returns: { updated: NotificationPreference }

type NotificationPreference = {
  notificationType: "comment" | "mention" | "update" | "marketing";
  enabled: boolean;
  updatedAt: string;
};
```

**C. UI Components**

```markdown
- NotificationPreferencesPage (container)
  - PreferenceToggleList (shows all notification types)
    - PreferenceToggle (individual toggle with description)
  - SaveIndicator (shows "Saved" on successful update)
```

**D. Testing Strategy**

```markdown
Unit Tests:

- Preference model validation
- API endpoint handlers
- Toggle component interactions

Integration Tests:

- Complete preference update flow
- Defaults for new users
- Notification filtering respects preferences

E2E Tests:

- User navigates to preferences page
- Toggles notifications on/off
- Verifies emails stop arriving
```

**WHY**: Design catches issues before they're expensive to fix

### 3. Create Feature Branch

```bash
# Use descriptive branch name
git checkout -b feature/notification-preferences

# Or if using ticket system
git checkout -b feature/PROJ-123-notification-preferences
```

### 4. Set Up Environment

**Install dependencies**:

```bash
# If feature needs new packages
npm install @package/needed-library
# or
pip install new-library

# Update documentation
echo "new-library==1.2.3" >> requirements.txt
```

**Update environment config**:

```bash
# If feature needs new env vars
echo "NOTIFICATION_SERVICE_URL=http://localhost:3001" >> .env.example
```

### 5. Implement with TDD

**Start with a failing test**:

```typescript
// ❌ Test fails (code doesn't exist yet)
describe("NotificationPreferences API", () => {
  it("returns default preferences for new user", async () => {
    const user = await createTestUser();

    const response = await request(app).get(
      `/api/users/${user.id}/notification-preferences`
    );

    expect(response.status).toBe(200);
    expect(response.body.preferences).toHaveLength(4);
    expect(response.body.preferences.every((p) => p.enabled)).toBe(true);
  });
});
```

**Implement minimal code to pass**:

```typescript
// ✅ Make test pass
app.get("/api/users/:userId/notification-preferences", async (req, res) => {
  const preferences = await db.notificationPreferences.findMany({
    where: { userId: req.params.userId },
  });

  res.json({ preferences });
});
```

**Refactor and repeat**:

```typescript
// Add next test
it("updates preference when toggled", async () => {
  // Arrange: User with default preferences
  const user = await createTestUser();

  // Act: Toggle comment notifications off
  const response = await request(app)
    .patch(`/api/users/${user.id}/notification-preferences`)
    .send({ notificationType: "comment", enabled: false });

  // Assert: Preference updated
  expect(response.status).toBe(200);
  expect(response.body.updated.notificationType).toBe("comment");
  expect(response.body.updated.enabled).toBe(false);
});

// Implement to make it pass...
```

**WHY**: TDD ensures every line of code is tested

### 6. Break Into Reviewable Pieces

**Don't create one massive PR**:

```markdown
PR 1: Database migration (add notification_preferences table)

- Reviewable in 5 min
- No behavior change
- Deploy: Safe (table exists but unused)

PR 2: Backend API endpoints

- GET preferences endpoint
- PATCH preferences endpoint
- Unit tests + integration tests
- Reviewable in 15 min
- Deploy: Safe (endpoints exist but UI not using yet)

PR 3: Frontend UI

- NotificationPreferencesPage
- Component tests + E2E tests
- Reviewable in 20 min
- Deploy: Feature complete! 🎉

PR 4 (optional): Analytics tracking

- Track preference changes
- Dashboard for insights
- Reviewable in 10 min
```

**WHY**: Small PRs get reviewed faster and deployed safer

## Verification Checklist

- [ ] Requirements clearly documented
- [ ] Success criteria defined (measurable)
- [ ] Out of scope items listed
- [ ] Data model designed
- [ ] API endpoints designed
- [ ] UI components planned
- [ ] Testing strategy defined
- [ ] Feature branch created with descriptive name
- [ ] Dependencies installed and documented
- [ ] Starting with tests (TDD approach)
- [ ] Feature broken into small, reviewable PRs
- [ ] Each piece delivers incremental value

## Remember

**Good feature setup**:

- Clarifies requirements first
- Designs before coding
- Starts with tests (TDD)
- Breaks into small pieces
- Documents decisions

**Bad feature setup**:

- Jumps straight to coding
- Figures it out as you go
- Tests written after (if at all)
- One giant PR
- No documentation
