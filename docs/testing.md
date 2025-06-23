# Test Suite Organization

This project uses RSpec for testing. The test suite is organized by feature for maximum clarity and maintainability:

- Each major module or feature has its own spec file in `spec/`.
- Shared contexts and helpers are in `spec/support/`.
- Placeholders exist for all major modules to guide future test additions.

## Test File Structure

- `spec/extractor_spec.rb` — Extractor (links, tags, mentions)
- `spec/markdown_helpers_spec.rb` — Markdown rendering
- `spec/opengraph_helpers_spec.rb` — OpenGraph extraction and preview
- `spec/extracts_rich_text_spec.rb` — ExtractsRichText concern
- `spec/instance_helpers_spec.rb` — Instance helpers
- `spec/rails_integration_spec.rb` — Rails-specific integration
- `spec/actiontext_jobs_spec.rb` — ActionText and background job integration
- `spec/advanced_*.rb` — Advanced usage, error handling, background jobs, etc.
- `spec/support/shared_contexts.rb` — Shared contexts and helpers
- Placeholders: Each module (e.g., `Error`, `Helpers`, `Railtie`, `VERSION`) has a placeholder spec file.

## Running the Test Suite

To run all tests:

```sh
bundle exec rspec
```

## Adding New Tests

- Add new tests to the relevant feature file in `spec/`.
- If a new module is added, create a corresponding `spec/<module>_spec.rb` file.
- Use shared contexts from `spec/support/shared_contexts.rb` to avoid duplication. 