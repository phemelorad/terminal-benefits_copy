# Error Handling Improvements Guide

## Overview
This guide shows how to improve error messages with user-facing messages, specific details, error codes, and help links.

---

## 1. Convert Console Errors to User-Facing Messages

### ❌ Before (Console Only):
```javascript
// home.html
if (error) {
  console.error('Error loading data:', error);
  document.getElementById('s-total').textContent = 'ERR';
}
```

### ✅ After (User-Facing):
```javascript
// home.html
if (error) {
  console.error('[ERR_LOAD_001] Error loading data:', error);
  
  // Show user-friendly message
  showToast('⚠️ Unable to load dashboard data. Please refresh the page.', true);
  
  // Update UI gracefully
  document.getElementById('s-total').textContent = '—';
  
  // Optional: Show retry button
  showRetryButton('loadDashboard');
}
```

---

## 2. Make Generic Errors More Specific

### ❌ Before (Generic):
```javascript
// profile.html
if (error) { 
  showToast('Failed to save: ' + error.message, true); 
  return; 
}
```

### ✅ After (Specific):
```javascript
// profile.html
if (error) {
  let userMessage = '✗ Failed to save profile';
  
  // Provide specific context based on error type
  if (error.message.includes('network')) {
    userMessage = '✗ Network error: Unable to reach server. Check your connection.';
  } else if (error.message.includes('permission')) {
    userMessage = '✗ Permission denied: You don\'t have access to update this profile.';
  } else if (error.message.includes('duplicate')) {
    userMessage = '✗ Email already in use: Please use a different email address.';
  } else if (error.message.includes('timeout')) {
    userMessage = '✗ Request timeout: Server took too long to respond. Please try again.';
  } else {
    userMessage = `✗ Failed to save profile: ${error.message}`;
  }
  
  console.error('[ERR_PROFILE_001]', error);
  showToast(userMessage, true);
  return;
}
```

---

## 3. Add Error Codes for Support

### Error Code System:

**Format**: `ERR_[MODULE]_[NUMBER]`

**Examples**:
- `ERR_AUTH_001` - Login failed
- `ERR_LOAD_001` - Data loading failed
- `ERR_SAVE_001` - Save operation failed
- `ERR_PERM_001` - Permission denied
- `ERR_VALID_001` - Validation failed

### Implementation:

