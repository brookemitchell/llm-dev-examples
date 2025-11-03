# Generate PR Description

## Purpose

Create a clear, comprehensive PR description that helps reviewers understand what changed, why it changed, and how to verify it works. Good PR descriptions speed up reviews and serve as documentation.

**Context**: PR descriptions are read by reviewers (who need context), future developers (debugging issues), and sometimes users (release notes). A good description answers: What changed? Why? How can I verify it works? What should I watch for?

## Critical Principles

1. **Start with WHY before WHAT**

   - Explain the problem or motivation first
   - Then describe the solution
   - **WHY**: Context helps reviewers understand if the approach is correct

2. **Make it easy to review**

   - Highlight what to focus on
   - Call out tricky parts or trade-offs
   - Link to relevant files/functions
   - **WHY**: Reduces cognitive load for reviewers

3. **Include testing evidence**

   - Show tests pass (screenshot or output)
   - Demonstrate the feature works (GIF/video)
   - Document manual testing steps
   - **WHY**: Proves the change works

4. **Be honest about limitations**
   - Call out known issues or TODOs
   - Mention alternative approaches considered
   - Note deployment risks
   - **WHY**: Transparency builds trust and prevents surprises

## Steps

### 1. Analyze the Changes

**Before writing, review what changed**:

```bash
# See all changed files
git diff main...HEAD --name-only

# See full diff
git diff main...HEAD

# See commit history
git log main..HEAD --oneline
```

**Understand**:

- What files changed?
- What's the core change?
- Why was this needed?
- Are there any breaking changes?

### 2. Write the PR Description

Use this template (adapt as needed):

```markdown
## 🎯 What & Why

### Problem

[Describe the problem this PR solves. Link to issue/ticket if applicable.]

Example:

> Users were receiving duplicate email notifications when multiple people commented on their post within a short time window. This caused complaints and increased server load.
>
> Fixes #1234

### Solution

[Explain your approach at a high level. Why this solution?]

Example:

> Implemented a notification batching system that:
>
> - Collects notifications in a 5-minute window
> - Deduplicates by notification type and target
> - Sends a single email with all updates
>
> Chose batching over debouncing because users want timely notifications (not delayed indefinitely).

## 📝 Changes Made

### Core Changes

- `src/notifications/batcher.ts`: New notification batching service
  - Buffers notifications for 5 minutes
  - Deduplicates by user_id + notification_type
  - Sends batch via existing EmailService
- `src/notifications/notifier.ts`: Modified to use batcher instead of direct send
- `src/notifications/types.ts`: Added `NotificationBatch` type

### Database Changes

- Added `notification_queue` table (migration: `2024-01-15-add-notification-queue.sql`)
- Added index on `(user_id, notification_type, created_at)` for deduplication queries

### Configuration

- New env var: `NOTIFICATION_BATCH_WINDOW_MS` (default: 300000 = 5 minutes)

### Breaking Changes

⚠️ **None** - This is backward compatible. Old code paths still work.

## ✅ Testing

### Automated Tests

- ✅ Unit tests for NotificationBatcher (100% coverage)
- ✅ Integration test: Multiple notifications -> Single batch email
- ✅ Integration test: Notifications outside window -> Separate emails
- ✅ E2E test: User receives batched email for multiple comments

**Test output**:
```

PASS src/notifications/batcher.test.ts
NotificationBatcher
✓ batches notifications within window (145ms)
✓ sends separate emails for notifications outside window (89ms)
✓ deduplicates notifications by type (65ms)

Test Suites: 1 passed
Tests: 3 passed

