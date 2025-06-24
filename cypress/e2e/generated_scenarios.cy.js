// This file is auto-generated from docs/_data/e2e_scenarios.yml.
// Do not edit directly! Edit the YAML and run bin/generate_cypress_e2e_tests.js.

describe("Doc-driven E2E Scenarios", () => {
  it('login', () => {
    cy.visit('/login');
    cy.get('input[name="Email"]').type('user@example.com');
    cy.get('input[name="Password"]').type('password');
    cy.contains('Log in').click();
    cy.contains('Dashboard');
  });
});