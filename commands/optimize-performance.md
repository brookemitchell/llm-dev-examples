# Optimize Performance

## Purpose

Identify and eliminate performance bottlenecks to make code faster. Focus on measurable improvements while maintaining readability and correctness.

**Context**: Performance optimization is about making the common case fast while keeping the code maintainable. Premature optimization wastes time, but ignoring real performance issues frustrates users.

## Instructions

Systematically analyze performance and apply optimizations where they matter most. Measure before and after to verify improvements.

### Step 1: Profile First (Don't Guess!)

**Never optimize without profiling**. Intuition about performance is often wrong.

**Use appropriate profiling tools**:
```bash
# JavaScript/Node.js
node --prof app.js
node --prof-process isolate-*.log

# Chrome DevTools Performance tab
# Network tab for API calls

# Python
python -m cProfile -o profile.stats script.py
python -m pstats profile.stats

# Rust
cargo flamegraph
```

**Identify the hot path**:
- What code runs most frequently?
- What code takes the most time?
- Where are the bottlenecks?

**WHY**: Optimize what matters, ignore what doesn't. 90% of time is spent in 10% of code.

### Step 2: Set Performance Goals

Define what "fast enough" means:
- **Latency targets**: API response < 200ms, page load < 2s
- **Throughput targets**: 1000 requests/second, 10MB/s file processing
- **Resource limits**: <100MB memory, <10% CPU usage

**Measure current performance**:
```typescript
console.time('operation')
// ... code to measure
console.timeEnd('operation')  // Prints: operation: 45.2ms
```

**WHY**: Without goals, optimization is endless

### Step 3: Fix Algorithmic Issues (Biggest Wins)

**Replace inefficient algorithms** with better ones:

❌ **O(n²) nested loops**:
```typescript
// Bad: O(n²)
function findDuplicates(arr) {
  const duplicates = []
  for (let i = 0; i < arr.length; i++) {
    for (let j = i + 1; j < arr.length; j++) {
      if (arr[i] === arr[j]) duplicates.push(arr[i])
    }
  }
  return duplicates
}
```

✅ **O(n) with hash set**:
```typescript
// Good: O(n)
function findDuplicates(arr) {
  const seen = new Set()
  const duplicates = new Set()
  for (const item of arr) {
    if (seen.has(item)) duplicates.add(item)
    seen.add(item)
  }
  return Array.from(duplicates)
}
```

**Use better data structures**:
- Array → Set/Map for lookups (O(1) vs O(n))
- Repeated sorting → Keep sorted, binary search
- Linear search → Index/hash table

**WHY**: Algorithm choice dominates performance. 100x speedups are possible.

### Step 4: Database Optimization

**Slow queries kill performance**. Optimize database access:

#### Add Indexes
```sql
-- Slow: Full table scan
SELECT * FROM users WHERE email = 'test@example.com';

-- Fast: Index lookup
CREATE INDEX idx_users_email ON users(email);
SELECT * FROM users WHERE email = 'test@example.com';
```

#### Reduce Round Trips
```typescript
// Bad: N+1 queries (1 + N separate queries)
const users = await User.findAll()
for (const user of users) {
  user.posts = await Post.findAll({ where: { userId: user.id } })
}

// Good: Single query with join
const users = await User.findAll({
  include: [{ model: Post }]
})
```

#### Paginate Large Results
```typescript
// Bad: Load everything
const allUsers = await User.findAll()  // Could be millions

// Good: Load in batches
const users = await User.findAll({
  limit: 50,
  offset: (page - 1) * 50
})
```

**WHY**: Database is often the bottleneck

### Step 5: Implement Caching

**Cache expensive operations** that don't change often:

#### Memoization (In-Memory Cache)
```typescript
const cache = new Map()

function expensiveCalculation(input) {
  if (cache.has(input)) {
    return cache.get(input)  // Instant!
  }
  
  const result = /* ... expensive work ... */
  cache.set(input, result)
  return result
}
```

#### Redis for Distributed Cache
```typescript
async function getCachedUser(id) {
  // Try cache first
  const cached = await redis.get(`user:${id}`)
  if (cached) return JSON.parse(cached)
  
  // Cache miss: fetch from database
  const user = await db.users.findById(id)
  
  // Store in cache (expire after 1 hour)
  await redis.setex(`user:${id}`, 3600, JSON.stringify(user))
  return user
}
```

#### HTTP Caching
```typescript
// Browser caches for 1 hour
res.setHeader('Cache-Control', 'public, max-age=3600')

// CDN caching for static assets
// /static/* → CloudFlare → User (instant)
```

**Cache invalidation**: When data changes, clear the cache
```typescript
async function updateUser(id, data) {
  await db.users.update(id, data)
  await redis.del(`user:${id}`)  // Clear cache
}
```

**WHY**: Cached data is 100-1000x faster than fresh data

