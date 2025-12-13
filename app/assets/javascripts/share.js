// Share functionality for external platforms
document.addEventListener('DOMContentLoaded', function() {
  
  // ========================================
  // Native Share API (Mobile share sheet)
  // ========================================
  var nativeShareBtn = document.getElementById('native-share-btn');
  
  if (navigator.share && nativeShareBtn) {
    // Show native share button only if Web Share API is supported
    nativeShareBtn.style.display = 'inline-flex';
    
    nativeShareBtn.addEventListener('click', function() {
      var btn = this;
      navigator.share({
        title: btn.dataset.title,
        text: btn.dataset.text,
        url: btn.dataset.url
      }).catch(function(err) {
        if (err.name !== 'AbortError') {
          console.error('Share failed:', err);
        }
      });
    });
  }

  // ========================================
  // Copy Link functionality
  // ========================================
  var copyLinkBtn = document.getElementById('copy-link-btn');
  
  if (copyLinkBtn) {
    copyLinkBtn.addEventListener('click', function() {
      var url = this.dataset.url;
      var btn = this;
      
      copyToClipboard(url).then(function() {
        // Visual feedback
        var iconSpan = btn.querySelector('.share-icon');
        var labelSpan = btn.querySelector('.share-label');
        var originalIcon = iconSpan.innerHTML;
        var originalLabel = labelSpan.innerHTML;
        
        iconSpan.innerHTML = '✓';
        labelSpan.innerHTML = 'Copied!';
        btn.classList.add('share-copied');
        
        setTimeout(function() {
          iconSpan.innerHTML = originalIcon;
          labelSpan.innerHTML = originalLabel;
          btn.classList.remove('share-copied');
        }, 2000);
      });
    });
  }

  // ========================================
  // Instagram Share Modal
  // ========================================
  var instagramBtn = document.getElementById('instagram-share-btn');
  var instagramModal = document.getElementById('instagram-modal');
  
  if (instagramBtn && instagramModal) {
    var modalBackdrop = instagramModal.querySelector('.share-modal-backdrop');
    var modalCloseBtn = instagramModal.querySelector('.share-modal-close');
    var modalCloseBtn2 = instagramModal.querySelector('.share-modal-close-btn');
    var copyStatus = document.getElementById('instagram-copy-status');
    
    instagramBtn.addEventListener('click', function() {
      var shareText = this.dataset.shareText;
      
      // Copy to clipboard
      copyToClipboard(shareText).then(function() {
        copyStatus.innerHTML = '✓ Event details copied to clipboard!';
        copyStatus.className = 'copy-status copy-success';
      }).catch(function() {
        copyStatus.innerHTML = 'Could not copy automatically. Please copy manually.';
        copyStatus.className = 'copy-status copy-error';
      });
      
      // Show modal
      instagramModal.style.display = 'flex';
      document.body.style.overflow = 'hidden';
    });
    
    // Close modal handlers
    function closeInstagramModal() {
      instagramModal.style.display = 'none';
      document.body.style.overflow = '';
    }
    
    if (modalBackdrop) modalBackdrop.addEventListener('click', closeInstagramModal);
    if (modalCloseBtn) modalCloseBtn.addEventListener('click', closeInstagramModal);
    if (modalCloseBtn2) modalCloseBtn2.addEventListener('click', closeInstagramModal);
    
    // Close on escape key
    document.addEventListener('keydown', function(e) {
      if (e.key === 'Escape' && instagramModal.style.display === 'flex') {
        closeInstagramModal();
      }
    });
  }

  // ========================================
  // Helper: Copy to Clipboard
  // ========================================
  function copyToClipboard(text) {
    // Modern clipboard API
    if (navigator.clipboard && navigator.clipboard.writeText) {
      return navigator.clipboard.writeText(text);
    }
    
    // Fallback for older browsers
    return new Promise(function(resolve, reject) {
      var textArea = document.createElement('textarea');
      textArea.value = text;
      textArea.style.position = 'fixed';
      textArea.style.left = '-9999px';
      textArea.style.top = '-9999px';
      document.body.appendChild(textArea);
      textArea.focus();
      textArea.select();
      
      try {
        var successful = document.execCommand('copy');
        document.body.removeChild(textArea);
        if (successful) {
          resolve();
        } else {
          reject(new Error('Copy command failed'));
        }
      } catch (err) {
        document.body.removeChild(textArea);
        reject(err);
      }
    });
  }
  
  // ========================================
  // Track share button clicks (optional analytics)
  // ========================================
  var shareButtons = document.querySelectorAll('.share-btn');
  shareButtons.forEach(function(btn) {
    btn.addEventListener('click', function() {
      var platform = this.classList[2]; // e.g., 'share-whatsapp'
      if (platform) {
        console.log('Share clicked:', platform.replace('share-', ''));
        // You could send analytics here if needed
      }
    });
  });

});
