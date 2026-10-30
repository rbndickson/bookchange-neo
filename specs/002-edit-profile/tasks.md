---

description: "Task list for Edit Profile"
---

# Tasks: Edit Profile

**Input**: Design documents from `specs/002-edit-profile/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md),
[data-model.md](./data-model.md), [contracts/routes.md](./contracts/routes.md),
[quickstart.md](./quickstart.md)

**Tests**: Required by the constitution (Principle IV): Capybara acceptance tests for every user
story in `spec/features` (Cuprite for JavaScript), RSpec model tests (shoulda-matchers where
they fit), Fabrication fabricators, no controller tests. Tests are written first and must fail
before the implementation task.

**Organization**: Tasks are grouped by user story so each story can be implemented and tested
on its own.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1 to US3)
- Paths are from the repository root

## Conventions for every task

- Follow `.rubocop.yml` (single quotes), Rails conventions and the constitution's Coding Style.
- Full words in names (`button`, not `btn`); files end with a newline.
- Messages go in `config/locales/en.yml` and are read with lazy lookup (`t('.updated')`), as in
  feature 1's controllers. Flash keys: `:success` and `:danger`.
- Reuse feature 1's pieces: `log_in(user)` in `spec/support/macros.rb`, the `:user`, `:alice`
  and `:bob` fabricators (password `password`), `shared/_field_errors`, `form_control_class`
  and the `expect_field_error(label, message)` style from `spec/features/user_signs_up_spec.rb`.
- Run commands inside the Docker Sandbox. If a command is not found, use `bash -l -c "..."`.

---

## Before Starting

The sandbox environment is already set up (feature 1). After a sandbox restart, start
PostgreSQL with `sudo service postgresql start` and check with `pg_isready`. No migration is
needed.

---

## Phase 1: Foundational (Blocking Prerequisites)

**Purpose**: `User` changes, the session token and routes that every story uses

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Password rules on update (R-001)

- [X] T001 Add tests to `spec/models/user_spec.rb`: a saved user (`alice`) loaded with `User.find` can be updated with only a new username, with no errors; for a saved user, setting `password: 'short'` gives "is too short (minimum is 8 characters)" and setting a valid `password` with no `password_confirmation` gives "can't be blank" on `password_confirmation`. Keep the existing new-user matchers (`validate_length_of(:password).is_at_least(8)`, `validate_presence_of(:password_confirmation)`) passing. Confirm the new tests fail.
- [X] T002 In `app/models/user.rb`, add `if: :password_required?` to `validates :password, length: { minimum: 8 }` and `validates :password_confirmation, presence: true`, with a private `def password_required? = new_record? || !password.nil?` (R-001); run `bundle exec rspec spec/models/user_spec.rb spec/features/user_signs_up_spec.rb` until both pass, so Sign Up's messages are unchanged

### Session token (R-004)

- [X] T003 Add tests to `spec/models/user_spec.rb`: `User.find_by_token_for(:session, alice.generate_token_for(:session))` returns `alice`; after `alice.update(password: 'newpassword', password_confirmation: 'newpassword')` the old token returns `nil` and a newly generated token returns `alice`. Confirm they fail.
- [X] T004 In `app/models/user.rb`, add `generates_token_for :session do password_salt.last(10) end` (R-004); run `spec/models/user_spec.rb` until it passes
- [X] T005 Use the token for the session: in `app/controllers/sessions_controller.rb` `create`, replace `session[:user_id] = user.id` with `session[:user_token] = user.generate_token_for(:session)` (after `reset_session`); in `app/controllers/application_controller.rb`, `current_user` becomes `@current_user ||= User.find_by_token_for(:session, session[:user_token]) if session[:user_token]` (R-004). Run `bundle exec rspec` and fix until feature 1's tests all pass unchanged.

### Routes and messages

- [X] T006 [P] In `config/routes.rb`, change `resources :users, only: [:create]` to `resources :users, only: [:create, :edit, :update]` and add `resource :password, only: [:edit, :update]` (contracts/routes.md, R-006)
- [X] T007 [P] Add to `config/locales/en.yml`: `activerecord.attributes.user.current_password: "Current Password"`; `activerecord.errors.models.user.attributes.current_password.incorrect: "is incorrect"`; `activemodel.attributes.password_change` with `current_password: "Current Password"`, `new_password: "New Password"`, `new_password_confirmation: "Confirm New Password"`; `activemodel.errors.models.password_change.attributes.current_password.incorrect: "is incorrect"` and `...new_password.password_too_long: "is too long (maximum is 72 characters)"`; `users.update.updated: "Your profile was updated."`, `users.update.rate_limited: "Try again later."`, `passwords.update.changed: "Your password was changed."`, `passwords.update.rate_limited: "Try again later."` (data-model.md, contracts Messages)

**Checkpoint**: `bundle exec rspec` passes; logging in and out works as before

---

## Phase 2: User Story 1 - Update username or email (Priority: P1) 🎯 MVP

**Goal**: Logged-in users change their username and email, with their current password, from the Update Account page in the user menu

**Independent Test**: Log in, open the user menu, click "Update Account", change the username,
click "Update" and see "Your profile was updated." and the new username in the header (spec
User Story 1)

### Tests for User Story 1

- [X] T008 [P] [US1] Add `current_password` tests to `spec/models/user_spec.rb` (on a saved `alice` loaded with `User.find`, saving with `context: :update_account`): `current_password` `nil` or `''` gives "can't be blank" only; a wrong one gives "is incorrect" only; `password` saves; it is needed even when nothing changes; other updates (no context) do not need it (spec Clarifications).
- [X] T009 [P] [US1] Write `spec/features/user_updates_account_spec.rb` (`type: :feature`) covering User Story 1 scenarios 1–11 and the spec's Edge Cases for this form: the user menu shows "Update Account" above "Log Out" (`js: true`, open the dropdown); the page shows heading "Update Account", Email and Username filled in, empty Current Password, "Update" button and "Change Password" link; username change lands on `/home` with "Your profile was updated." and the new username in the header; email change with the correct Current Password saves, and logging in with the new email works; email change with blank or wrong Current Password shows "Current Password can't be blank" or "Current Password is incorrect" and saves nothing; blank email or username shows the named error with the entered email and username kept and Current Password empty; ` Bob@Example.com ` against `bob` shows "Email cannot be used"; `Bob` against `bob` shows "Username has already been taken"; invalid email, long email, 1- or 21-character username show Sign Up's messages; after a failed save the header still shows the saved username; saving with no changes succeeds without Current Password; 10 saves then an 11th with valid details shows "Try again later." on the Update Account page and saves nothing. Confirm the tests fail.

### Implementation for User Story 1

- [X] T010 [US1] In `app/models/user.rb`, add `attr_accessor :current_password`; `validates :current_password, presence: true, on: :update_account`; `validate :current_password_correct, on: :update_account, if: -> { current_password.present? }`, with a private `current_password_correct` that does `errors.add(:current_password, :incorrect) unless authenticate(current_password)` (R-002); run `spec/models/user_spec.rb` until it passes
- [X] T011 [US1] In `app/controllers/users_controller.rb`: limit `before_action :redirect_logged_in_user_to_home_path` to `only: [:new, :create]`; add `before_action :set_user, only: [:edit, :update]`, `before_action :require_user, only: [:edit, :update]`, `before_action :require_correct_user, only: [:edit, :update]` (the original's order), then `rate_limit to: 10, within: 3.minutes, only: :update, with: -> { redirect_to edit_user_path(current_user), flash: { danger: t('users.update.rate_limited') } }` after the guards (R-007); `edit` (empty); `update` (`@user.assign_attributes(update_params)`, then `if @user.save(context: :update_account)`: `flash[:success] = t('.updated')` and `redirect_to home_path`; otherwise `render :edit, status: :unprocessable_content`); private `set_user` (`@user = User.find_by(id: params[:id])`), `require_correct_user` (`access_denied unless @user == current_user`) and `update_params` (`params.expect(user: [:email, :username, :current_password])`) (FR-003–FR-007, FR-013, FR-016, R-006)
- [X] T012 [US1] Create `app/views/users/edit.html.erb`: same layout as `app/views/users/new.html.erb` (column classes, `h3` "Update Account" and `hr`); `form_with model: @user` with `email_field :email` ("Email"), `text_field :username` ("Username") and `password_field :current_password` ("Current Password"), each with `form_control_class` and `shared/field_errors`; a "Change Password" `link_to` `edit_password_path`, and the "Update" submit as `btn btn-primary` (FR-002, R-008)
- [X] T013 [US1] In `app/views/shared/_header.html.erb`, add `<li><%= link_to "Update Account", edit_user_path(current_user), class: "dropdown-item" %></li>` above the "Log Out" item (FR-001)
- [X] T014 [US1] Run `bundle exec rspec spec/features/user_updates_account_spec.rb` and fix until all scenarios pass, except the "Change Password" link's target, which needs US2

**Checkpoint**: Users can update their username and email; User Story 1 is testable on its own

---

## Phase 3: User Story 2 - Change password (Priority: P1)

**Goal**: Logged-in users change their password on its own page, with their current password;
other browsers are logged out

**Independent Test**: Log in, open "Update Account", follow "Change Password", change the
password, log out and log in with the new password but not the old one (spec User Story 2)

### Tests for User Story 2

- [X] T015 [P] [US2] Write `spec/models/password_change_spec.rb` (`describe PasswordChange`, with `PasswordChange.new(user: alice, ...)`) for every rule in data-model.md, checking the exact message on the attribute: blank `current_password` "can't be blank"; wrong `current_password` "is incorrect"; blank `new_password` "can't be blank" and "is too short (minimum is 8 characters)", as on Sign Up; 7 characters "is too short (minimum is 8 characters)"; 73 characters and 19 four-byte emoji "is too long (maximum is 72 characters)"; mismatched confirmation "doesn't match New Password" on `new_password_confirmation`; blank confirmation "can't be blank"; and `save` returning `false` and leaving the password unchanged when invalid, `true` and changing it (`alice.reload.authenticate('newpassword')`) when valid; a new password equal to the current one is accepted. Group the `save` tests under `describe '#save'` (constitution unit test style). Confirm they fail.
- [X] T016 [P] [US2] Write `spec/features/user_changes_password_spec.rb` (`type: :feature`) covering User Story 2 scenarios 1–9: "Change Password" link on Update Account opens the page with heading "Change Password", empty Current Password, New Password and Confirm New Password, and a "Change Password" button; a valid change lands on `/home` with "Your password was changed.", still logged in; after logging out, the new password logs in and the old gives "Log in error, please try again."; with `Capybara.using_session`, a second session logged in as the same user is sent to the Log In page with "You must be logged in to do that." on its next visit to `/home` after the first session changes the password (KI-018); blank fields show "can't be blank" errors; wrong Current Password shows "Current Password is incorrect"; mismatch shows "Confirm New Password doesn't match New Password"; short and long new passwords show "New Password is too short (minimum is 8 characters)" and "New Password is too long (maximum is 72 characters)"; all fields empty after a failed save; 10 submissions then an 11th with correct details shows "Try again later." and the password is unchanged. Confirm the tests fail.

### Implementation for User Story 2

- [X] T017 [US2] Create `app/models/password_change.rb`: `class PasswordChange` with `include ActiveModel::Model`; `attr_accessor :user, :current_password, :new_password, :new_password_confirmation`; `validates :current_password, presence: true`; `validate :current_password_correct, if: -> { current_password.present? }` (`errors.add(:current_password, :incorrect) unless user.authenticate(current_password)`); `validates :new_password, presence: true, length: { minimum: 8 }, confirmation: true`; `validates :new_password_confirmation, presence: true`; a validation adding `:password_too_long` on `new_password` when `new_password.to_s.bytesize > ActiveModel::SecurePassword::MAX_PASSWORD_LENGTH_ALLOWED`; `def save = valid? && user.update(password: new_password, password_confirmation: new_password_confirmation)` (R-003); run `spec/models/password_change_spec.rb` until it passes
- [X] T018 [US2] Create `app/controllers/passwords_controller.rb`: `before_action :require_user`, then `rate_limit to: 10, within: 3.minutes, only: :update, with: -> { redirect_to edit_password_path, flash: { danger: t('passwords.update.rate_limited') } }` (R-007); `edit` (`@password_change = PasswordChange.new`); `update` (`@password_change = PasswordChange.new(password_change_params.merge(user: current_user))`; on `save`: `reset_session`, `session[:user_token] = current_user.generate_token_for(:session)`, then `flash[:success] = t('.changed')` (after the reset, R-005) and `redirect_to home_path`; otherwise `render :edit, status: :unprocessable_content`); private `password_change_params` (`params.expect(password_change: [:current_password, :new_password, :new_password_confirmation])`) (FR-009–FR-013, R-004, R-006)
- [X] T019 [US2] Create `app/views/passwords/edit.html.erb`: same layout as `app/views/users/new.html.erb`, `h3` "Change Password" and `hr`; `form_with model: @password_change, url: password_path, method: :patch` with `password_field :current_password` ("Current Password"), `password_field :new_password` ("New Password") and `password_field :new_password_confirmation` ("Confirm New Password"), each with `form_control_class` and `shared/field_errors`; submit "Change Password" as `btn btn-primary` (FR-008, R-008)
- [X] T020 [US2] Run `bundle exec rspec spec/features/user_changes_password_spec.rb spec/features/user_updates_account_spec.rb` and fix until all pass, including US1's "Change Password" link

**Checkpoint**: User Stories 1 and 2 work; users can update their account and password

---

## Phase 4: User Story 3 - Only the owner can update an account (Priority: P1)

**Goal**: Visitors are sent to log in, and users cannot view or change another account

**Independent Test**: Logged out, visit a user's Update Account address and see the Log In
page; logged in as another user, see the home page with "You do not have access." (spec User
Story 3)

### Tests for User Story 3

- [X] T021 [US3] Write `spec/features/user_cannot_change_another_account_spec.rb` (`type: :feature`) covering User Story 3 scenarios 1–3. Users routes: a visitor visiting `edit_user_path(alice)` sees the Log In page and "You must be logged in to do that."; `bob` visiting `edit_user_path(alice)` sees the home page and "You do not have access."; `bob` visiting `edit_user_path(id: 0)` (no such account) sees the same. For submitting to another account (scenario 2), use `page.driver.submit :patch, user_path(alice), user: { username: 'taken' }` (Rack::Test) while logged in as `bob`, then check "You do not have access." and that `alice.reload.username` is unchanged; as a visitor, the same request shows "You must be logged in to do that." Password routes: a visitor visiting `edit_password_path`, or submitting `page.driver.submit :patch, password_path, {}`, sees the Log In page and "You must be logged in to do that." Confirm the tests fail only where a guard is missing (the guards are built in T011 and T018).

### Implementation for User Story 3

- [X] T022 [US3] Run `bundle exec rspec spec/features/user_cannot_change_another_account_spec.rb` and fix the guards in `app/controllers/users_controller.rb` and `app/controllers/passwords_controller.rb` until all pass (FR-015, FR-016)

**Checkpoint**: All user stories work independently

---

## Phase 5: Polish & Cross-Cutting Concerns

**Purpose**: Responsive check, quality and security gates (Principle V) and final checks

- [X] T023 Check the Update Account and Change Password pages, and the user menu, at 375 px wide with Cuprite (resize the window in a `js: true` example or by hand): no horizontal scrolling; adjust Bootstrap classes in `app/views/users/edit.html.erb` and `app/views/passwords/edit.html.erb` if needed (FR-017, SC-006)
- [X] T024 Run `bundle exec rspec` (the full suite in `spec/`) and fix any failures
- [X] T025 [P] Run `bundle exec rubocop` (rules in `.rubocop.yml`) and fix offenses in `app/`, `config/` and `spec/` (`bundle exec rubocop -a` for safe fixes)
- [X] T026 [P] Run `yarn lint:js` and `yarn format:js` on `app/javascript` (no JavaScript changes expected)
- [X] T027 [P] Run `yarn lint:erb` and `yarn format:erb`, and fix any issues in `app/views`
- [X] T028 [P] Run `bin/brakeman --no-pager` and `bin/bundler-audit`; fix any warnings, or record the project owner's accepted reason in `config/brakeman.ignore` (Principle V)
- [X] T029 Walk through quickstart.md's Manual walkthrough (steps 1–15) with `bin/dev` and record any differences from the spec
- [X] T030 Update feature 2's Status in `.specify/memory/roadmap.md` to "In progress" when implementation starts and "Done" when T024–T029 pass

---

## Phase 6: Changes After Review

**Purpose**: Changes the project owner asked for after implementation (spec Clarifications).
They supersede the parts of T002, T008, T010, T011 and T015–T019 they change.

- [X] T031 Require Current Password on every Update Account save: `current_password` validations `on: :update_account`, saved with `@user.save(context: :update_account)` in `app/controllers/users_controller.rb`; update `spec/models/user_spec.rb` and `spec/features/user_updates_account_spec.rb` (KI-017, FR-005, R-002)
- [X] T032 Remove the `PasswordChange` form object (`app/models/password_change.rb`, `spec/models/password_change_spec.rb`): `app/controllers/passwords_controller.rb` saves `current_user` with `save(context: :change_password)`; `app/models/user.rb` requires `password` and checks `current_password` against `password_digest_was` in that context; `app/views/passwords/edit.html.erb` uses "Password" and "Confirm Password"; tests in `spec/models/user_spec.rb` and `spec/features/user_changes_password_spec.rb` (FR-008, FR-009, R-003)
- [X] T033 Show "The passwords do not match" without a field name on Sign Up and Change Password: `config.active_model.i18n_customize_full_message = true` in `config/application.rb`; `format: "%{message}"`, `blank` and `confirmation` messages for `password_confirmation` in `config/locales/en.yml`; update `spec/features/user_signs_up_spec.rb` and feature 1's spec (KI-014, R-003)
- [X] T034 Replace `password_required?` in `app/models/user.rb` with `on: [:create, :change_password]` on the password length and Confirm Password presence rules; move the saved-user length and confirmation tests in `spec/models/user_spec.rb` into the changing-the-password tests (R-001). Supersedes T002.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Foundational (Phase 1)**: No dependencies; blocks all user stories
- **User Stories (Phases 2–4)**: Need Foundational
- **Polish (Phase 5)**: Needs all user stories

### User Story Dependencies

- **US1 Update username or email (P1)**: Needs Foundational only, except the "Change Password"
  link's target, which passes once US2 is built (checked in T020)
- **US2 Change password (P1)**: Needs Foundational; its tests reach the page through the Update
  Account link, so they need US1's page (T012) and header item (T013)
- **US3 Only the owner (P1)**: Needs US1 (users guards, T011) and US2 (passwords guard, T018);
  it adds the tests that prove them

### Within Each User Story

- Tests are written first and must fail
- Model before controller, controller before view, then the full test run
- Story complete before moving to the next

### Parallel Opportunities

- Foundational: T006 and T007 together, alongside T001–T005
- US1: T008 and T009 together
- US2: T015 and T016 together
- Polish: T025–T028 together

---

## Parallel Example: User Story 1

```bash
# Tests first:
Task: "current_password tests in spec/models/user_spec.rb (T008)"
Task: "spec/features/user_updates_account_spec.rb (T009)"
```

## Parallel Example: User Story 2

```bash
# Tests first:
Task: "spec/models/password_change_spec.rb (T015)"
Task: "spec/features/user_changes_password_spec.rb (T016)"
```

---

## Implementation Strategy

### MVP First (User Story 1)

1. Phase 1: Foundational
2. Phase 2: User Story 1 (update username or email)
3. **Stop and validate**: Update Account works on its own

### Incremental Delivery

1. Foundational → password rules fixed, session token in place, routes and messages ready
2. US1 → users can update their username and email
3. US2 → users can change their password; other sessions are logged out
4. US3 → access rules proven by tests
5. Polish → responsive check, all CI checks pass, roadmap updated

---

## Notes

- [P] tasks = different files, no dependencies on incomplete tasks
- Commit after each phase with a conventional commit message (e.g. `feat: add update account`)
- Do not add gems or packages; raise any need with the project owner (Principle VI)
- Original behavior differences are only those in the spec's Differences from the Original
  (KI-016 to KI-019) and Clarifications; anything else found during implementation is raised
  with the project owner, not changed silently
