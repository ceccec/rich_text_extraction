export function updateStatus(statusTarget, t) {
  if (navigator.onLine) {
    statusTarget.textContent = t ? t('online') : 'Online';
    statusTarget.className = "online";
  } else {
    statusTarget.textContent = t ? t('offline') : 'Offline: results may be cached or queued';
    statusTarget.className = "offline";
  }
}

export function queueRequest(url, payload) {
  const queue = JSON.parse(localStorage.getItem('validationQueue') || '[]');
  queue.push({ url, payload, timestamp: Date.now() });
  localStorage.setItem('validationQueue', JSON.stringify(queue));
  if ('serviceWorker' in navigator && 'SyncManager' in window) {
    navigator.serviceWorker.ready.then(sw => sw.sync.register('sync-validation'));
  }
}

export function handleValidationTracking(symbol, result, value) {
  if (typeof trackValidation === 'function') trackValidation(symbol, result, value);
}

export function formatPlural(key, vars = {}, lang = 'en') {
  if (typeof IntlMessageFormat === 'undefined') {
    // Fallback: just return the key or a simple string
    return (translations[key] || key).replace('{count}', vars.count || 0);
  }
  const icuString = translations[key];
  if (!icuString) return key;
  const msg = new IntlMessageFormat(icuString, lang);
  return msg.format(vars);
} 