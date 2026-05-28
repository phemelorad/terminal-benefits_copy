# FIX: Super Admin Role Changes Reverting

## ISSUE
Super admin could change other users' roles in the UI, console showed "Database updated successfully", but changes would revert when page refreshed.

## ROOT CAUSE
Database Row Level Security (RLS) policies were blocking the UPDATE operation on the `user_profiles` table, even though the initial update appeared to succeed. The update was being rejected at the database level but the error wasn't being caught properly.

## SOLUTION IMPLEMENTED

### 1. Added Verification Step in admin.html
Updated `saveRole()` function to verify the role change actually persisted:
- After updating the database, immediately read back the role value
- Compare the returned role with the intended new role
- If they don't match, show error message directing user to run RLS fix script
- Reset dropdown to actual database value if verification fails

### 2. Enhanced Error Messages
- **ERR_ADMIN_003**: Update sent but could not verify
- **ERR_ADMIN_004**: Update failed - Database RLS policy blocking change

### 3. Console Logging
Added detailed logging to track:
- Database update success
- Verification query results
- Expected vs actual role values
- Whether verification succeeded or failed

## WHAT USER NEEDS TO DO

### STEP 1: Run the RLS Policy Fix Script
Execute `check_and_fix_rls_policies.sql` in Supabase SQL Editor:

```sql
-- This script will:
-- 1. Check current RLS policies on user_profiles table
-- 2. Drop restrictive policies that prevent role updates
-- 3. Create proper policy allowing admins/super_admins to update any user profile
-- 4. Verify the new policy was created
```

### STEP 2: Test Role Change
1. Go to Admin page
2. Try changing a user's role (e.g., admin → officer)
3. Click "Save"
4. Watch console logs for verification messages
5. If successful, you'll see: `[SaveRole] Verification successful - role persisted as: officer`
6. If failed, you'll see: `[SaveRole] VERIFICATION FAILED - Role reverted!`

### STEP 3: Refresh Page to Confirm
After successful role change:
1. Refresh the admin page
2. Verify the role change persisted
3. User should see new role instantly on their next login (cache = 0)

## EXPECTED BEHAVIOR AFTER FIX

✅ Super admin can change any non-super_admin user's role
✅ Changes persist in database
✅ Verification confirms role was saved
✅ User sees new role instantly on refresh (no cache delay)
✅ Console shows clear success/failure messages

❌ Cannot change own role (prevented)
❌ Cannot change another super_admin's role (protected)
❌ Cannot assign super_admin role to anyone (only one super_admin allowed)

## FILES MODIFIED
- `admin.html` - Added verification step in `saveRole()` function (lines ~1420-1445)

## FILES TO RUN IN SUPABASE
- `check_and_fix_rls_policies.sql` - Fixes RLS policies blocking role updates

## TESTING CHECKLIST
- [ ] Run `check_and_fix_rls_policies.sql` in Supabase
- [ ] Change admin → officer (should succeed with verification)
- [ ] Change officer → viewer (should succeed with verification)
- [ ] Change viewer → admin (should succeed with verification)
- [ ] Try to change own role (should be prevented with error)
- [ ] Try to change super_admin role (should be prevented with error)
- [ ] Try to assign super_admin role (should be prevented with error)
- [ ] Refresh page and verify changes persisted
- [ ] Check console logs show verification success messages

## RELATED FILES
- `admin.html` - Role management UI
- `check_and_fix_rls_policies.sql` - RLS policy fix script
- `fix_role_update_tracking.sql` - Adds role_updated_at timestamp (already run)
- `CACHE_REDUCED.md` - Cache set to 0 for instant updates

---
**Status**: ✅ Code updated, awaiting user to run SQL script
**Date**: 2026-05-28
**Task**: #10 - Fix Super Admin Role Change Permissions
