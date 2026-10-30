# Bookchange Constitution

## Core Principles

### I. Faithful Rebuild

Bookchange is a rebuild of the demo application at https://github.com/rbndickson/bookchange:
the same features, built with new technology.

- The feature set MUST be the same as the original's; the original application is the
  reference for user-facing behavior, and each feature spec MUST state which original behavior
  it reproduces.
- Any behavior added, removed or changed relative to the original MUST be called out explicitly
  in the feature spec and approved by the project owner before implementation.
- Bugs or quirks found in the original MUST be recorded as Known Issues in the spec, with the
  project owner's decision (reproduce, fix or drop) recorded alongside.
- The original's code is the starting point for coding style and structure (see Coding Style),
  but the rebuild MUST be implemented with the new tech stack (see Technology Stack & Constraints),
  not ported line by line. Technology differences alone are not behavior changes and do not need
  approval.

Rationale: a faithful rebuild needs a clear reference point, and silent drift makes the result
impossible to review against that reference.

### II. Double Opt-In Integrity

The double opt-in exchange is the core of the product: users never request or decline
exchanges; an exchange only happens when two users want each other's books.

- An exchange MUST only be possible between two users who each have at least one of the other's
  available books in their Wantlist.
- An exchange MUST NOT be confirmed until both users have each chosen one book from the other;
  the first choice opens the exchange and the second confirms it.
- A user MUST NOT be able to add their own book to their Wantlist or choose it in an exchange.
- On confirmation, both books MUST become unavailable, and users with pending exchanges for
  those books MUST be notified.
- These rules MUST be enforced on the server (models and authorization), never only in the UI.
- Every controller action that reads or changes user data MUST check that the current user is
  allowed to (e.g. only a book's owner edits it or marks it sent; only its receiver adds a
  sending address, marks it received or leaves feedback).
- A sending address MUST only be visible to the user sending the book in that confirmed
  exchange.

Rationale: the product's value depends on users trusting that nothing happens without both
parties' confirming and that their details are not public.

### III. Rails Conventions & Hotwire

- Code MUST follow Ruby on Rails conventions (RESTful resources, Active Record models,
  server-rendered views) unless a spec justifies a deviation.
- Interactivity MUST use Turbo and Stimulus by default. A JavaScript framework MAY be used
  where a feature needs it; the need MUST be justified in the feature's plan, and the package
  added by the project owner (Principle VI).
- Views MUST be ERB; styling MUST use Bootstrap 5 and Bootstrap Icons, compiled with Sass.
- Background work MUST use Solid Queue; caching Solid Cache; real-time updates Solid Cable.

Rationale: conventional Rails keeps the codebase small, predictable and easy to review.

### IV. Tested Behavior

- Every feature MUST be covered by RSpec tests before it is considered done.
- Each user story MUST have Capybara acceptance tests exercising it through the browser,
  using Cuprite where JavaScript is involved.
- Model, service and other unit-level logic (including exchange rules) MUST have RSpec unit
  tests.
- Test data MUST be built with Fabrication fabricators.
- Rails controller tests MUST NOT be written; access rules are covered by acceptance tests.
- Tests MUST NOT call external services (e.g. book information APIs); those calls MUST be
  stubbed.
- `bundle exec rspec` MUST pass before a feature is complete.

Rationale: acceptance tests verify behavior against the spec; unit tests protect the core rules.

### V. Quality & Security Gates

Before a feature is complete, all CI checks MUST pass locally:

- Ruby: `bundle exec rubocop`
- JavaScript: `yarn lint:js` and `yarn format:js` (CI checks `yarn format:js:check`)
- ERB: `yarn lint:erb` and `yarn format:erb` (CI checks `yarn format:erb:check`)
- Security: `bin/brakeman` and `bin/bundler-audit` MUST report no unresolved issues

Brakeman warnings MUST be fixed, or explicitly accepted by the project owner with a recorded
reason.

Rationale: matching CI locally prevents broken pushes and catches security issues early.

### VI. Scope Discipline & Simplicity

- Work MUST stay within the task requested; additional features or refactors require approval.
- Gems and JavaScript packages MUST NOT be added (`Gemfile`, `package.json`); the need MUST be
  raised with the project owner, who adds them.
- When requirements are unclear, questions MUST be asked and answered before work continues.
- The simplest design that satisfies the spec MUST be preferred; added complexity MUST be
  justified in the plan.

Rationale: a small, owner-controlled scope keeps the rebuild focused and reviewable.

## Technology Stack & Constraints

