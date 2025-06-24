import { Controller } from "@hotwired/stimulus"
import { updateStatus, queueRequest, handleValidationTracking } from "./validation_utils.js"

export default class extends Controller {
  static targets = ["inputs", "output", "jsonToggle", "status"]

  connect() {
    this.inputs = [""]
    this.renderInputs()
    window.addEventListener('online', () => updateStatus(this.statusTarget, typeof t === 'function' ? t : undefined))
    window.addEventListener('offline', () => updateStatus(this.statusTarget, typeof t === 'function' ? t : undefined))
    updateStatus(this.statusTarget, typeof t === 'function' ? t : undefined)
  }

  addInput(event) {
    event.preventDefault()
    this.inputs.push("")
    this.renderInputs()
  }

  removeInput(event) {
    event.preventDefault()
    const idx = parseInt(event.target.dataset.index, 10)
    this.inputs.splice(idx, 1)
    this.renderInputs()
  }

  updateInput(event) {
    const idx = parseInt(event.target.dataset.index, 10)
    this.inputs[idx] = event.target.value
  }

  async validate(event) {
    event.preventDefault()
    const symbol = this.data.get("symbol")
    const json = this.hasJsonToggleTarget && this.jsonToggleTarget.checked
    const payload = { values: this.inputs }
    const url = `/validators/${symbol}/batch_validate`
    if (!navigator.onLine) {
      queueRequest(url, payload)
      this.outputTarget.textContent = typeof t === 'function' ? t('offline') : 'Offline: request queued.'
      this.inputs.forEach(val => handleValidationTracking(symbol, 'fail', val))
      return
    }
    try {
      const response = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json", "Accept": "application/json" },
        body: JSON.stringify(payload)
      })
      const data = await response.json()
      this.outputTarget.textContent = json ? JSON.stringify(data, null, 2) : this.formatResults(data)
      data.forEach(res => handleValidationTracking(symbol, res.valid ? 'success' : 'fail', res.value))
    } catch (err) {
      this.outputTarget.textContent = `Error: ${err}`
      this.inputs.forEach(val => handleValidationTracking(symbol, 'fail', val))
    }
  }

  formatResults(data) {
    return data.map(res =>
      res.valid
        ? (typeof t === 'function' ? t('validation_success') : `705 ${res.value}`)
        : (typeof t === 'function' ? t('validation_error', { error: res.errors ? res.errors.join(", ") : '' }) : `74c ${res.value}: ${res.errors ? res.errors.join(", ") : "Invalid"}`)
    ).join("\n")
  }

  renderInputs() {
    this.inputsTarget.innerHTML = ""
    this.inputs.forEach((val, idx) => {
      const input = document.createElement("input")
      input.value = val
      input.setAttribute("data-index", idx)
      input.addEventListener("input", this.updateInput.bind(this))
      this.inputsTarget.appendChild(input)

      const removeBtn = document.createElement("button")
      removeBtn.textContent = "Remove"
      removeBtn.setAttribute("data-index", idx)
      removeBtn.addEventListener("click", this.removeInput.bind(this))
      this.inputsTarget.appendChild(removeBtn)
    })
    // Add button to add more inputs
    const addBtn = document.createElement("button")
    addBtn.textContent = "Add Input"
    addBtn.addEventListener("click", this.addInput.bind(this))
    this.inputsTarget.appendChild(addBtn)
  }
}