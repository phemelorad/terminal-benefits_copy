// ══════════════════════════════════════════════════════════════
// AUTHENTICATION GUARD
// ══════════════════════════════════════════════════════════════
// This script must be loaded BEFORE page content is visible
// It ensures users are authenticated before accessing any page

(function() {
  'use strict';
  
  // Hide entire page body until authentication is verified
  document.documentElement.style.visibility = 'hidden';
  
  // Check authentication as soon as possible
  window.addEventListener('DOMContentLoaded', async function() {
    try {
      // Wait for Supabase to be available
      if (typeof window.supabase === 'undefined') {
        console.error('[AuthGuard] Supabase not loaded');
        redirectToLogin();
        return;
      }
      
      // Get current session
      const { data: { session }, error } = await window.db.auth.getSession();
      
      if (error || !session) {
        console.log('[AuthGuard] No valid session - redirecting to login');
        redirectToLogin();
        return;
      }
      
      // Session valid - show page
      console.log('[AuthGuard] Session valid - showing page');
      document.documentElement.style.visibility = 'visible';
      
    } catch (err) {
      console.error('[AuthGuard] Error checking authentication:', err);
      redirectToLogin();
    }
  });
  
  function redirectToLogin() {
    // Only redirect if not already on login page
    if (!window.location.pathname.includes('index.html') && 
        window.location.pathname !== '/' && 
        window.location.pathname !== '') {
      window.location.replace('index.html');
    } else {
      // On login page, show it
      document.documentElement.style.visibility = 'visible';
    }
  }
  
  // Timeout safety - show page after 3 seconds even if check fails
  setTimeout(function() {
    if (document.documentElement.style.visibility === 'hidden') {
      console.warn('[AuthGuard] Timeout - forcing page visible');
      document.documentElement.style.visibility = 'visible';
    }
  }, 3000);
  
})();
