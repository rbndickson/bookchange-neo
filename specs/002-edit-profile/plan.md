# Implementation Plan: Edit Profile

**Branch**: `feature/002-edit-profile` | **Date**: 2026-10-30 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `specs/002-edit-profile/spec.md`

## Summary

Logged-in users change their email and username on an Update Account page, reached from the
header's user menu, and their password on a separate Change Password page linked from it. The
Update Account part mirrors the original: `UsersController#edit/update` at `/users/:id/edit`
with `set_user`, `require_user` and `require_correct_user`. The approved fixes add a Current
Password check on every Update Account save and password change (a `User` virtual attribute and
validation contexts), `PasswordsController` for the new page, which saves through `User`, rate limits on both forms, and logging out
other sessions on a password change by storing a `generates_token_for` session token, based on
the password salt, in place of the user id. `User`'s password rules are adjusted so a user can
be saved without a new password. See [research.md](./research.md).

## Technical Context

**Language/Version**: Ruby 4.0.9, Rails 8.1

**Primary Dependencies**: Rails (`has_secure_password`, `generates_token_for`, `rate_limit`,
`ActiveModel::Model`), bcrypt, Turbo, Bootstrap 5 with Bootstrap Icons (all already installed)

**Storage**: PostgreSQL (`users` table, unchanged); Rails cookie session holding a signed
session token; cache store for rate limit counts

**Testing**: RSpec with Fabrication and shoulda-matchers; Capybara acceptance tests with
Rack::Test, and Cuprite for JavaScript scenarios

**Target Platform**: Linux server; modern browsers on phone, tablet and desktop

**Project Type**: Server-rendered Rails web application

**Performance Goals**: Standard web expectations; a username change in under 1 minute
(SC-001)

**Constraints**: No new gems or packages; no migration; no JavaScript beyond Bootstrap's
existing data attributes; pages usable at 375 px wide (SC-006)

**Scale/Scope**: 1 changed model, 1 changed and 1 new controller, 2 new
pages, header and session changes

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Check | Status |
|---|---|---|
| I. Faithful Rebuild | Spec states the original behavior reproduced; all differences are approved in the spec's Differences from the Original (KI-016 to KI-019) and Clarifications. Update Account keeps the original's route, guards, labels and messages. | Pass |
| II. Double Opt-In Integrity | No exchange behavior. Access checks on the server: `require_user` on both controllers and `require_correct_user` on Update Account; Change Password only acts on `current_user`. | Pass |
| III. Rails Conventions & Hotwire | RESTful `users#edit/update` and singular `resource :password`; ERB views; Turbo forms with `422` on invalid saves; `generates_token_for` and `rate_limit` from Rails. No Stimulus controller needed. | Pass |
| IV. Tested Behavior | Acceptance tests per user story in `spec/features`, including two browser sessions for KI-018; `User` model specs; no controller tests; no external services. | Pass |
| V. Quality & Security Gates | RuboCop, oxlint/oxfmt, Herb, Brakeman and bundler-audit before completion. Security fixes KI-017 and KI-018 in the design. | Pass |
| VI. Scope Discipline & Simplicity | No new gems or packages, no migration. Change Password saves through `User` rather than a separate form object (R-003). Later features' menu entries left out. | Pass |
| Coding Style | Original's names (`set_user`, `require_correct_user`, `access_denied`); flash `:success` and `:danger`; `generates_token_for` per "better way". | Pass |

**Post-design re-check (after Phase 1)**: Pass. The data model, routes contract and quickstart
add no dependencies. One change touches feature 1's code with no visible change: the session
holds a token instead of the user id (R-004), so log in and `current_user` change.

## Project Structure

### Documentation (this feature)

```text
specs/002-edit-profile/
├── plan.md              # This file
├── research.md          # Phase 0: decisions R-001 to R-008
├── data-model.md        # Phase 1: User changes
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
│   ├── application_controller.rb   # current_user from the session token (R-004)
│   ├── passwords_controller.rb     # new: edit, update (rate limited)
│   ├── sessions_controller.rb      # create stores the session token (R-004)
│   └── users_controller.rb         # add edit, update (rate limited), set_user,
│                                   # require_correct_user
├── models/
│   └── user.rb                     # password_required?, current_password, validation
│                                   # contexts, generates_token_for :session
└── views/
    ├── passwords/
    │   └── edit.html.erb           # new: Change Password
    ├── shared/
    │   └── _header.html.erb        # "Update Account" menu item
    └── users/
        └── edit.html.erb           # new: Update Account

config/
├── application.rb                  # i18n_customize_full_message (R-003)
├── locales/en.yml                  # field names and messages
└── routes.rb                       # users edit/update, resource :password

spec/
├── features/
│   ├── user_updates_account_spec.rb    # User Story 1
│   ├── user_changes_password_spec.rb   # User Story 2 (two sessions for KI-018)
│   └── user_cannot_change_another_account_spec.rb  # User Story 3
└── models/
    └── user_spec.rb                    # password rules on update, current_password,
                                        # changing the password, session token
```

**Structure Decision**: The standard Rails application layout already in the repository.
Acceptance test file names follow feature 1's (`user_signs_up_spec.rb`), named for the spec's
user stories. The original's `users/_form` partial is not used: Sign Up and Update Account no
longer share their password fields (R-008).

## Implementation Notes

- **Feature 1 tests**: the `User` model specs for password length and confirmation presence
  need to reflect R-001 (rules apply to new users and when a password is set). Feature 1's
  acceptance tests should pass unchanged.
- **Session token**: `log_in` in `spec/support/macros.rb` logs in through the form, so it needs
  no change.
- **Roadmap**: set feature 2 to "Planned" now, "Tasks ready" after `/speckit-tasks`.

## Complexity Tracking

No constitution violations to justify.
