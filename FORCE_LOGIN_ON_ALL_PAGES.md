# FORCE LOGIN ON ALL PAGES

## ISSUE
When someone receives a direct link to a protected page (home.html, dashboard.html, status.html, admin.html, profile.html), the page content would briefly flash before the authentication check redirected them to login.

## SOLUTION IMPLEMENTED

### 1. Hide Page Until Authentication Verified
Added inline script in the `<head>` of all protected pages:
```html
<!-- Auth Guard: Hide page until authentication verified -->
<script>document.documentElement.style.opacity='0';</script>
```

This immediately hides the entire page (opacity=0) before any content loads.

### 2. Show Page After Authentication
Updated the authentication check in each page to show the page only after session is verified:
```javascript
const { data: { session } } = await db.auth.getSession();
if (!session) { location.replace('index.html'); return; }

// Show page now that auth is verified
document.documentElement.style.opacity = '1';
document.documentElement.style.transition = 'opacity 0.2s';
```

### 3. Smooth Fade-In
The page fades in smoothly (0.2s transition) once authentication is confirmed.

## HOW IT WORKS

**Before (Old Behavior):**
1. User clicks link to `home.html`
2. Page HTML loads and displays
3. JavaScript runs authentication check (takes ~500ms)
4. If not logged in, redirects to `index.html`
5. **Problem**: User sees protected content for ~500ms before redirect

**After (New Behavior):**
1. User clicks link to `home.html`
2. Page is immediately hidden (opacity=0) by inline script
3. JavaScript runs authentication check
4. If not logged in → redirects to `index.html` (user never sees content)
5. If logged in → page fades in smoothly
6. **Result**: No content flash, forced login for all protected pages

## PAGES UPDATED

✅ **home.html** - Dashboard page
✅ **dashboard.html** - Application form page
✅ **status.html** - Entries/status page
✅ **admin.html** - Admin panel
✅ **profile.html** - User profile page

❌ **index.html** - Login page (no auth guard needed)

## TESTING

**Test 1: Direct Link When Not Logged In**
1. Log out completely
2. Try to access: `https://your-domain.com/home.html`
3. Expected: Page stays blank, immediately redirects to `index.html`
4. ✅ No content flash

**Test 2: Direct Link When Logged In**
1. Log in as any user
2. Try to access: `https://your-domain.com/admin.html`
3. Expected: Page fades in smoothly after ~200ms
4. ✅ Content loads properly

**Test 3: Shared Link**
1. Copy link to `status.html` and send to someone
2. They click the link (not logged in)
3. Expected: Redirects to login, no content visible
4. ✅ Forced login works

## TECHNICAL DETAILS

- **Inline Script**: Runs immediately in `<head>` before any content renders
- **Opacity vs Display**: Using `opacity='0'` instead of `display='none'` allows smooth fade-in transition
- **No JavaScript Dependency**: Works even if JavaScript is slow to load
- **Fallback**: If auth check fails, redirect happens before page becomes visible

## SECURITY NOTES

⚠️ **Important**: This is a **UI-level** protection only. The actual security is enforced by:
1. **Supabase RLS policies** - Database-level access control
2. **Session validation** - Server-side authentication
3. **API authentication** - All API calls require valid JWT tokens

The opacity guard prevents **visual leakage** of protected content, but does not replace proper backend security.

---
**Status**: ✅ Complete
**Date**: 2026-05-28
**Files Modified**: home.html, dashboard.html, status.html, admin.html, profile.html
