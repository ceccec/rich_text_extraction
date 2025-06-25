# GitHub Actions Workflows

This directory contains GitHub Actions workflows organized using DRY (Don't Repeat Yourself) principles to reduce duplication and improve maintainability.

## Structure

### Reusable Workflows (`.github/workflows/reusable/`)

These workflows can be called by other workflows to avoid code duplication:

- **`setup-ruby.yml`** - Sets up Ruby environment with caching
- **`test.yml`** - Runs tests with optional coverage upload
- **`lint.yml`** - Runs linting tools (RuboCop, StandardRB, etc.)
- **`rails-integration.yml`** - Tests Rails integration across versions

### Main Workflows

- **`ci-consolidated.yml`** - Consolidated CI workflow using reusable components
- **`jekyll.yml`** - Jekyll site deployment to GitHub Pages
- **`gem-push.yml`** - Gem publishing workflow

## Benefits of DRY Workflows

1. **Reduced Duplication**: Common patterns are defined once and reused
2. **Easier Maintenance**: Changes to common steps only need to be made in one place
3. **Consistency**: All workflows use the same setup and configuration
4. **Flexibility**: Reusable workflows accept parameters for customization

## Usage Examples

### Using a Reusable Workflow

```yaml
jobs:
  test:
    uses: ./.github/workflows/reusable/test.yml
    with:
      ruby-version: '3.2.3'
      coverage: true
      upload-coverage: true
    secrets:
      CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}
```

### Matrix Strategy with Reusable Workflows

```yaml
jobs:
  test-matrix:
    uses: ./.github/workflows/reusable/test.yml
    strategy:
      matrix:
        ruby-version: ['3.0', '3.1', '3.2', '3.3']
    with:
      ruby-version: ${{ matrix.ruby-version }}
      coverage: true
```

## Migration from Old Workflows

The old workflows (`test.yml`, `ci.yml`, `main.yml`) have been consolidated into `ci-consolidated.yml` which uses the reusable components. This provides the same functionality with less code duplication.

## Adding New Reusable Workflows

1. Create a new file in `.github/workflows/reusable/`
2. Define inputs and outputs as needed
3. Use `workflow_call` trigger
4. Document the workflow in this README

## Workflow Parameters

### setup-ruby.yml
- `ruby-version`: Ruby version to use (default: '3.2.3')
- `bundler-cache`: Whether to cache bundler (default: true)
- `cache-version`: Cache version for bundler (default: 0)

### test.yml
- `ruby-version`: Ruby version to use (default: '3.2.3')
- `test-command`: Test command to run (default: 'bundle exec rspec')
- `coverage`: Whether to run with coverage (default: false)
- `upload-coverage`: Whether to upload coverage to Codecov (default: false)

### lint.yml
- `ruby-version`: Ruby version to use (default: '3.2.3')
- `rubocop`: Whether to run RuboCop (default: true)
- `standardrb`: Whether to run StandardRB (default: false)
- `debride`: Whether to run Debride for unused code (default: false)
- `bundle-audit`: Whether to run bundle audit (default: false)

### rails-integration.yml
- `ruby-version`: Ruby version to use (default: '3.2.3')
- `rails-version`: Rails version to test (required)
- `test-command`: Test command to run (default: Rails runner test) 