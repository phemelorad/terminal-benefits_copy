# Fix: Profile Page Loading Performance

## Issue #10 from improvements.txt

**Problem**: Profile page is loading slowly.

**Investigation Needed**: Identify bottlenecks in profile.html loading process.

---

## Potential Causes

### 1. Multiple Database Queries
- Loading user profile
- Loading user stats
- Loading recent activity
- Each query adds latency

### 2. Large Avatar Images
- Base64 encoded images in database
- No compression or optimization

### 3. No Caching
- Profile data fetched fresh every time
- Stats recalculated on each load

### 4. Sequential Loading
- Queries run one after another instead of parallel

---

## Performance Analysis

### Current Loading Sequence (profile.html)
```javascript
1. Check session (async)
2. Load user profile (async) - WAIT
3. Load stats (async) - WAIT  
4. Load recent activity (async) - WAIT
```

**Total Time**: Query1 + Query2 + Query3 + Network latency

### Optimized Loading Sequence
```javascript
1. Check session (async)
2. Load ALL data in parallel:
   - Promise.all([
       loadProfile(),
       loadStats(),
       loadActivity()
     ])
```

**Total Time**: Max(Query1, Query2, Query3) + Network latency

---

## Solutions

### Solution 1: Parallel Data Loading (Quick Win)
Replace sequential awaits with `Promise.all()`:

```javascript
// BEFORE (Sequential - SLOW)
await loadProfile(profileId, session.user.email);
await loadStats(profileId);
await loadRecentActivity(profileId);

// AFTER (Parallel - FAST)
await Promise.all([
  loadProfile(profileId, session.user.email),
  loadStats(profileId),
  loadRecentActivity(profileId)
]);
```

**Expected Improvement**: 50-70% faster loading

### Solution 2: Add Loading Skeleton
Show skeleton UI while data loads:

```html
<div class="profile-skeleton" id="profile-skeleton">
  <div class="skeleton-hero"></div>
  <div class="skeleton-cards"></div>
</div>
```

**Benefit**: Perceived performance improvement

### Solution 3: Cache Profile Data
Use sessionStorage to cache profile data:

```javascript
const cachedProfile = sessionStorage.getItem('profile_data');
if (cachedProfile && cacheAge < 2 * 60 * 1000) { // 2 minutes
  displayCachedProfile(JSON.parse(cachedProfile));
  // Refresh in background
  refreshProfile();
}
```

**Expected Improvement**: Instant load on repeat visits

### Solution 4: Optimize Avatar Loading
- Compress images before storing
- Use lazy loading for avatars
- Consider using Supabase Storage instead of base64

### Solution 5: Database Query Optimization
Create a combined RPC function:

```sql
CREATE OR REPLACE FUNCTION get_profile_dashboard(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'profile', (SELECT row_to_json(p) FROM user_profiles p WHERE id = p_user_id),
    'stats', (SELECT row_to_json(s) FROM get_user_entry_stats(p_user_id) s),
    'activity', (SELECT json_agg(a) FROM (
      SELECT * FROM audit_log 
      WHERE changed_by_name = (SELECT full_name FROM user_profiles WHERE id = p_user_id)
      ORDER BY changed_at DESC LIMIT 8
    ) a)
  ) INTO result;
  
  RETURN result;
END;
$$ LANGUAGE plpgsql;
```

**Expected Improvement**: Single round-trip instead of 3

---

## Implementation Plan

### Phase 1: Quick Wins (Immediate)
1. ✅ Implement parallel loading with Promise.all()
2. ✅ Add loading skeleton UI
3. ✅ Add performance logging

### Phase 2: Caching (Short-term)
1. Cache profile data in sessionStorage
2. Implement background refresh
3. Add cache invalidation on updates

### Phase 3: Optimization (Long-term)
1. Create combined RPC function
2. Optimize avatar storage
3. Add lazy loading for images

---

## Implementation

### Step 1: Update profile.html Init Function

```javascript
(async () => {
  const { data: { session } } = await db.auth.getSession();
  if (!session) { location.replace('index.html'); return; }
  currentUser = session.user;

  // Check if admin is viewing another user via ?uid=xxx
  const params = new URLSearchParams(window.location.search);
  const targetUid = params.get('uid');

  let profileId = currentUser.id;
  
  // ... existing cache and admin view logic ...

  // BEFORE (Sequential):
  // await loadProfile(profileId, session.user.email);
  // await loadStats(profileId);
  // await loadRecentActivity(profileId);

  // AFTER (Parallel - MUCH FASTER):
  const startTime = performance.now();
  
  await Promise.all([
    loadProfile(profileId, session.user.email),
    loadStats(profileId),
    loadRecentActivity(profileId)
  ]);
  
  const loadTime = performance.now() - startTime;
  console.log(`✅ Profile loaded in ${loadTime.toFixed(0)}ms`);
})();
```

### Step 2: Add Loading Skeleton CSS

```css
.profile-skeleton {
  animation: pulse 1.5s ease-in-out infinite;
}

.skeleton-hero {
  height: 150px;
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
  margin-bottom: 20px;
}

.skeleton-cards {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
}

.skeleton-card {
  height: 200px;
  background: linear-gradient(90deg, #f0f0f0 25%, #e0e0e0 50%, #f0f0f0 75%);
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite;
}

@keyframes shimmer {
  0% { background-position: -200% 0; }
  100% { background-position: 200% 0; }
}
```

---

## Testing

### Performance Benchmarks

**Before Optimization**:
- First load: ~1500-2000ms
- Cached load: ~1500-2000ms (no caching)

**After Optimization (Target)**:
- First load: ~500-800ms (parallel loading)
- Cached load: ~50-100ms (with caching)

### Test Scenarios

1. **Fresh Load** (no cache):
   - Clear sessionStorage
   - Navigate to profile.html
   - Measure time to interactive

2. **Cached Load**:
   - Load profile once
   - Navigate away
   - Return to profile
   - Should be instant

3. **Admin Viewing User**:
   - As admin, view another user's profile
   - Should load quickly

4. **Slow Network**:
   - Throttle network to 3G
   - Verify skeleton shows
   - Verify data loads correctly

---

## Files to Modify

1. ✅ **profile.html**: Update init function with Promise.all()
2. ✅ **profile.html**: Add loading skeleton HTML
3. ✅ **profile.html**: Add skeleton CSS
4. ⏳ **profile.html**: Add caching logic (Phase 2)
5. ⏳ **Database**: Create combined RPC function (Phase 3)

---

## Status

- [ ] Parallel loading implemented
- [ ] Loading skeleton added
- [ ] Performance logging added
- [ ] Caching implemented
- [ ] Tested and verified
- [ ] Documented in IMPLEMENTATION_LOG.md

---

**Next**: Implement parallel loading in profile.html