#### A. Create Error Code Registry:
```javascript
// Add to each HTML file (or create shared error-codes.js)

const ERROR_CODES = {
  // Authentication Errors (index.html)
  ERR_AUTH_001: {
    code: 'ERR_AUTH_001',
    title: 'Login Failed',
    message: 'Invalid email or password',
    help: 'https://docs.yourapp.com/troubleshooting/login-failed',
    action: 'Check your credentials and try again'
  },
  ERR_AUTH_002: {
    code: 'ERR_AUTH_002',
    title: 'Account Inactive',
    message: 'Your account is pending activation',
    help: 'https://docs.yourapp.com/account/activation',
    action: 'Contact your administrator'
  },
  ERR_AUTH_003: {
    code: 'ERR_AUTH_003',
    title: 'Password Reset Failed',
    message: 'Unable to send password reset email',
    help: 'https://docs.yourapp.com/troubleshooting/password-reset',
    action: 'Contact support if problem persists'
  },
  
  // Data Loading Errors (home.html, status.html)
  ERR_LOAD_001: {
    code: 'ERR_LOAD_001',
    title: 'Data Loading Failed',
    message: 'Unable to load dashboard data',
    help: 'https://docs.yourapp.com/troubleshooting/data-loading',
    action: 'Refresh the page or check your connection'
  },
  ERR_LOAD_002: {
    code: 'ERR_LOAD_002',
    title: 'Compliance Data Failed',
    message: 'Unable to load compliance metrics',
    help: 'https://docs.yourapp.com/troubleshooting/compliance-data',
    action: 'Try refreshing the page'
  },
  
  // Save Errors (dashboard.html, status.html, profile.html)
  ERR_SAVE_001: {
    code: 'ERR_SAVE_001',
    title: 'Save Failed',
    message: 'Unable to save your changes',
    help: 'https://docs.yourapp.com/troubleshooting/save-failed',
    action: 'Check your connection and try again'
  },
  ERR_SAVE_002: {
    code: 'ERR_SAVE_002',
    title: 'Duplicate Entry',
    message: 'An entry with these details already exists',
    help: 'https://docs.yourapp.com/troubleshooting/duplicates',
    action: 'Check existing entries or modify the details'
  },
  
  // Permission Errors (all pages)
  ERR_PERM_001: {
    code: 'ERR_PERM_001',
    title: 'Permission Denied',
    message: 'You don\'t have permission to perform this action',
    help: 'https://docs.yourapp.com/permissions/overview',
    action: 'Contact your administrator for access'
  },
  
  // Validation Errors (all forms)
  ERR_VALID_001: {
    code: 'ERR_VALID_001',
    title: 'Validation Failed',
    message: 'Please check the form for errors',
    help: 'https://docs.yourapp.com/forms/validation',
    action: 'Fill in all required fields correctly'
  },
  
  // Export Errors (status.html, admin.html)
  ERR_EXPORT_001: {
    code: 'ERR_EXPORT_001',
    title: 'Export Failed',
    message: 'Unable to export data',
    help: 'https://docs.yourapp.com/troubleshooting/export',
    action: 'Try exporting fewer records or refresh the page'
  }
};

// Helper function to get error details
function getErrorDetails(code) {
  return ERROR_CODES[code] || {
    code: 'ERR_UNKNOWN',
    title: 'Unknown Error',
    message: 'An unexpected error occurred',
    help: 'https://docs.yourapp.com/troubleshooting',
    action: 'Please try again or contact support'
  };
}
```

#### B. Enhanced showToast Function:
```javascript
// Replace existing showToast with enhanced version

function showToast(message, isError = false, errorCode = null) {
  const toast = document.getElementById('toast');
  
  if (errorCode) {
    const errorDetails = getErrorDetails(errorCode);
    
    // Create enhanced error message with help link
    const errorHTML = `
      <div style="display:flex;flex-direction:column;gap:8px">
        <div style="display:flex;align-items:center;gap:8px">
          <span style="font-weight:700">${errorDetails.title}</span>
          <span style="font-size:0.7rem;opacity:0.7">${errorDetails.code}</span>
        </div>
        <div>${errorDetails.message}</div>
        <div style="font-size:0.85rem;opacity:0.9">💡 ${errorDetails.action}</div>
        ${errorDetails.help ? `
          <a href="${errorDetails.help}" target="_blank" 
             style="color:inherit;text-decoration:underline;font-size:0.85rem">
            📖 Learn more →
          </a>
        ` : ''}
      </div>
    `;
    
    toast.innerHTML = errorHTML;
    console.error(`[${errorDetails.code}]`, message);
  } else {
    // Standard message (backward compatible)
    toast.textContent = message;
  }
  
  toast.className = isError ? 'toast show error' : 'toast show';
  setTimeout(() => toast.classList.remove('show'), 5000); // Longer for error codes
}
```

#### C. Usage Examples:

**Example 1: Login Error**
```javascript
// index.html
async function handleLogin() {
  const { data, error } = await db.auth.signInWithPassword({
    email: email,
    password: password
  });
  
  if (error) {
    // Use error code instead of generic message
    showAlert(getErrorDetails('ERR_AUTH_001').message, 'error', 'ERR_AUTH_001');
    return;
  }
}
```

**Example 2: Data Loading Error**
```javascript
// home.html
async function loadDashboard() {
  try {
    const { data, error } = await db.from('applications').select('*');
    
    if (error) {
      console.error('[ERR_LOAD_001]', error);
      showToast('Unable to load dashboard data', true, 'ERR_LOAD_001');
      return;
    }
    
    // Process data...
  } catch (e) {
    console.error('[ERR_LOAD_001]', e);
    showToast('Unable to load dashboard data', true, 'ERR_LOAD_001');
  }
}
```

