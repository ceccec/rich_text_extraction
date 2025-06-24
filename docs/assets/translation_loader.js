let translations = {};
function loadTranslations(lang) {
  return fetch(`/assets/i18n/${lang}.json`)
    .then(res => res.json())
    .then(data => { translations = data; });
}
function t(key, vars = {}) {
  let str = translations[key] || key;
  Object.keys(vars).forEach(k => {
    str = str.replace(`{${k}}`, vars[k]);
  });
  return str;
}
// Usage: loadTranslations('en').then(() => t('validation_success')); 