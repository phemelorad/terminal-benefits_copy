// ══════════════════════════════════════════════════════════════
// ERROR HANDLING SYSTEM
// ══════════════════════════════════════════════════════════════

// ── Error Codes Registry ──────────────────────────────────────
const ERROR_CODES = {
  // Authentication Errors (index.html)
  ERR_AUTH_001: {
    code: 'ERR_AUTH_001',
    title: 'Login Failed',
    message: 'Invalid email or password',
    action: 'Check your credentials and try again. Make sure Caps Lock is off.',
    contact: true
  },
  ERR_AUTH_002: {
    code: 'ERR_AUTH_002',
    title: 'Account Inactive',
    message: 'Your account is pending activation',
    action: 'Contact your administrator to activate your account',
    contact: true
  },
  ERR_AUTH_003: {
    code: 'ERR_AUTH_003',
    title: 'Password Reset Failed',
    message: 'Unable to send password reset email',
    action: 'SMTP server not configured. Contact IT support for manual password reset.',
    contact: true
  },
  ERR_AUTH_004: {
    code: 'ERR_AUTH_004',
    title: 'Registration Failed',
    message: 'Unable to create account',
    action: 'Check all fields are filled correctly and try again',
    contact: true
  },
  
  // Data Loading Errors (home.html, status.html)
  ERR_LOAD_001: {
    code: 'ERR_LOAD_001',
    title: 'Data Loading Failed',
    message: 'Unable to load dashboard data from the server',
    action: 'Try refreshing the page or check your internet connection',
    contact: true
  },
  ERR_LOAD_002: {
    code: 'ERR_LOAD_002',
    title: 'Compliance Data Failed',
    message: 'Unable to load compliance metrics',
    action: 'Dashboard will work without compliance data. Try refreshing the page.',
    contact: false
  },
  ERR_LOAD_003: {
    code: 'ERR_LOAD_003',
    title: 'Entries Loading Failed',
    message: 'Unable to load application entries',
    action: 'Check your connection and refresh the page',
    contact: true
  },
  
  // Save Errors (dashboard.html, status.html, profile.html)
  ERR_SAVE_001: {
    code: 'ERR_SAVE_001',
    title: 'Save Failed',
    message: 'Unable to save your changes to the database',
    action: 'Check your connection and try again. If problem persists, contact IT support.',
    contact: true
  },
  ERR_SAVE_002: {
    code: 'ERR_SAVE_002',
    title: 'Duplicate Entry',
    message: 'An application with these details already exists',
    action: 'Check existing entries or modify the officer, reason, or date',
    contact: false
  },
  ERR_SAVE_003: {
    code: 'ERR_SAVE_003',
    title: 'Profile Update Failed',
    message: 'Unable to save profile changes',
    action: 'Check all fields are valid and try again',
    contact: true
  },
  ERR_SAVE_004: {
    code: 'ERR_SAVE_004',
    title: 'Application Submit Failed',
    message: 'Unable to submit application',
    action: 'Check all required fields are filled and try again',
    contact: true
  },
  
  // Permission Errors (all pages)
  ERR_PERM_001: {
    code: 'ERR_PERM_001',
    title: 'Permission Denied',
    message: 'You don\'t have permission to perform this action',
    action: 'Contact your administrator to request elevated permissions',
    contact: true
  },
  ERR_PERM_002: {
    code: 'ERR_PERM_002',
    title: 'Viewer Restriction',
    message: 'Viewers cannot edit or submit records',
    action: 'Contact your administrator to upgrade your role to Officer or Admin',
    contact: true
  },
  ERR_PERM_003: {
    code: 'ERR_PERM_003',
    title: 'Super Admin Protected',
    message: 'Super admin accounts cannot be modified',
    action: 'This is a security restriction to protect system administrators',
    contact: false
  },
  
  // Validation Errors (all forms)
  ERR_VALID_001: {
    code: 'ERR_VALID_001',
    title: 'Validation Failed',
    message: 'Please check the form for errors',
    action: 'Fill in all required fields correctly',
    contact: false
  },
  ERR_VALID_002: {
    code: 'ERR_VALID_002',
    title: 'Password Requirements',
    message: 'Password does not meet requirements',
    action: 'Password must be at least 8 characters long',
    contact: false
  },
  ERR_VALID_003: {
    code: 'ERR_VALID_003',
    title: 'Password Mismatch',
    message: 'Passwords do not match',
    action: 'Make sure both password fields are identical',
    contact: false
  },
  
  // Export Errors (status.html, admin.html)
  ERR_EXPORT_001: {
    code: 'ERR_EXPORT_001',
    title: 'Export Failed',
    message: 'Unable to export data',
    action: 'Try exporting fewer records or refresh the page',
    contact: true
  },
  ERR_EXPORT_002: {
    code: 'ERR_EXPORT_002',
    title: 'No Data to Export',
    message: 'No records found for the selected period',
    action: 'Select a different period or check your filters',
    contact: false
  },
  
  // Admin Errors (admin.html)
  ERR_ADMIN_001: {
    code: 'ERR_ADMIN_001',
    title: 'Role Update Failed',
    message: 'Unable to update user role',
    action: 'Check your permissions and try again',
    contact: true
  },
  ERR_ADMIN_002: {
    code: 'ERR_ADMIN_002',
    title: 'User Deletion Failed',
    message: 'Unable to delete user account',
    action: 'Super admin accounts cannot be deleted. Contact IT support.',
    contact: true
  },
  ERR_ADMIN_003: {
    code: 'ERR_ADMIN_003',
    title: 'Status Update Failed',
    message: 'Unable to mark application as paid',
    action: 'Check your connection and try again',
    contact: true
  }
};

