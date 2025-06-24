# Validator Reference
This file is auto-generated from the gem's DRY validator structure.

**Note:** This reference is auto-generated from the `VALIDATOR_EXAMPLES` hash in the codebase. All validator and extractor documentation is DRY and always consistent with the code and API.

**Note:** All valid/invalid examples below are automatically tested via doc-driven specs (`rake test:scenarios_from_docs`), ensuring documentation and code are always in sync.

[Usage Guide](usage.md) | [API Reference](api.markdown)

## `isbn`
- **Schema.org Type:** [`Book`](https://schema.org/Book)
- **Schema.org Property:** [`isbn`](https://schema.org/isbn)
- **Description:** International Standard Book Number (schema.org/Book/isbn)
- **Valid examples:** `978-3-16-148410-0`, `0-306-40615-2`
- **Invalid examples:** `978-3-16-148410-1`, `123`

## `vin`
- **Schema.org Type:** [`Vehicle`](https://schema.org/Vehicle)
- **Schema.org Property:** [`vehicleIdentificationNumber`](https://schema.org/vehicleIdentificationNumber)
- **Description:** Vehicle Identification Number (schema.org/Vehicle/vehicleIdentificationNumber)
- **Regex:** `VIN_REGEX`
- **Valid examples:** `1HGCM82633A004352`
- **Invalid examples:** `1HGCM82633A004353`, `123`

## `issn`
- **Schema.org Type:** [`PublicationIssue`](https://schema.org/PublicationIssue)
- **Schema.org Property:** [`issn`](https://schema.org/issn)
- **Description:** International Standard Serial Number (schema.org/PublicationIssue/issn)
- **Valid examples:** `2049-3630`
- **Invalid examples:** `2049-3631`, `123`

## `iban`
- **Schema.org Type:** [`BankAccount`](https://schema.org/BankAccount)
- **Schema.org Property:** [`identifier`](https://schema.org/identifier)
- **Description:** International Bank Account Number (no direct schema.org property, using identifier)
- **Regex:** `IBAN_REGEX`
- **Valid examples:** `GB82WEST12345698765432`
- **Invalid examples:** `GB82WEST12345698765431`, `123`

## `luhn`
- **Schema.org Type:** [`CreditCard`](https://schema.org/CreditCard)
- **Schema.org Property:** [`identifier`](https://schema.org/identifier)
- **Description:** Credit card number (schema.org/CreditCard/identifier, Luhn validated)
- **Regex:** `CREDIT_CARD_REGEX`
- **Valid examples:** `4111 1111 1111 1111`, `79927398713`
- **Invalid examples:** `4111 1111 1111 1112`, `123`

## `ean13`
- **Schema.org Type:** [`Product`](https://schema.org/Product)
- **Schema.org Property:** [`gtin13`](https://schema.org/gtin13)
- **Description:** EAN-13 barcode (schema.org/Product/gtin13)
- **Regex:** `EAN13_REGEX`
- **Valid examples:** `4006381333931`
- **Invalid examples:** `400638133393`, `abc`

## `upca`
- **Schema.org Type:** [`Product`](https://schema.org/Product)
- **Schema.org Property:** [`gtin12`](https://schema.org/gtin12)
- **Description:** UPC-A barcode (schema.org/Product/gtin12)
- **Regex:** `UPCA_REGEX`
- **Valid examples:** `036000291452`
- **Invalid examples:** `03600029145`, `abc`

## `uuid`
- **Schema.org Type:** [`Thing`](https://schema.org/Thing)
- **Schema.org Property:** [`identifier`](https://schema.org/identifier)
- **Description:** Universally Unique Identifier (schema.org/Thing/identifier)
- **Regex:** `

#### Live Test
<div data-controller="validator-test" data-validator-test-symbol-value="#{symbol}">
  <input data-validator-test-target="input" value="#{Array(ex[:valid]).first || ''}">
  <button data-action="click->validator-test#validate">Test</button>
  <label><input type="checkbox" data-validator-test-target="jsonToggle"> JSON output</label>
  <pre data-validator-test-target="output"></pre>
</div>

## Batch Validation (Live Demo)

<div data-controller="validator-batch" data-validator-batch-symbol-value="isbn">
  <div data-validator-batch-target="inputs"></div>
  <button data-action="click->validator-batch#validate">Batch Validate</button>
  <label>
    <input type="checkbox" data-validator-batch-target="jsonToggle"> JSON output
  </label>
  <pre data-validator-batch-target="output"></pre>
</div>