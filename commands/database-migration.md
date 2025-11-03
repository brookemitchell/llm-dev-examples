# Database Migration

## Purpose

Create safe, reversible database migrations that can be deployed to production with confidence. Database migrations are risky—they can cause data loss, downtime, or performance issues. This command helps you avoid those pitfalls.

**Context**: Migrations are code that modifies production data. Unlike application code, you can't just roll back a bad migration—the data might be corrupted or gone. Always assume migrations will be run on a database with millions of rows and plan accordingly.

## Critical Principles

1. **Migrations must be reversible (always have a down/rollback)**

   - You WILL need to roll back at some point
   - Down migration should undo exactly what up migration does
   - Test rollback on staging before deploying
   - **WHY**: Deployment failures happen; you need an escape route

2. **Never destroy data in the same migration that changes schema**

   - Bad: Add column, migrate data, drop old column (all in one migration)
   - Good: Add column (migration 1), migrate data (migration 2), drop old column (migration 3)
   - **WHY**: If migration fails halfway, data is lost

3. **Plan for zero-downtime migrations**

   - Schema changes must be backward compatible with old code
   - Deploy in phases: add new column → deploy code using new column → remove old column
   - **WHY**: Users don't accept downtime anymore

4. **Test on production-sized data**
   - Migration that works on 100 rows might hang on 100M rows
   - Test on staging with production database clone
   - **WHY**: Performance problems appear at scale

## Steps

### 1. Understand the Change Needed

**Before writing any SQL, understand**:

- What schema change is needed? (add column, new table, change type, etc.)
- Does data need to be transformed?
- Are there existing foreign key constraints affected?
- What's the current data volume?
- **WHY**: Rushing into writing migrations causes mistakes

### 2. Analyze Risks and Impact

**Identify potential problems**:

- **Data loss risks**

  - Dropping columns with data
  - Changing column types (might truncate values)
  - Adding NOT NULL without default (fails if rows exist)
  - **WHY**: Data loss is permanent

- **Performance impact**

  - Adding indexes on large tables (can lock table for minutes)
  - Altering column types (requires full table rewrite)
  - Complex data migrations (slow on millions of rows)
  - **WHY**: Migrations shouldn't cause downtime

- **Breaking changes**
  - Removing columns still used by old code
  - Renaming tables before code is updated
  - Changing foreign key constraints
  - **WHY**: Old code must continue working during deployment

### 3. Design the Migration Strategy

**Choose the right approach based on risk**:

**A. Simple additive changes (low risk)**

```sql
-- Adding a nullable column is safe
ALTER TABLE users ADD COLUMN phone_verified BOOLEAN DEFAULT false;

-- Adding an index (use CONCURRENTLY in Postgres to avoid locks)
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);

-- Adding a new table is safe
CREATE TABLE user_sessions (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  expires_at TIMESTAMP NOT NULL
);
```

✅ Safe to deploy directly

**B. Multi-step migrations (medium risk)**

```sql
-- Renaming a column requires 3 migrations:

-- Migration 1: Add new column
ALTER TABLE users ADD COLUMN full_name TEXT;
UPDATE users SET full_name = name;

-- Deploy code that writes to both columns

-- Migration 2: Backfill any missing data
UPDATE users SET full_name = name WHERE full_name IS NULL;

-- Deploy code that only uses new column

-- Migration 3: Drop old column
ALTER TABLE users DROP COLUMN name;
```

⚠️ Requires coordinated deploys

**C. Data transformations (high risk)**

```sql
-- Transforming data requires careful planning

-- Migration UP: Transform data in batches
DO $$
DECLARE
  batch_size INT := 1000;
  offset_val INT := 0;
  rows_updated INT;
BEGIN
  LOOP
    UPDATE users
    SET email = LOWER(TRIM(email))
    WHERE id IN (
      SELECT id FROM users
      WHERE email != LOWER(TRIM(email))
      ORDER BY id
      LIMIT batch_size
      OFFSET offset_val
    );

    GET DIAGNOSTICS rows_updated = ROW_COUNT;
    offset_val := offset_val + batch_size;

    EXIT WHEN rows_updated = 0;

    -- Add delay to avoid overwhelming database
    PERFORM pg_sleep(0.1);
  END LOOP;
END $$;

-- Migration DOWN: Cannot reverse data transformation reliably
-- Store original values in a backup table before transforming
```

🔴 Test thoroughly on staging

### 4. Write the Migration

**Follow project conventions** (examples for common frameworks):

**Knex.js (Node.js)**:

```javascript
exports.up = async function (knex) {
  // Check if change already applied (idempotent)
  const hasColumn = await knex.schema.hasColumn("users", "email_verified");
  if (hasColumn) return;

  await knex.schema.table("users", (table) => {
    table.boolean("email_verified").defaultTo(false).notNullable();
    table.index("email_verified"); // Add index if needed for queries
  });

  // Backfill existing users
  await knex("users")
    .whereNull("email_verified")
    .update({ email_verified: false });
};

exports.down = async function (knex) {
  await knex.schema.table("users", (table) => {
    table.dropColumn("email_verified");
  });
};
```

**Alembic (Python/SQLAlchemy)**:

