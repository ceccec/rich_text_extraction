import { Controller } from "@hotwired/stimulus"
import { updateStatus, queueRequest, handleValidationTracking } from "./validation_utils.js"

// Usage: Attach to a div with data-controller="validator-test" and data-validator-test-symbol-value="isbn"
// Requires input, output, jsonToggle, and status targets.
export default class extends Controller {
  static targets = ["input", "output", "jsonToggle", "status"]

  connect() {
    window.addEventListener('online', () => updateStatus(this.statusTarget, typeof t === 'function' ? t : undefined))
    window.addEventListener('offline', () => updateStatus(this.statusTarget, typeof t === 'function' ? t : undefined))
    updateStatus(this.statusTarget, typeof t === 'function' ? t : undefined)
  }

  async validate(event) {
    event.preventDefault()
    const symbol = this.data.get("symbol")
    const value = this.inputTarget.value
    const json = this.hasJsonToggleTarget && this.jsonToggleTarget.checked
    const payload = { value }
    const url = `/validators/${symbol}/validate`
    if (!navigator.onLine) {
      queueRequest(url, payload)
      this.outputTarget.textContent = typeof t === 'function' ? t('offline') : 'Offline: request queued.'
      handleValidationTracking(symbol, 'fail', value)
      return
    }
    try {
      const response = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json", "Accept": "application/json" },
        body: JSON.stringify(payload)
      })
      const data = await response.json()
      this.outputTarget.textContent = json ? JSON.stringify(data, null, 2) : this.formatResult(data)
      handleValidationTracking(symbol, data.valid ? 'success' : 'fail', value)
    } catch (err) {
      this.outputTarget.textContent = `Error: ${err}`
      handleValidationTracking(symbol, 'fail', value)
    }
  }

  formatResult(data) {
    if (data.valid) {
      return typeof t === 'function' ? t('validation_success') : "✅ Valid"
    } else if (data.errors && data.errors.length > 0) {
      return typeof t === 'function' ? t('validation_error', { error: data.errors.join(", ") }) : `❌ Invalid: ${data.errors.join(", ")}`
    } else {
      return typeof t === 'function' ? t('validation_error', { error: '' }) : "❌ Invalid"
    }
  }
} 