**Example 3: Save Error**
```javascript
// dashboard.html
async function submitForm() {
  try {
    const { data, error } = await db.from('applications').insert(formData);
    
    if (error) {
      // Check for specific error types
      if (error.message.includes('duplicate')) {
        showToast('Duplicate entry detected', true, 'ERR_SAVE_002');
      } else {
        showToast('Failed to save application', true, 'ERR_SAVE_001');
      }
      return;
    }
    
    showToast('✓ Application submitted successfully!');
  } catch (e) {
    console.error('[ERR_SAVE_001]', e);
    showToast('Failed to save application', true, 'ERR_SAVE_001');
  }
}
```

---

## 4. Add Help Links for Complex Issues

### A. Enhanced Alert Function (index.html):
```javascript
function showAlert(msg, type = 'error', errorCode = null, helpLink = null) {
  const el = document.getElementById('alert');
  if (!el) return;
  
  el.className = `alert ${type}`;
  
  if (errorCode) {
    const errorDetails = getErrorDetails(errorCode);
    el.innerHTML = `
      <div style="display:flex;flex-direction:column;gap:10px">
        <div style="display:flex;align-items:center;justify-content:space-between">
          <strong>${errorDetails.title}</strong>
          <span style="font-size:0.75rem;opacity:0.7">${errorDetails.code}</span>
        </div>
        <div>${errorDetails.message}</div>
        <div style="font-size:0.9rem;opacity:0.9">💡 ${errorDetails.action}</div>
        ${errorDetails.help ? `
          <a href="${errorDetails.help}" target="_blank" 
             style="color:inherit;text-decoration:underline;display:inline-flex;align-items:center;gap:4px">
            📖 View troubleshooting guide
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
              <path d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6"></path>
              <polyline points="15 3 21 3 21 9"></polyline>
              <line x1="10" y1="14" x2="21" y2="3"></line>
            </svg>
          </a>
        ` : ''}
      </div>
    `;
  } else {
    el.textContent = msg;
  }
}
```

### B. Contextual Help Links:

**Example 1: SMTP Configuration Error**
```javascript
// index.html - Password reset
if (error.status === 500) {
  const errorMsg = `
    <div style="display:flex;flex-direction:column;gap:12px">
      <div>
        <strong>⚠ Email Configuration Error</strong>
        <span style="font-size:0.75rem;opacity:0.7;margin-left:8px">ERR_AUTH_003</span>
      </div>
      <div>
        The email server is not configured correctly. Password reset emails cannot be sent.
      </div>
      <div style="font-size:0.9rem;opacity:0.9">
        💡 Contact your administrator to reset your password manually via the Supabase dashboard.
      </div>
      <div style="display:flex;gap:12px;margin-top:4px">
        <a href="https://docs.yourapp.com/admin/smtp-setup" target="_blank" 
           style="color:inherit;text-decoration:underline;font-size:0.9rem">
          📖 SMTP Setup Guide →
        </a>
        <a href="https://docs.yourapp.com/admin/manual-password-reset" target="_blank" 
           style="color:inherit;text-decoration:underline;font-size:0.9rem">
          🔧 Manual Reset Guide →
        </a>
      </div>
    </div>
  `;
  showAlert(errorMsg, 'error');
}
```

**Example 2: Duplicate Entry with Help**
```javascript
// dashboard.html
if (err.message.startsWith('⚠ Duplicate')) {
  const duplicateHTML = `
    <div class="duplicate-alert">
      <div style="display:flex;align-items:center;justify-content:space-between">
        <strong>⚠ Duplicate Entry Detected</strong>
        <span style="font-size:0.75rem;opacity:0.7">ERR_SAVE_002</span>
      </div>
      <div style="margin-top:8px">${err.message}</div>
      <div style="margin-top:12px;font-size:0.9rem;opacity:0.9">
        💡 An application with the same officer, reason, and date already exists.
      </div>
      <div style="margin-top:12px;display:flex;gap:12px">
        <a href="status.html" style="color:inherit;text-decoration:underline;font-size:0.9rem">
          📋 View existing entries →
        </a>
        <a href="https://docs.yourapp.com/forms/duplicates" target="_blank" 
           style="color:inherit;text-decoration:underline;font-size:0.9rem">
          📖 About duplicate detection →
        </a>
      </div>
      <button onclick="this.parentElement.remove()" 
              style="margin-top:12px;padding:6px 12px;background:#c8a84b;color:#fff;border:none;border-radius:4px;cursor:pointer">
        Dismiss
      </button>
    </div>
  `;
  
  showDuplicateAlert(duplicateHTML);
}
```

