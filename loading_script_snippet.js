// ══════════════════════════════════════════════════════
// ── LOADING MANAGER ───────────────────────────────────
// ══════════════════════════════════════════════════════

const LoadingManager = {
  overlay: null,
  
  init() {
    this.overlay = document.getElementById('loader');
    document.body.classList.add('loaded');
  },
  
  show(message = 'Loading...') {
    if (this.overlay) {
      const textEl = this.overlay.querySelector('.loading-text');
      if (textEl) textEl.textContent = message;
      this.overlay.classList.remove('hidden');
    }
  },
  
  hide() {
    if (this.overlay) {
      setTimeout(() => {
        this.overlay.classList.add('hidden');
      }, 300);
    }
  }
};

// Initialize and hide loader
LoadingManager.init();
window.addEventListener('load', () => {
  LoadingManager.hide();
});

// Smooth navigation transitions
document.querySelectorAll('a[href]').forEach(link => {
  const href = link.getAttribute('href');
  if (href && !href.startsWith('#') && !href.startsWith('mailto:') && !href.startsWith('tel:')) {
    link.addEventListener('click', (e) => {
      if (link.target !== '_blank') {
        e.preventDefault();
        document.body.style.opacity = '0';
        setTimeout(() => window.location.href = href, 200);
      }
    });
  }
});
