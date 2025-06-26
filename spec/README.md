# RichTextExtraction Specs - DRY Refactoring & Directory Structure

This directory contains the test suite for RichTextExtraction, now fully DRY and organized by feature.

## 🎯 DRY Refactoring Goals

- Eliminate duplication in test setup and logic
- Use shared contexts and examples for all common patterns
- Organize specs by feature for clarity and maintainability

## 🗂️ Directory Structure

```
spec/
  advanced/           # Advanced/edge-case specs
    advanced_error_handling_spec.rb
    advanced_view_helper_spec.rb
  api/                # API-related specs
    validators_api_spec.rb
    validators_openapi_spec.rb
  core/               # Core and utility specs
    core_functionality_spec.rb
    error_spec.rb
    extraction_helpers_spec.rb
    extracts_rich_text_spec.rb
    helpers_spec.rb
    instance_helpers_spec.rb
    railtie_spec.rb
    version_spec.rb
  extractors/         # Extractor-related specs
    extractor_consolidated_spec.rb
    link_extractor_spec.rb
    social_extractor_spec.rb
    validators_spec.rb
  integration/        # Integration specs
    rails_integration_spec.rb
    rails_model_validators_spec.rb
  jobs/               # Background/job specs
    actiontext_jobs_spec.rb
    advanced_background_jobs_spec.rb
  markdown/           # Markdown-related specs
    markdown_helpers_spec.rb
    markdown_service_spec.rb
  opengraph/          # OpenGraph-related specs
    opengraph_service_spec.rb
    opengraph_spec.rb
  support/            # Shared contexts/examples
    shared_contexts.rb
    shared_examples.rb
    shared_examples_api.rb
  README.md           # This file
  rails_helper.rb     # Rails-specific test config
  services/           # (empty or legacy, can be removed)
  spec_helper.rb      # Main RSpec config
  swagger_helper.rb   # Swagger/OpenAPI config
  validators/         # (empty or for future validator specs)
```

## 🔧 Shared Contexts & Examples
- All common setup and test logic is in `support/shared_contexts.rb` and `support/shared_examples.rb`.
- Use `include_context` and `include_examples` in your specs for DRY, maintainable tests.

## 📝 Best Practices
- **Add new specs** in the appropriate subdirectory by feature.
- **Require only `spec_helper`** at the top of each spec file.
- **Use shared contexts/examples** for all common patterns.
- **Keep top-level spec directory clean**—all specs should be in subdirectories.

## 🚀 Running Tests

```bash
bundle exec rspec
```

RSpec will automatically find all specs in all subdirectories.

## 📈 Migration Guide
- If you add a new feature, create a new subdirectory if needed.
- If you add a new shared pattern, put it in `support/`.
- If you move or rename a spec, update any references in documentation or CI scripts.

## 🎉 Results
- **Cleaner, more maintainable tests**
- **Reduced duplication**
- **Better organization**
- **Faster onboarding for new contributors**

## Autodiscover Spec

### File: `spec/autodiscover_spec.rb`

The autodiscover spec is a fully automated, DRY test that:

- **Discovers all modules and classes** under the `RichTextExtraction` namespace.
- **Discovers all public methods** (module/class/instance/validator).
- **Tests all discovered methods** with sample data, including extraction, configuration, validator, cache, OpenGraph, and markdown methods.
- **Pattern-based testing:** Finds and tests methods matching common extraction, validation, cache, and configuration patterns.
- **Performance and edge case testing:** Checks method performance with large input, edge cases, and error handling.
- **Integration testing:** Tests method interactions and end-to-end workflows.

#### Why use autodiscover?
- **Zero-maintenance:** New features and methods are automatically tested as they are added.
- **Catches regressions:** Ensures all public API surfaces are exercised.
- **Promotes DRYness:** Reduces the need for repetitive, boilerplate specs.

#### How it works
- Uses Ruby's `ObjectSpace` to find all modules/classes/methods under `RichTextExtraction`.
- Runs generic tests on discovered methods, checking for expected behavior, return types, and error handling.
- Applies pattern-based discovery to ensure all extraction/validation/configuration/cache methods are covered.
- Includes performance and integration checks.

#### Usage

To run the autodiscover spec:

```sh
bundle exec rspec spec/autodiscover_spec.rb
```

Or as part of the full suite:

```sh
bundle exec rspec
```

#### Customization
- You can extend or modify the autodiscover spec to add more patterns, test more edge cases, or integrate with CI/CD workflows.
- For advanced reporting or analytics, see the scripts in `../scripts/`.

## Other Notes

- All support files in `spec/support` are loaded automatically by `spec_helper.rb`.
- For Rails integration, use `rails_helper.rb`.
- For advanced and monitoring scripts, see the `../scripts/` directory and its README.

For more information, see the main project README or contact the maintainers. 