**Example 3: Permission Error with Help**
```javascript
// status.html, admin.html
if (currentRole === 'viewer') {
  const permissionHTML = `
    <div style="display:flex;flex-direction:column;gap:10px">
      <div style="display:flex;align-items:center;justify-content:space-between">
        <strong>⛔ Permission Denied</strong>
        <span style="font-size:0.75rem;opacity:0.7">ERR_PERM_001</span>
      </div>
      <div>Viewers cannot edit records. You need Officer, Admin, or Super Admin role.</div>
      <div style="font-size:0.9rem;opacity:0.9">
        💡 Contact your administrator to request elevated permissions.
      </div>
      <a href="https://docs.yourapp.com/permissions/roles" target="_blank" 
         style="color:inherit;text-decoration:underline;font-size:0.9rem;margin-top:4px">
        📖 Learn about user roles →
      </a>
    </div>
  `;
  
  showToast(permissionHTML, true, 'ERR_PERM_001');
  return;
}
```

---

## 5. Create Error Help Modal (Optional)

### A. Add Modal HTML:
```html
<!-- Add to each HTML file -->
<div class="modal-overlay" id="error-help-modal" onclick="closeErrorHelp(event)">
  <div class="modal-box" style="max-width:600px">
    <div class="modal-header">
      <h3 id="error-help-title">Error Details</h3>
      <button onclick="closeModal('error-help-modal')" class="modal-close">✕</button>
    </div>
    <div class="modal-body" id="error-help-content">
      <!-- Error details populated here -->
    </div>
    <div class="modal-footer">
      <button onclick="closeModal('error-help-modal')" class="btn-secondary">Close</button>
      <a id="error-help-link" href="#" target="_blank" class="btn-primary">
        View Full Guide →
      </a>
    </div>
  </div>
</div>
```

### B. Show Error Help Function:
```javascript
function showErrorHelp(errorCode) {
  const errorDetails = getErrorDetails(errorCode);
  
  document.getElementById('error-help-title').textContent = 
    `${errorDetails.title} (${errorDetails.code})`;
  
  document.getElementById('error-help-content').innerHTML = `
    <div style="display:flex;flex-direction:column;gap:16px">
      <div>
        <h4 style="margin:0 0 8px 0;color:var(--navy)">What happened?</h4>
        <p style="margin:0">${errorDetails.message}</p>
      </div>
      <div>
        <h4 style="margin:0 0 8px 0;color:var(--navy)">What should I do?</h4>
        <p style="margin:0">${errorDetails.action}</p>
      </div>
      <div>
        <h4 style="margin:0 0 8px 0;color:var(--navy)">Common causes:</h4>
        <ul style="margin:8px 0;padding-left:20px">
          ${getCommonCauses(errorCode).map(cause => `<li>${cause}</li>`).join('')}
        </ul>
      </div>
      <div>
        <h4 style="margin:0 0 8px 0;color:var(--navy)">Need more help?</h4>
        <p style="margin:0">
          Contact your system administrator or 
          <a href="mailto:support@yourapp.com">support@yourapp.com</a>
        </p>
      </div>
    </div>
  `;
  
  document.getElementById('error-help-link').href = errorDetails.help;
  
  openModal('error-help-modal');
}

function getCommonCauses(errorCode) {
  const causes = {
    'ERR_AUTH_001': [
      'Incorrect email or password',
      'Account not yet activated',
      'Caps Lock is on'
    ],
    'ERR_LOAD_001': [
      'Poor internet connection',
      'Server is temporarily unavailable',
      'Browser cache needs clearing'
    ],
    'ERR_SAVE_001': [
      'Network connection lost',
      'Required fields are missing',
      'Database is temporarily unavailable'
    ],
    'ERR_SAVE_002': [
      'Entry with same details already exists',
      'Officer already has an application for this reason and date',
      'Check existing entries before submitting'
    ]
  };
  
  return causes[errorCode] || ['Unknown cause', 'Please contact support'];
}
```

