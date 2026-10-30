# Implementation Plan: Sign Up, Log In and Log Out

**Branch**: `feature/001-sign-up-log-in` | **Date**: 2026-10-30 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/001-sign-up-log-in/spec.md`

## Summary

Visitors sign up with an email, username and password, log in with their email and password,
and log out from a user menu in the header; a simple front page is the root page and a
temporary home page is shown after log in. The design mirrors the original: the user's id in
the Rails cookie session, with `current_user`, `require_user` and `access_denied` in
`ApplicationController`, `UsersController#new/create`, `SessionsController` and
`PagesController#front/home`. Modern Rails provides the approved fixes: `normalizes` for
emails, `authenticate_by` for even timing, `rate_limit` for log in attempts, `reset_session`
on log in and log out, and a `DELETE` log out button. Passwords use `has_secure_password` with
bcrypt. See [research.md](./research.md).

## Technical Context

**Language/Version**: Ruby 4.0.9, Rails 8.1

**Primary Dependencies**: Rails (`has_secure_password`, `normalizes`, `authenticate_by`,
`rate_limit`), bcrypt (owner to uncomment in `Gemfile`, R-001), Turbo, Bootstrap 5 with
Popper and Bootstrap Icons (already installed)

**Storage**: PostgreSQL (`users` table); Rails cookie session for log in state; cache store
for rate limit counts (Solid Cache in production)

**Testing**: RSpec with Fabrication; Capybara acceptance tests with Rack::Test, and Cuprite
(headless Chromium) for JavaScript scenarios

**Target Platform**: Linux server; modern browsers (`allow_browser versions: :modern`) on
phone, tablet and desktop

**Project Type**: Server-rendered Rails web application

**Performance Goals**: Standard web expectations; sign up to logged in in under 2 minutes for
a user (SC-001)

**Constraints**: No new gems or packages beyond bcrypt (approved); no JavaScript beyond
Bootstrap's existing data attributes; pages usable at 375 px wide (SC-005)

**Scale/Scope**: Demo application; 1 model, 3 controllers, 5 pages and partials, 1 migration

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Check | Status |
|---|---|---|
| I. Faithful Rebuild | Spec states the original behavior reproduced; all differences are approved in the spec's Differences from the Original (KI-001 to KI-013). Plan follows the original's routes, controllers, messages and session approach. | Pass |
| II. Double Opt-In Integrity | No exchange behavior in this feature. Access checks start here: `require_user` and `access_denied` on the home page; logged-in users redirected away from Sign Up and Log In. | Pass |
| III. Rails Conventions & Hotwire | RESTful `users#create`, conventional controllers, ERB views, Bootstrap 5 and Bootstrap Icons. Turbo handles forms (422 on invalid sign up). No JavaScript framework; no Stimulus controller needed. | Pass |
| IV. Tested Behavior | Acceptance tests per user story in `spec/features` (Cuprite for the dropdown and closing messages); `User` model specs; fabricators `:user`, `:alice`, `:bob`; no controller tests; no external services. | Pass |
| V. Quality & Security Gates | RuboCop, oxlint/oxfmt, Herb, Brakeman and bundler-audit run before completion. Security fixes KI-002, KI-006, KI-007, KI-008 in the design. | Pass |
| VI. Scope Discipline & Simplicity | bcrypt approved by the owner (R-001). Chromium is a sandbox system package, not a `Gemfile` or `package.json` change (R-003). Hand-written sessions chosen over the generator as the simpler fit (R-002). Later features' header links and pages left out. | Pass |
| Coding Style | Original's names (`current_user`, `require_user`, `access_denied`, `log_in` helper, `:alice`/`:bob`); `normalizes` and `authenticate_by` per "better way"; flash keys `:success` and `:danger`, plus `:info` for log out as in the original (spec FR-019). | Pass |

**Post-design re-check (after Phase 1)**: Pass. The data model, routes contract and quickstart
add no new dependencies or patterns. One environment change is needed: the test cache store
becomes `:memory_store` so rate limits can be tested (R-005).

## Project Structure

### Documentation (this feature)

```text
specs/001-sign-up-log-in/
├── plan.md              # This file
├── research.md          # Phase 0: decisions R-001 to R-012
├── data-model.md        # Phase 1: User fields, indexes and validations
├── quickstart.md        # Phase 1: how to check the feature works
├── contracts/
│   └── routes.md        # Phase 1: routes, requests, responses and messages
├── checklists/
│   └── requirements.md  # Spec quality checklist
└── tasks.md             # Phase 2 (/speckit-tasks, not created here)
```

### Source Code (repository root)

```text
app/
├── controllers/
│   ├── application_controller.rb   # current_user, logged_in?, require_user, access_denied,
│   │                               # redirect for logged-in users
│   ├── pages_controller.rb         # front, home
│   ├── sessions_controller.rb      # new, create (rate limited), destroy
│   └── users_controller.rb         # new, create
├── helpers/
│   └── application_helper.rb       # form field error helper (if needed by the partial)
├── models/
│   └── user.rb                     # has_secure_password, normalizes, validations
└── views/
    ├── layouts/
    │   └── application.html.erb    # header, messages, container
    ├── pages/
    │   ├── front.html.erb
    │   └── home.html.erb           # temporary: username (replaced in feature 3)
    ├── sessions/
    │   └── new.html.erb
    ├── shared/
    │   ├── _field_errors.html.erb  # invalid-feedback messages for a field (R-009)
    │   ├── _header.html.erb
    │   └── _messages.html.erb
    └── users/
        └── new.html.erb

config/
├── application.rb                  # field_error_proc (R-009)
├── environments/test.rb            # cache_store :memory_store (R-005)
├── locales/en.yml                  # password_too_long message (R-008)
└── routes.rb

db/
└── migrate/<timestamp>_create_users.rb

spec/
├── fabricators/
│   ├── alice_fabricator.rb
│   ├── bob_fabricator.rb
│   └── user_fabricator.rb
├── features/
│   ├── user_signs_up_spec.rb        # User Story 1
│   ├── user_logs_in_spec.rb         # User Story 2
│   ├── user_logs_out_spec.rb        # User Story 3 (js: true)
│   └── visitor_views_front_page_spec.rb  # User Story 4 (closing messages js: true)
├── models/
│   └── user_spec.rb
├── support/
│   ├── capybara.rb                  # Rack::Test default, Cuprite for js: true
│   ├── cache.rb                     # Rails.cache.clear before each example
│   └── macros.rb                    # log_in(user)
└── rails_helper.rb                  # load spec/support
```

**Structure Decision**: The standard Rails application layout already in the repository. The
original's `users/_form` partial is not needed yet (only Sign Up uses the form until feature
2 adds Edit Profile). Acceptance test file names follow the original's
(`user_registers_spec.rb`, `user_signs_in_spec.rb`), renamed to match the spec's wording.

## Implementation Notes

- **Environment first**: install Ruby 4.0.9 and Chromium in the sandbox, then the README's
  Installation steps; confirm bcrypt is uncommented before `bundle install` (quickstart
  Prerequisites).
- **`rails_helper.rb`**: uncomment the `spec/support` loader line.
- **`hello_controller.js`**: Rails' example Stimulus controller is left alone; removing it is
  outside this feature's scope.
- **Roadmap**: set feature 1 to "Planned" now, "Tasks ready" after `/speckit-tasks`.

## Complexity Tracking

No constitution violations to justify.