### Step 6: Reduce Unnecessary Work

**Don't do work you don't need to do**:

#### Lazy Loading
```typescript
// Bad: Load everything upfront
const user = await db.users.findById(id, {
  include: ['posts', 'comments', 'likes', 'followers']
})

// Good: Load on demand
const user = await db.users.findById(id)
// Only load posts when actually needed
if (showPosts) {
  user.posts = await db.posts.findByUser(id)
}
```

#### Debouncing
```typescript
// Bad: Search on every keystroke
<input onChange={e => searchAPI(e.target.value)} />

// Good: Wait for user to stop typing
const debouncedSearch = debounce(searchAPI, 300)
<input onChange={e => debouncedSearch(e.target.value)} />
```

#### Virtual Scrolling
```tsx
// Bad: Render 10,000 items (slow!)
<div>
  {items.map(item => <Item key={item.id} {...item} />)}
</div>

// Good: Only render visible items
<VirtualList
  items={items}
  itemHeight={50}
  renderItem={item => <Item {...item} />}
/>
```

**WHY**: Fastest code is code that never runs

### Step 7: Parallelize Independent Work

**Use concurrency** for independent operations:

```typescript
// Bad: Sequential (3 seconds total)
const user = await fetchUser(id)     // 1s
const posts = await fetchPosts(id)   // 1s  
const comments = await fetchComments(id)  // 1s

// Good: Parallel (1 second total)
const [user, posts, comments] = await Promise.all([
  fetchUser(id),
  fetchPosts(id),
  fetchComments(id)
])
```

**WHY**: Waiting is wasted time

### Step 8: Avoid Memory Leaks

**Memory leaks slow down and crash apps**:

#### Cleanup Event Listeners
```typescript
// Bad: Memory leak
function Component() {
  useEffect(() => {
    window.addEventListener('resize', handleResize)
    // ❌ Never removed!
  }, [])
}

// Good: Cleanup
function Component() {
  useEffect(() => {
    window.addEventListener('resize', handleResize)
    return () => window.removeEventListener('resize', handleResize)
  }, [])
}
```

#### Clear Timers/Intervals
```typescript
// Bad: Timer keeps running
const timerId = setInterval(doWork, 1000)

// Good: Clear on unmount
useEffect(() => {
  const timerId = setInterval(doWork, 1000)
  return () => clearInterval(timerId)
}, [])
```

#### Avoid Holding References
```typescript
// Bad: Entire array kept in memory
const cache = new Map()
array.forEach(item => {
  cache.set(item.id, item)  // Holds references
})

// Good: Use WeakMap for automatic cleanup
const cache = new WeakMap()
```

**WHY**: Memory leaks compound over time

### Step 9: Measure Improvement

**Verify optimizations actually helped**:

```typescript
// Before optimization
console.time('processData')
processData(largeDataset)
console.timeEnd('processData')
// processData: 2847ms

// After optimization
console.time('processData')
processDataOptimized(largeDataset)
console.timeEnd('processData')
// processData: 124ms

// 23x faster! 🎉
```

Use real metrics:
- Response times (p50, p95, p99)
- Throughput (requests/sec)
- Resource usage (CPU, memory, network)
- User experience metrics (Time to Interactive, FCP, LCP)

**WHY**: Measure to prove optimization worked

## Anti-Patterns (What NOT to Do)

❌ **Micro-optimizations**: Shaving microseconds off non-critical code
❌ **Premature optimization**: Optimizing before knowing where the problems are
❌ **Sacrificing readability**: Clever code that no one can maintain
❌ **Ignoring big O**: Optimizing constants while using O(n²) algorithm

**Remember**: "Premature optimization is the root of all evil" - Donald Knuth

**Optimize when**:
- Users complain about speed
- Profiling shows clear bottleneck
- Resource costs are high
- Performance requirements aren't met

## Output Format

For each optimization, provide:

```markdown
## Optimization: [Name]

**Location**: [File and function]
**Bottleneck**: [What was slow]
**Root Cause**: [Why it was slow]

**Before** (measured):
- Time: 2.8s
- Memory: 150MB
- Algorithm: O(n²)

**Optimization Applied**:
```[language]
[optimized code with explanation]
```

**After** (measured):
- Time: 124ms (23x faster)
- Memory: 12MB (12x less)
- Algorithm: O(n)

**Trade-offs**: [Any downsides or complexity added]
```

## Verification Checklist

- [ ] Profiled code to find actual bottlenecks
- [ ] Set specific performance goals
- [ ] Measured performance before changes
- [ ] Applied optimizations with clear rationale
- [ ] Measured performance after changes
- [ ] Verified optimization achieved goals
- [ ] Checked no regressions introduced
- [ ] Code remains readable and maintainable
- [ ] Documented why optimizations were made
- [ ] Trade-offs explicitly noted