### C. Usage in Toast:
```javascript
function showToast(message, isError = false, errorCode = null) {
  const toast = document.getElementById('toast');
  
  if (errorCode) {
    const errorDetails = getErrorDetails(errorCode);
    
    toast.innerHTML = `
      <div style="display:flex;flex-direction:column;gap:8px">
        <div style="display:flex;align-items:center;justify-content:space-between">
          <span style="font-weight:700">${errorDetails.title}</span>
          <span style="font-size:0.7rem;opacity:0.7">${errorDetails.code}</span>
        </div>
        <div>${errorDetails.message}</div>
        <div style="display:flex;gap:12px;margin-top:4px">
          <button onclick="showErrorHelp('${errorCode}')" 
                  style="background:none;border:none;color:inherit;text-decoration:underline;cursor:pointer;padding:0;font-size:0.85rem">
            📖 Learn more
          </button>
          <a href="${errorDetails.help}" target="_blank" 
             style="color:inherit;text-decoration:underline;font-size:0.85rem">
            🔧 Troubleshooting guide →
          </a>
        </div>
      </div>
    `;
  } else {
    toast.textContent = message;
  }
  
  toast.className = isError ? 'toast show error' : 'toast show';
  setTimeout(() => toast.classList.remove('show'), 5000);
}
```

---

## 6. Implementation Priority

### Phase 1: Quick Wins (1-2 hours)
1. ✅ Add error codes to console.error statements
2. ✅ Make 5-10 most common errors more specific
3. ✅ Add help links to SMTP and permission errors

### Phase 2: Enhanced Messages (2-3 hours)
1. ✅ Create ERROR_CODES registry
2. ✅ Update showToast to support error codes
3. ✅ Update showAlert to support error codes
4. ✅ Add help links to all error codes

### Phase 3: Full System (3-4 hours)
1. ✅ Convert all console errors to user-facing
2. ✅ Add error help modal
3. ✅ Create documentation pages
4. ✅ Test all error scenarios

---

## 7. Documentation Pages Needed

Create these help pages (can be simple markdown/HTML):

1. **https://docs.yourapp.com/troubleshooting**
   - General troubleshooting guide
   - Common issues and solutions

2. **https://docs.yourapp.com/troubleshooting/login-failed**
   - Login issues
   - Password reset
   - Account activation

3. **https://docs.yourapp.com/troubleshooting/data-loading**
   - Data loading issues
   - Network problems
   - Browser compatibility

4. **https://docs.yourapp.com/troubleshooting/save-failed**
   - Save operation failures
   - Validation errors
   - Duplicate detection

5. **https://docs.yourapp.com/permissions/overview**
   - User roles explained
   - Permission levels
   - How to request access

6. **https://docs.yourapp.com/admin/smtp-setup**
   - SMTP configuration
   - Email server setup
   - Testing email delivery

---

## 8. Example: Complete Implementation

Here's a complete example for **home.html**:

```javascript
// ── Error Codes Registry ──────────────────────────────────────
const ERROR_CODES = {
  ERR_LOAD_001: {
    code: 'ERR_LOAD_001',
    title: 'Data Loading Failed',
    message: 'Unable to load dashboard data from the server',
    help: 'https://docs.yourapp.com/troubleshooting/data-loading',
    action: 'Try refreshing the page or check your internet connection'
  },
  ERR_LOAD_002: {
    code: 'ERR_LOAD_002',
    title: 'Compliance Data Failed',
    message: 'Unable to load compliance metrics',
    help: 'https://docs.yourapp.com/troubleshooting/compliance-data',
    action: 'The dashboard will work without compliance data. Try refreshing.'
  }
};

function getErrorDetails(code) {
  return ERROR_CODES[code] || {
    code: 'ERR_UNKNOWN',
    title: 'Unknown Error',
    message: 'An unexpected error occurred',
    help: 'https://docs.yourapp.com/troubleshooting',
    action: 'Please try again or contact support'
  };
}

// ── Enhanced Toast Function ───────────────────────────────────
function showToast(message, isError = false, errorCode = null) {
  const toast = document.getElementById('toast');
  
  if (errorCode) {
    const errorDetails = getErrorDetails(errorCode);
    
    toast.innerHTML = `
      <div style="display:flex;flex-direction:column;gap:8px">
        <div style="display:flex;align-items:center;justify-content:space-between">
          <span style="font-weight:700">${errorDetails.title}</span>
          <span style="font-size:0.7rem;opacity:0.7">${errorDetails.code}</span>
        </div>
        <div>${errorDetails.message}</div>
        <div style="font-size:0.85rem;opacity:0.9">💡 ${errorDetails.action}</div>
        ${errorDetails.help ? `
          <a href="${errorDetails.help}" target="_blank" 
             style="color:inherit;text-decoration:underline;font-size:0.85rem;margin-top:4px;display:inline-block">
            📖 View troubleshooting guide →
          </a>
        ` : ''}
      </div>
    `;
    
    console.error(`[${errorDetails.code}]`, message);
  } else {
    toast.textContent = message;
  }
  
  toast.className = isError ? 'toast show error' : 'toast show';
  setTimeout(() => toast.classList.remove('show'), 5000);
}

// ── Updated Load Function ─────────────────────────────────────
async function loadDashboard() {
  try {
    showStatsSkeletons();
    
    const { data, error } = await db
      .from('applications')
      .select('*');
    
    if (error) {
      console.error('[ERR_LOAD_001]', error);
      
      // Show user-friendly error with help
      showToast('Unable to load dashboard data', true, 'ERR_LOAD_001');
      
      // Update UI gracefully
      document.getElementById('s-total').textContent = '—';
      hideStatsSkeletons();
      return;
    }
    
    // Process data...
    allApps = data;
    renderStats();
    
  } catch (e) {
    console.error('[ERR_LOAD_001]', e);
    showToast('Unable to load dashboard data', true, 'ERR_LOAD_001');
    hideStatsSkeletons();
  }
}

// ── Load Compliance Metrics ───────────────────────────────────
async function loadComplianceMetrics() {
  const { data, error } = await db
    .from('applications')
    .select('file_prep_compliant, leave_payment_compliant, benefits_payment_compliant, overall_compliant');
  
  if (error || !data) {
    console.error('[ERR_LOAD_002]', error);
    
    // Show warning but don't block dashboard
    showToast('Unable to load compliance metrics', true, 'ERR_LOAD_002');
    
    // Set default values
    document.getElementById('kpi-file-prep').textContent = '—';
    document.getElementById('kpi-leave-payment').textContent = '—';
    document.getElementById('kpi-benefits').textContent = '—';
    document.getElementById('kpi-overall').textContent = '—';
    return;
  }
  
  // Calculate and display metrics...
}
```

---

## Summary

### What We're Adding:

1. **Error Codes** 🏷️
   - Unique identifier for each error type
   - Easy to reference in support tickets
   - Helps track error patterns

2. **Specific Messages** 📝
   - Context-aware error descriptions
   - Clear explanation of what went wrong
   - Actionable guidance on what to do

3. **Help Links** 🔗
   - Direct links to troubleshooting guides
   - Contextual documentation
   - Self-service support

4. **Better UX** ✨
   - User-facing instead of console-only
   - Graceful degradation
   - Professional error handling

### Benefits:

- ✅ Users understand what went wrong
- ✅ Users know what to do next
- ✅ Support team can identify issues faster
- ✅ Self-service reduces support burden
- ✅ Professional, polished experience

