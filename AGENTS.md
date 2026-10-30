# AI Agent Instructions

## Project Overview

A double opt in book exchange web application.

This is a rebuild of a demo application, found at:
https://github.com/rbndickson/bookchange

## Tech Stack

- Ruby 4.0 & Rails 8.1
- PostgreSQL
- Turbo & Stimulus, bundled with esbuild
- Bootstrap 5 CSS & Bootstrap Icons, compiled with Sass
- Solid Queue, Solid Cache & Solid Cable
- RSpec with Fabrication and shoulda-matchers
- Capybara acceptance tests, with Cuprite as the JavaScript driver
- RuboCop for linting
- Brakeman & bundler-audit for security checks

## Workflow

- Ask questions when not totally sure what action is required; ensure all questions are answered before continuing
- Follow the feature order in `.specify/memory/roadmap.md` and keep its statuses up to date
- Keep to the required task without doing additional tasks
- Do not add gems or packages (Gemfile, `package.json`); ask the project owner to add them
- Work on this project inside a Docker Sandbox started with `sbx run claude` from the project
  directory, not directly on the host (see the README)
- Always check existing class definitions and interfaces before suggesting how to use them
- Check the current state of the repository (branches, files, config, installed packages) before
  stating it; the project owner may change things outside the session
- Run `bundle exec rspec` after making a feature
- Run `bundle exec rubocop` after making a feature
- Run `yarn lint:js` after making a feature
- Run `yarn format:js` after making a feature
- Run `yarn lint:erb` after making a feature
- Run `yarn format:erb` after making a feature
- For git commit messages, use conventional commit format (type: description)

## Code Guidelines

- Write Ruby code that conforms to the project's `.rubocop.yml` configuration
- When writing unit tests, write the tests using RSpec
- Avoid creating Rails controller tests
- When creating or updating files end with a newline character
- Avoid abbreviations for short words in naming - use full words (e.g. `button` not `btn`, `image` not `img`)

## Key Patterns

- Follow Ruby on Rails conventions

## Code Review Guidelines

- Focus on bugs, errors, security and important issues
- Check behavior against the feature's spec, and flag any behavior added, removed or changed
  without approval (including Known Issue decisions)
- Thoroughly investigate and understand code patterns before making suggestions
- Check for auto-generated values, conventions, and intentional design decisions
- If something looks incorrect or is unclear, ask about it for clarification
- Avoid suggesting controller tests
- Avoid raising harmless redundancies or small style inconsistencies that have zero functional impact