// ── Get Error Details ─────────────────────────────────────────
function getErrorDetails(code) {
  return ERROR_CODES[code] || {
    code: 'ERR_UNKNOWN',
    title: 'Unknown Error',
    message: 'An unexpected error occurred',
    action: 'Please try again or contact IT support',
    contact: true
  };
}

// ── Enhanced Toast Function ───────────────────────────────────
function showToast(message, isError = false, errorCode = null) {
  const toast = document.getElementById('toast');
  if (!toast) return;
  
  if (errorCode) {
    const errorDetails = getErrorDetails(errorCode);
    
    toast.innerHTML = `
      <div style="display:flex;flex-direction:column;gap:8px">
        <div style="display:flex;align-items:center;justify-content:space-between;gap:12px">
          <span style="font-weight:700">${errorDetails.title}</span>
          <span style="font-size:0.7rem;opacity:0.7;white-space:nowrap">${errorDetails.code}</span>
        </div>
        <div style="line-height:1.4">${errorDetails.message}</div>
        <div style="font-size:0.85rem;opacity:0.9;line-height:1.4">💡 ${errorDetails.action}</div>
        ${errorDetails.contact ? `
          <div style="font-size:0.85rem;opacity:0.8;margin-top:4px;padding-top:8px;border-top:1px solid rgba(255,255,255,0.2)">
            📞 Need help? Contact IT support or your system administrator
          </div>
        ` : ''}
      </div>
    `;
    
    console.error(`[${errorDetails.code}]`, message);
  } else {
    toast.textContent = message;
  }
  
  toast.className = isError ? 'toast show error' : 'toast show';
  setTimeout(() => toast.classList.remove('show'), errorCode ? 6000 : 3000); // Longer for errors with codes
}

// ── Enhanced Alert Function (for index.html) ──────────────────
function showAlert(msg, type = 'error', errorCode = null) {
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
        ${errorDetails.contact ? `
          <div style="font-size:0.9rem;opacity:0.8;margin-top:4px;padding-top:8px;border-top:1px solid currentColor;border-opacity:0.2">
            📞 Need help? Contact IT support or your system administrator
          </div>
        ` : ''}
      </div>
    `;
  } else {
    el.textContent = msg;
  }
}

// ── Error Type Detection ──────────────────────────────────────
function getSpecificError(error) {
  const msg = error.message || error.toString();
  
  // Network errors
  if (msg.includes('network') || msg.includes('fetch') || msg.includes('NetworkError')) {
    return {
      message: 'Network error: Unable to reach server. Check your internet connection.',
      code: null
    };
  }
  
  // Permission errors
  if (msg.includes('permission') || msg.includes('denied') || msg.includes('forbidden')) {
    return {
      message: 'Permission denied: You don\'t have access to perform this action.',
      code: 'ERR_PERM_001'
    };
  }
  
  // Duplicate errors
  if (msg.includes('duplicate') || msg.includes('unique') || msg.includes('already exists')) {
    return {
      message: 'Duplicate entry: An entry with these details already exists.',
      code: 'ERR_SAVE_002'
    };
  }
  
  // Timeout errors
  if (msg.includes('timeout') || msg.includes('timed out')) {
    return {
      message: 'Request timeout: Server took too long to respond. Please try again.',
      code: null
    };
  }
  
  // Authentication errors
  if (msg.includes('auth') || msg.includes('credentials') || msg.includes('password')) {
    return {
      message: 'Authentication error: Invalid credentials or session expired.',
      code: 'ERR_AUTH_001'
    };
  }
  
  // Generic error
  return {
    message: msg,
    code: null
  };
}
