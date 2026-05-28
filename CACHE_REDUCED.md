# Cache Time Reduced for Faster Updates

## Issue
Role changes were taking too long to reflect (up to 5 minutes).

## Solution
Reduced cache time from **5 minutes to 30 seconds** across all pages.

## Changes Made

### Files Updated:
- ✅ admin.html
- ✅ home.html  
- ✅ dashboard.html
- ✅ status.html
- ✅ profile.html

### Before:
```javascript
const CACHE_MAX_AGE = 5 * 60 * 1000; // 5 minutes
```

### After:
```javascript
const CACHE_MAX_AGE = 30 * 1000; // 30 seconds
```

## Result
Now when you change a user's role:
1. Admin changes role → saves immediately
2. User refreshes page (or waits 30 seconds)
3. Cache expires and checks for role updates
4. New role is detected and cache is cleared
5. User sees new role and permissions

**Maximum wait time: 30 seconds** (down from 5 minutes)

## How It Works
1. **Cache expires after 30 seconds** instead of 5 minutes
2. **On next page load**, system checks if role was updated
3. **If role changed**, cache is cleared immediately
4. **Fresh data loaded** with new role

---

**Status**: ✅ COMPLETE - Role changes now reflect within 30 seconds maximum