```

### Manual Testing
1. Created test user with notifications enabled
2. Had 3 different users comment on the same post within 2 minutes
3. ✅ Verified single email received (not 3)
4. ✅ Email contained all 3 comments
5. Tested with notifications 10 minutes apart
6. ✅ Verified 2 separate emails received

**Screenshot**: [Attach screenshot of batched email]

### Performance Testing
- Tested with 1000 notifications per second
- ✅ Batching reduced emails sent by 85%
- ✅ Database load reduced (fewer individual queries)
- ⚠️ Memory usage increased ~50MB (acceptable for our scale)

## 🚀 Deployment Notes

### Prerequisites
- Run migration: `npm run migrate:up`
- Set env var if custom batch window desired

### Rollout Plan
1. Deploy to staging (verify batching works)
2. Monitor for 24 hours
3. Deploy to 10% of prod (canary)
4. Monitor email send rate and user complaints
5. Full rollout if metrics look good

### Rollback Plan
- If issues: Set `NOTIFICATION_BATCH_WINDOW_MS=0` (disables batching)
- Full rollback: Revert PR and run `npm run migrate:down`

### Monitoring
Watch these metrics:
- Email send rate (expect 60-80% reduction)
- Notification queue depth (should stay < 1000)
- User complaints about delayed notifications

## 🤔 Trade-offs & Alternatives Considered

### Why batching instead of debouncing?
- **Batching**: Fixed delay (5 min) = predictable timing
- **Debouncing**: Delay resets on each new event = could delay indefinitely
- Chose batching for predictability

### Why 5 minutes?
- Too short (1 min): Minimal deduplication benefit
- Too long (30 min): Users frustrated by delays
- 5 min balances timeliness and deduplication

### Why not use existing queue system (Kafka)?
- Would work, but adds infrastructure dependency
- Database queue is simpler for MVP
- Can migrate to Kafka later if needed

## 📋 Review Focus

Please pay special attention to:
1. **Batching logic** (`src/notifications/batcher.ts:45-78`): Does the deduplication logic cover all cases?
2. **Database migration** (`migrations/2024-01-15-add-notification-queue.sql`): Index strategy correct?
3. **Error handling** (`src/notifications/batcher.ts:112-125`): What happens if EmailService fails?

## 📌 Related Issues

- Fixes #1234: Duplicate email notifications
- Related to #1200: Performance improvement initiative
- Blocks #1250: Email notification settings (needs batching first)

## 🔮 Follow-up Work

Not included in this PR (future work):
- [ ] Add admin dashboard to monitor batch queue depth
- [ ] Allow users to customize batch window per notification type
- [ ] Migrate to Kafka if queue depth consistently > 10K
```

### 3. Adapt the Template

**For simple bug fixes**:

```markdown
## Bug Fix: [Brief description]

### Problem

[What was broken]

### Root Cause

[Why it was broken]

### Fix

[What changed to fix it]

### Testing

- ✅ Added test case reproducing the bug
- ✅ Verified bug no longer occurs
- ✅ All existing tests still pass
```

**For refactoring**:

```markdown
## Refactor: [What area]

### Motivation

[Why refactor was needed - technical debt, performance, readability]

### Changes

[What changed - no behavior changes]

### Verification

- ✅ All tests pass (no behavior change)
- ✅ Performance: [benchmarks showing no regression]
- ✅ Checked no unused exports/imports
```

**For documentation**:

```markdown
## Documentation: [What area]

### Motivation

[Why docs were needed/updated]

### Changes

- Updated README with [...]
- Added inline comments for [...]
- Created docs/guide-name.md for [...]

### Verification

- ✅ Links all work
- ✅ Code examples run without errors
- ✅ Reviewed by [person familiar with area]
```

## Best Practices

### ✅ Do This

**Be specific**:

- ✅ "Added retry logic with exponential backoff (max 3 retries, 2s initial delay)"
- ❌ "Improved error handling"

**Show, don't just tell**:

- Include screenshots for UI changes
- Include GIFs for interactions
- Include terminal output for CLI changes

**Link to code**:

- "See `PaymentService.processRefund()` for the core logic"
- "The tricky part is in `utils/date-parser.ts:45-60`"

**Call out risks**:

- "⚠️ This changes database schema - requires maintenance window"
- "⚠️ This increases memory usage by ~100MB per instance"

### ❌ Don't Do This

**Too vague**:

- ❌ "Fixed stuff"
- ❌ "Updated code"
- ❌ "Made improvements"

**Too technical (for simple changes)**:

- ❌ "Refactored AbstractFactoryBuilder to use strategy pattern..."
- (for a 5-line change)

**Missing context**:

- ❌ Just listing commits without explaining WHY

**Overpromising**:

- ❌ "This fixes all performance issues" (unless you're sure)

## Verification Checklist

- [ ] Read through git diff to understand all changes
- [ ] Title summarizes the change in < 72 chars
- [ ] Description explains WHY (problem/motivation)
- [ ] Description explains WHAT (solution approach)
- [ ] Listed all significant code changes
- [ ] Highlighted breaking changes (if any)
- [ ] Included testing evidence (output/screenshots)
- [ ] Documented manual testing steps
- [ ] Linked to related issues/tickets
- [ ] Called out deployment risks/requirements
- [ ] Noted follow-up work (if any)
- [ ] Guided reviewers to tricky areas
- [ ] Used proper markdown formatting
- [ ] Checked spelling and grammar

## Remember

**Good PR descriptions**:

- Save reviewers time
- Serve as documentation later
- Show you thought through the change
- Build trust with reviewers
- Speed up merge time

**Bad PR descriptions**:

- "Fixed bug" (no context)
- "See commits" (makes reviewer dig)
- "WIP" (then never updated)
- Novel-length (no one reads it)
- Missing testing info (how do I verify?)
