document.addEventListener('DOMContentLoaded', function() {
  const optout = document.getElementById('analytics-optout');
  if (!optout) return;
  optout.checked = !!localStorage.getItem('plausible_ignore');
  optout.addEventListener('change', function(e) {
    if (e.target.checked) {
      localStorage.setItem('plausible_ignore', 'true');
    } else {
      localStorage.removeItem('plausible_ignore');
    }
  });
}); 