- Ruby 4.0 and Rails 8.1, with PostgreSQL.
- Turbo and Stimulus, bundled with esbuild; Propshaft for assets.
- Bootstrap 5 CSS and Bootstrap Icons, compiled with Sass.
- Solid Queue, Solid Cache and Solid Cable.
- RSpec with Fabrication and shoulda-matchers; Capybara acceptance tests with Cuprite as the
  JavaScript driver.
- RuboCop (with rubocop-rails and rubocop-rspec), oxlint and oxfmt, Herb.
- Brakeman, bundler-audit and `yarn audit` for security checks.
- Development by AI agents takes place inside a Docker Sandbox (`sbx run claude`), not directly
  on the host.

The original's technology maps to the new stack as follows: HAML → ERB; jQuery and
CoffeeScript → Stimulus and Turbo; Sidekiq → Solid Queue; Bootstrap 4 alpha → Bootstrap 5.
Where the original relies on technology with no counterpart in the new stack (e.g.
Elasticsearch search, Mailgun email, external API clients, Faker, VCR), the
replacement MUST be decided in the feature's plan, preferring what Rails and the existing stack
provide; any new gem or package needs the project owner's approval (Principle VI).

Changes to this stack MUST be approved by the project owner and recorded by amending this
constitution.

## Coding Style

The original's code is the starting point for structure and style, but it was written for
Ruby 2.4 and Rails 4.2. Where current Ruby or Rails offers a better way (e.g. the Rails
authentication generator, `normalizes`, `generates_token_for`, enums, `Time.current`, Turbo
Streams), the better way SHOULD be used. Where the original conflicts with `.rubocop.yml` or
current Rails, those win. The conventions below are kept unless a better approach applies.

- **Domain language**: use the original's names: `Book`, `WantlistItem` (Wantlist), `Exchange`
  with `initiator` and `responder`, `ExchangeBook`, `Notification`, `Feedback`, book `owner`
  and `receiver`, and the original's notification names (e.g. `book_sent`, `book_taken`,
  `exchange_confirmed`).
- **Models** hold domain logic: associations, validations, scopes, query methods and
  predicates (e.g. `confirmed?`, `in_wantlist_of?(user)`, `other_user(user)`), with
  `delegate` for attributes of associated records.
- **Service objects** in `app/services` are plain Ruby classes for side effects spanning models
  and for external API clients, named for what they do (e.g. `BookNotificationCreator` with
  `notify_sent`), taking the record in `initialize`.
- **Controllers** are thin: `before_action` guards (`require_user`, `require_owner`,
  `require_receiving_user`) backed by a shared `access_denied`, strong parameters, and flash
  messages under `:success` and `:danger` to match Bootstrap alert styles.
- **Views** use partials for repeated components, with shared partials in `app/views/shared`.
- **Acceptance tests** live in `spec/features`, one file per user story named from the user's
  point of view (e.g. `user_creates_an_exchange_spec.rb`), with scenarios that read as steps
  through small, intention-revealing helper methods (e.g. `expect_book_chosen_to_be_visible`).
  Shared helpers such as `log_in(user)` live in `spec/support`.
- **Unit tests** use `describe '#method'` / `describe '.method'`, with `let` blocks using
  named users (`alice`, `bob`) and possessive record names (`alices_book`).
- **Fabricators** exist per model, plus named fabricators for recurring personas (`:alice`,
  `:bob`).
- Names MUST use full words, not abbreviations (e.g. `button`, not `btn`).

## Development Workflow

- Features follow the Spec Kit flow: specify → clarify (as needed) → plan → tasks → implement.
- Before using a class or interface, its existing definition MUST be checked; the repository's
  current state (branches, files, config, installed packages) MUST be checked before stating it.
- Files MUST end with a newline character.
- Git commit messages MUST use conventional commit format (`type: description`).
- Code review focuses on bugs, errors, security and important issues, and MUST check behavior
  against the feature's spec, flagging any behavior added, removed or changed without approval
  (including Known Issue decisions). Harmless redundancies and zero-impact style nits are not
  raised.

## Governance

- This constitution supersedes other practices where they conflict. `AGENTS.md` provides
  day-to-day agent guidance and MUST be kept consistent with this document.
- Amendments are made through `/speckit-constitution`, require project owner approval, and MUST
  update the version and Last Amended date.
- Versioning follows semantic versioning: MAJOR for removing or redefining a principle, MINOR for
  adding a principle or section or materially expanding guidance, PATCH for clarifications and
  wording.
- Every plan MUST include a Constitution Check, and every review MUST verify compliance; any
  justified exception MUST be documented in the plan's Complexity Tracking.

**Version**: 1.1.0 | **Ratified**: 2026-10-29 | **Last Amended**: 2026-10-30
