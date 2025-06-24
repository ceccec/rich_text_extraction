// Plausible custom event tracking for Rich Text Extraction PWA

function trackEvent(eventName, props = {}) {
  if (window.plausible) {
    plausible(eventName, { props });
  }
}

// Track a validation attempt
function trackValidation(symbol, result, value = null) {
  const props = { validator: symbol, result };
  if (value !== null) props.value = value;
  trackEvent('Validation', props);
}

// Track a language switch
function trackLanguageSwitch(lang) {
  trackEvent('Language Switch', { lang });
}

// Track PWA install prompt
function trackPWAInstallPrompt() {
  trackEvent('PWA Install Prompt');
}

// Example usage:
// trackValidation('isbn', 'success');
// trackValidation('isbn', 'fail', '12345');
// trackLanguageSwitch('es');
// trackPWAInstallPrompt(); 