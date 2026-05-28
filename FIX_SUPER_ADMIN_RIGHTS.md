# Fix: Super Admin Rights Not Updating

## Issue #9 from improvements.txt

**Problem**: When super admin changes a user's role (e.g., from admin to officer), the change is saved in the database but the user still sees their old role on their end.

**Root Cause**: User role is cached in `sessionStorage` for performance. When an admin changes another user's role, that user's browser cache isn't cleared, so they continue to see and operate with their old role until they log out and back in.

---

## Solution

### Approach 1: Force Cache Refresh (Recommended)
Add a `role_updated_at` timestamp field and check it on each page load to invalidate stale cache.

### Approach 2: Real-time Notification
Use Supabase real-time subscriptions to notify users when their role changes.

### Approach 3: Shorter Cache TTL
Reduce cache max age from 5 minutes to 1 minute for role-sensitive operations.

---

## Implementation: Approach 1 (Cache Invalidation)

### Step 1: Add Database Field
```sql
ALTER TABLE user_profiles 
ADD COLUMN role_updated_at TIMESTAMPTZ DEFAULT NOW();

-- Create trigger to update timestamp when role changes
CREATE OR REPLACE FUNCTION update_role_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.role IS DISTINCT FROM OLD.role THEN
    NEW.role_updated_at = NOW();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER role_update_trigger
BEFORE UPDATE ON user_profiles
FOR EACH ROW
EXECUTE FUNCTION update_role_timestamp();
```

### Step 2: Update Admin Role Save Function
In `admin.html`, update the `saveRole()` function to set the timestamp:

```javascript
async function saveRole(userId) {
  const sel = document.getElementById('rs-'+userId);
  const btn = document.getElementById('rsb-'+userId);
  const newRole = sel.value;
  
  // ... existing validation code ...
  
  btn.textContent = '…'; btn.disabled = true;

  // Update role AND timestamp
  const { error } = await db.from('user_profiles')
    .update({ 
      role: newRole,
      role_updated_at: new Date().toISOString()
    })
    .eq('id', userId);

  btn.textContent = 'Save'; btn.disabled = false;
  if (error) { showToast('✗ Failed: '+error.message, true, 'ERR_ADMIN_001'); return; }

  const u = users.find(x=>x.id===userId);
  if (u) u.role = newRole;
  sel.classList.remove('changed');
  btn.classList.remove('show');
  document.getElementById('s-admins').textContent = users.filter(u=>u.role==='admin').length;
  showToast(`✓ Role updated to "${newRole}" - user will see changes on next page load`);
  renderUsers();
}
```

### Step 3: Update Cache Validation Logic
In ALL pages (home.html, dashboard.html, status.html, admin.html, profile.html), update the cache check:

```javascript
// Current code:
const cachedRole = sessionStorage.getItem('user_role');
const cacheTimestamp = sessionStorage.getItem('user_cache_time');
const cacheAge = cacheTimestamp ? Date.now() - parseInt(cacheTimestamp) : Infinity;
const CACHE_MAX_AGE = 5 * 60 * 1000; // 5 minutes

// NEW: Also check role_updated_at
const cachedRoleTimestamp = sessionStorage.getItem('user_role_timestamp');

// Fetch from database to check if role was updated
const { data: roleCheck } = await db.from('user_profiles')
  .select('role, role_updated_at')
  .eq('id', currentUser.id)
  .single();

// Invalidate cache if role was updated after cache was created
const roleUpdatedAt = roleCheck?.role_updated_at ? new Date(roleCheck.role_updated_at).getTime() : 0;
const cacheCreatedAt = cacheTimestamp ? parseInt(cacheTimestamp) : 0;

if (roleUpdatedAt > cacheCreatedAt) {
  console.log('⚠️ Role was updated - clearing cache');
  sessionStorage.clear();
  useCache = false;
}
```

### Step 4: Store role_updated_at in Cache
When caching user data, also store the role timestamp:

```javascript
sessionStorage.setItem('user_role', role);
sessionStorage.setItem('user_role_timestamp', roleCheck.role_updated_at || new Date().toISOString());
sessionStorage.setItem('user_cache_time', Date.now().toString());
```

---

## Alternative: Simpler Solution (Quick Fix)

### Reduce Cache TTL for Role-Sensitive Checks
Change cache max age from 5 minutes to 30 seconds:

```javascript
const CACHE_MAX_AGE = 30 * 1000; // 30 seconds instead of 5 minutes
```

This ensures users see role changes within 30 seconds without requiring database schema changes.

---

## Testing

1. **As Super Admin**:
   - Change a user's role from admin to officer
   - Verify toast message confirms the change

2. **As Affected User** (in different browser/incognito):
   - Stay logged in
   - Wait 30 seconds (or refresh page)
   - Verify role badge updates in header
   - Verify permissions change (e.g., can't access admin panel)

3. **Verify Database**:
   ```sql
   SELECT id, email, role, role_updated_at 
   FROM user_profiles 
   WHERE email = 'test@example.com';
   ```

---

## Files to Modify

1. ✅ **Database**: Add `role_updated_at` field and trigger
2. ✅ **admin.html**: Update `saveRole()` function
3. ✅ **home.html**: Update cache validation logic
4. ✅ **dashboard.html**: Update cache validation logic
5. ✅ **status.html**: Update cache validation logic
6. ✅ **profile.html**: Update cache validation logic

---

## Status

- [ ] Database schema updated
- [ ] admin.html updated
- [ ] Cache validation updated in all pages
- [ ] Tested with role changes
- [ ] Documented in IMPLEMENTATION_LOG.md

---

**Next**: Implement the fix starting with database changes.
