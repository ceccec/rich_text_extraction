#!/usr/bin/env node
const fs = require('fs');
const yaml = require('js-yaml');

const BANNER = `// This file is auto-generated from docs/_data/e2e_scenarios.yml.\n// Do not edit directly! Edit the YAML and run bin/generate_cypress_e2e_tests.js.\n`;

const scenarios = yaml.load(fs.readFileSync('docs/_data/e2e_scenarios.yml', 'utf8'));
const tests = [];

tests.push(BANNER);
tests.push('describe("Doc-driven E2E Scenarios", () => {');

for (const [name, scenario] of Object.entries(scenarios)) {
  tests.push(`  it('${name}', () => {`);
  for (const step of scenario.steps) {
    if (step.visit) tests.push(`    cy.visit('${step.visit}');`);
    if (step.fill_in) {
      const sel = step.fill_in.selector || `input[name="${step.fill_in.field}"]`;
      const opts = step.fill_in.options ? `, ${JSON.stringify(step.fill_in.options)}` : '';
      tests.push(`    cy.get('${sel}').type('${step.fill_in.value}'${opts});`);
    }
    if (step.clear) tests.push(`    cy.get('${step.clear}').clear();`);
    if (step.type) {
      const opts = step.type.options ? `, ${JSON.stringify(step.type.options)}` : '';
      tests.push(`    cy.get('${step.type.selector}').type('${step.type.value}'${opts});`);
    }
    if (step.click) {
      const sel = typeof step.click === 'string' ? step.click : step.click.selector;
      tests.push(`    cy.get('${sel}').click();`);
    }
    if (step.dblclick) tests.push(`    cy.get('${step.dblclick}').dblclick();`);
    if (step.rightclick) tests.push(`    cy.get('${step.rightclick}').rightclick();`);
    if (step.check) tests.push(`    cy.get('${step.check}').check();`);
    if (step.uncheck) tests.push(`    cy.get('${step.uncheck}').uncheck();`);
    if (step.select) tests.push(`    cy.get('${step.select.selector}').select('${step.select.value}');`);
    if (step.scrollTo) tests.push(`    cy.get('${step.scrollTo}').scrollTo('bottom');`);
    if (step.focus) tests.push(`    cy.get('${step.focus}').focus();`);
    if (step.blur) tests.push(`    cy.get('${step.blur}').blur();`);
    if (step.contains) tests.push(`    cy.contains('${step.contains}');`);
    if (step.assertUrl) tests.push(`    cy.url().should('include', '${step.assertUrl}');`);
    if (step.screenshot) tests.push(`    cy.screenshot('${step.screenshot}');`);
    if (step.invoke) tests.push(`    cy.get('${step.invoke.selector}').invoke('${step.invoke.method}');`);
    if (step.each) tests.push(`    cy.get('${step.each.selector}').each(($el) => { ${step.each.custom} });`);
    if (step.route) tests.push(`    cy.intercept('${step.route.method}', '${step.route.url}').as('${step.route.alias}');`);
    if (step.waitFor) tests.push(`    cy.wait('${step.waitFor}');`);
    if (step.assert) {
      if (step.assert.contains) {
        tests.push(`    cy.get('${step.assert.selector}').should('contain', '${step.assert.contains}');`);
      } else if (step.assert.visible) {
        tests.push(`    cy.get('${step.assert.selector}').should('be.visible');`);
      }
    }
    if (step.upload) {
      tests.push(`    cy.get('${step.upload.selector}').selectFile('${step.upload.file}');`);
    }
    if (step.wait) {
      tests.push(`    cy.wait(${step.wait});`);
    }
    if (step.custom) {
      tests.push(`    ${step.custom}`);
    }
  }
  if (scenario.expect) tests.push(`    cy.contains('${scenario.expect}');`);
  tests.push('  });');
}
tests.push('});');

fs.mkdirSync('cypress/e2e', { recursive: true });
fs.writeFileSync('cypress/e2e/generated_scenarios.cy.js', tests.join('\n'));
console.log('Generated cypress/e2e/generated_scenarios.cy.js from docs/_data/e2e_scenarios.yml.'); 