```python
def upgrade():
    # Add column
    op.add_column('users',
        sa.Column('email_verified', sa.Boolean(),
                  nullable=False, server_default='false'))

    # Add index
    op.create_index('ix_users_email_verified', 'users', ['email_verified'])

def downgrade():
    op.drop_index('ix_users_email_verified', table_name='users')
    op.drop_column('users', 'email_verified')
```

**Rails (Ruby)**:

```ruby
class AddEmailVerifiedToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :email_verified, :boolean, default: false, null: false
    add_index :users, :email_verified
  end
end
```

### 5. Handle Edge Cases and Errors

**Make migrations robust**:

```sql
-- Check if already applied (idempotent)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'users' AND column_name = 'email_verified'
  ) THEN
    ALTER TABLE users ADD COLUMN email_verified BOOLEAN DEFAULT false;
  END IF;
END $$;

-- Handle foreign key constraints
ALTER TABLE orders DROP CONSTRAINT IF EXISTS fk_orders_users;
ALTER TABLE orders ADD CONSTRAINT fk_orders_users
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

-- Add NOT NULL constraint safely (two-step)
-- Step 1: Add column as nullable with default
ALTER TABLE users ADD COLUMN email TEXT DEFAULT 'unknown@example.com';
UPDATE users SET email = 'unknown@example.com' WHERE email IS NULL;

-- Step 2: In next migration, make NOT NULL
ALTER TABLE users ALTER COLUMN email SET NOT NULL;
```

### 6. Test the Migration

**Never skip testing**:

```bash
# 1. Test on local with production-like data
# Create test data
./scripts/generate_test_data.sh 1000000 # 1M rows

# 2. Run migration
npm run migrate:up

# 3. Verify data
SELECT COUNT(*) FROM users WHERE email_verified IS NOT NULL;

# 4. Test rollback
npm run migrate:down

# 5. Verify rollback
SELECT COUNT(*) FROM users WHERE email_verified IS NULL;

# 6. Test on staging with production clone
ssh staging "npm run migrate:up"

# 7. Monitor performance
# Check migration time, lock duration, CPU/memory usage
```

## Zero-Downtime Migration Strategy

For production systems that can't afford downtime:

### Phase 1: Make schema backward compatible

```sql
-- Add new column (old code ignores it)
ALTER TABLE users ADD COLUMN new_email TEXT;
```

✅ Deploy this, old code continues working

### Phase 2: Deploy code that writes to both columns

```javascript
// New code writes to both
await db.users.update({
  email: newEmail,
  new_email: newEmail, // Also write to new column
});
```

✅ Deploy this, both columns stay in sync

### Phase 3: Backfill data

```sql
-- Copy data from old to new column
UPDATE users SET new_email = email WHERE new_email IS NULL;
```

✅ Run this migration, all data in new column

### Phase 4: Deploy code that only reads/writes new column

```javascript
// Code now uses new_email
const user = await db.users.findOne({
  where: { new_email: email },
});
```

✅ Deploy this, old column no longer used

### Phase 5: Drop old column

```sql
-- Safe to drop now
ALTER TABLE users DROP COLUMN email;
```

✅ Run this migration, cleanup complete

## Verification Checklist

- [ ] Understood the schema change and data transformation needed
- [ ] Identified all data loss and performance risks
- [ ] Designed migration strategy (single vs multi-step)
- [ ] Written both UP and DOWN migrations
- [ ] Made migrations idempotent (safe to run multiple times)
- [ ] Added proper error handling
- [ ] Handled constraints and indexes appropriately
- [ ] Tested on local database with realistic data volume
- [ ] Tested rollback works correctly
- [ ] Tested on staging with production database clone
- [ ] Measured migration time and performance impact
- [ ] Documented deployment steps and coordination needed
- [ ] Planned monitoring during deployment
- [ ] Created backup before running in production

## Common Pitfalls

❌ **Adding NOT NULL without default on existing table**

```sql
-- This will FAIL if table has rows
ALTER TABLE users ADD COLUMN email TEXT NOT NULL;
```

✅ **Add as nullable, backfill, then make NOT NULL**

```sql
ALTER TABLE users ADD COLUMN email TEXT;
UPDATE users SET email = 'unknown@example.com' WHERE email IS NULL;
ALTER TABLE users ALTER COLUMN email SET NOT NULL;
```

❌ **Changing column type without considering data**

```sql
-- This might truncate data
ALTER TABLE users ALTER COLUMN age TYPE SMALLINT;
```

✅ **Validate data first**

```sql
-- Check if safe
SELECT COUNT(*) FROM users WHERE age > 32767 OR age < -32768;
-- If count is 0, safe to proceed
```

❌ **Creating indexes without CONCURRENTLY (Postgres)**

```sql
-- This LOCKS the table during creation
CREATE INDEX idx_users_email ON users(email);
```

✅ **Use CONCURRENTLY to avoid locks**

```sql
-- This allows reads/writes during creation
CREATE INDEX CONCURRENTLY idx_users_email ON users(email);
```

## Remember

**Good migrations**:

- Are reversible and tested
- Handle edge cases gracefully
- Consider performance at scale
- Don't lose data
- Can be deployed with zero downtime

**Bad migrations**:

- Drop columns with data
- Lock tables for minutes
- Break old code
- Can't be rolled back
- Weren't tested on realistic data
