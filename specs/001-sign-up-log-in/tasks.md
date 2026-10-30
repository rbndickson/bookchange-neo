---

description: "Task list for Sign Up, Log In and Log Out"
---

# Tasks: Sign Up, Log In and Log Out

**Input**: Design documents from `specs/001-sign-up-log-in/`

**Prerequisites**: [plan.md](./plan.md), [spec.md](./spec.md), [research.md](./research.md),
[data-model.md](./data-model.md), [contracts/routes.md](./contracts/routes.md),
[quickstart.md](./quickstart.md)

**Tests**: Required by the constitution (Principle IV): Capybara acceptance tests for every user
story in `spec/features` (Cuprite for JavaScript), RSpec model tests, Fabrication fabricators, no
controller tests. Tests are written first and must fail before the implementation task.

**Organization**: Tasks are grouped by user story so each story can be implemented and tested
on its own.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (US1 to US4)
- Paths are from the repository root

## Conventions for every task

- Follow `.rubocop.yml` (single quotes), Rails conventions and the constitution's Coding Style.
- Full words in names (`button`, not `btn`); files end with a newline.
- Flash keys: `:success`, `:danger`, and `:info` only for "You have logged out."
- Run commands inside the Docker Sandbox. If a command is not found, use `bash -l -c "..."`.

---

## Before Starting

The sandbox environment was set up on 2026-10-30, outside this task list: Ruby 4.0.9, Yarn,
PostgreSQL, Chromium (for Cuprite), gems, JavaScript packages, built assets and the development
and test databases. After a sandbox restart, start PostgreSQL with `sudo service postgresql
start` and check with `pg_isready`.

---

## Phase 1: Foundational (Blocking Prerequisites)

**Purpose**: The `User` model, test setup, shared layout, routes and access helpers that every
story uses

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Test setup

- [ ] T001 Uncomment the `spec/support` loader line (`Rails.root.glob('spec/support/**/*.rb')...`) in `spec/rails_helper.rb`
- [ ] T002 [P] Create `spec/support/capybara.rb`: Rack::Test as `Capybara.default_driver`; register a `:cuprite` driver (`Capybara::Cuprite::Driver.new(app, window_size: [1200, 800], browser_options: { 'no-sandbox': nil })`) as `Capybara.javascript_driver`; tag `type: :feature` examples with `js: true` to use it (R-003, R-012)
- [ ] T003 [P] Create `spec/support/cache.rb` that runs `Rails.cache.clear` before each example, so rate limit counts do not leak between tests (R-005)
- [ ] T004 [P] Create `spec/support/macros.rb` with `log_in(user = nil)`: fabricate a user if none given, visit `login_path`, fill in 'Email' and 'Password' (the fabricated password `password`), click 'Log In' (as the original's macro)
- [ ] T005 [P] Change `config.cache_store = :null_store` to `config.cache_store = :memory_store` in `config/environments/test.rb`, with a comment that rate limits need a counting store (R-005)

### User model

- [ ] T006 Generate the migration `db/migrate/<timestamp>_create_users.rb`: `users` table with `email` string `null: false`, `username` string `null: false`, `password_digest` string `null: false`, timestamps; unique index on `email`; unique index on `'lower(username)'` named `index_users_on_lower_username`; run `bin/rails db:migrate` and commit the updated `db/schema.rb` (data-model.md)
- [ ] T007 [P] Create fabricators: `spec/fabricators/user_fabricator.rb` (`sequence(:email) { |number| "user#{number}@example.com" }`, `sequence(:username) { |number| "user#{number}" }`, `password 'password'`, `password_confirmation 'password'`), `spec/fabricators/alice_fabricator.rb` (`Fabricator(:alice, from: :user)` with email `alice@example.com`, username `alice`) and `spec/fabricators/bob_fabricator.rb` (email `bob@example.com`, username `bob`)
- [ ] T008 Write model tests in `spec/models/user_spec.rb` (`describe User`, named users `alice`/`bob`) for every rule in data-model.md, checking the exact message on the attribute: email "can't be blank"; email `alice` "is invalid"; email over 254 characters "is too long (maximum is 254 characters)"; duplicate email (including ` Alice@Example.com ` against `alice@example.com`) "This email cannot be used"; email saved as `alice@example.com` from ` Alice@Example.com `; username "can't be blank"; username of 1 character "is too short (minimum is 2 characters)"; 21 characters "is too long (maximum is 20 characters)"; `Alice` against `alice` "has already been taken"; username kept as typed (`Alice`); password "can't be blank"; 7 characters "is too short (minimum is 8 characters)"; 73 characters and 19 four-byte emoji "is too long (maximum is 72 characters)"; 72 ASCII characters valid; confirmation mismatch "doesn't match Password" on `password_confirmation`; blank confirmation "can't be blank"; plus `.authenticate_by` finding `alice` with ` ALICE@example.com ` and returning `nil` for a wrong password or unknown email. Confirm they fail.
- [ ] T009 Create `app/models/user.rb` to pass T008: `has_secure_password`; `normalizes :email, with: ->(email) { email.strip.downcase }`; `validates :email, presence: true`, `length: { maximum: 254, allow_blank: true }`, `format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }`, `uniqueness: { message: 'This email cannot be used' }`; `validates :username, presence: true, length: { in: 2..20, allow_blank: true }, uniqueness: { case_sensitive: false }`; `validates :password, length: { minimum: 8 }` (no presence validation, `has_secure_password` adds it); `validates :password_confirmation, presence: true` (R-006, R-008)
- [ ] T010 [P] Add the password length message to `config/locales/en.yml`: `en.activerecord.errors.models.user.attributes.password.password_too_long: "is too long (maximum is 72 characters)"` (R-008); rerun `spec/models/user_spec.rb` until it passes

### Shared layout, routes and access

- [ ] T011 Write `config/routes.rb` per contracts/routes.md, keeping the health check: `root 'pages#front'`; `get 'home', to: 'pages#home'`; `get 'signup', to: 'users#new'`; `resources :users, only: [:create]`; `get 'login', to: 'sessions#new'`; `post 'login', to: 'sessions#create'`; `delete 'logout', to: 'sessions#destroy'`
- [ ] T012 Add to `app/controllers/application_controller.rb` (keep `allow_browser`): `helper_method :current_user, :logged_in?`; `current_user` (`@current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]`); `logged_in?`; `require_user` (`access_denied unless logged_in?`); `access_denied` (logged in: `flash[:danger] = 'You do not have access.'` and redirect to `home_path`; otherwise `flash[:danger] = 'You must be logged in to do that.'` and redirect to `login_path`, as in the original); `redirect_logged_in_user` (`redirect_to home_path if logged_in?`) for Sign Up and Log In (FR-011, FR-014, R-002)
- [ ] T013 [P] Set `config.action_view.field_error_proc = proc { |html_tag, _instance| html_tag }` in `config/application.rb`, so Rails does not wrap invalid fields in `field_with_errors` (R-009)
- [ ] T014 [P] Create `app/views/shared/_messages.html.erb`: for each flash, a `div.alert.alert-<name>.alert-dismissible.fade.show` with `role="alert"`, the message, and a `button.btn-close` with `data-bs-dismiss="alert"` and `aria-label="Close"` (FR-019, R-011)
- [ ] T015 [P] Create `app/views/shared/_header.html.erb`: a responsive Bootstrap 5 navbar. Brand: `bi bi-book` icon and "Bookchange", linking to `home_path` when `logged_in?`, otherwise `root_path`. Visitor: "Sign Up" (`signup_path`) and "Log In" (`login_path`) as `btn btn-outline-primary` links. Logged in: a dropdown button (`bi bi-person` icon and `current_user.username`, `data-bs-toggle="dropdown"`) whose menu contains `button_to 'Log Out', logout_path, method: :delete, class: 'dropdown-item'` (FR-017, FR-018, R-010, R-011). Leave out later features' links (spec Assumptions).
- [ ] T016 Update `app/views/layouts/application.html.erb`: keep `<title>` as "Bookchange" (FR-021), render `shared/header` and `shared/messages` in the body, and wrap `yield` in a `main.container` (depends on T014, T015)
- [ ] T017 Create `app/controllers/pages_controller.rb` (`before_action :require_user, except: :front`; empty `front` and `home` actions), `app/views/pages/front.html.erb` (centred section with `h1` "Exchange books you have read for something new.", `p.lead` "Save space in your home and help the environment without giving up paper books." and a large "Sign Up" `btn btn-primary` link to `signup_path`; FR-015) and `app/views/pages/home.html.erb` (temporary: `h2` "Username: <username>"; FR-016)

**Checkpoint**: `bundle exec rspec spec/models` passes; `/` shows the front page and header

---

## Phase 2: User Story 1 - Sign up (Priority: P1) 🎯 MVP

**Goal**: Visitors create an account and are sent to Log In with "You have joined Bookchange,
you can now log in."

**Independent Test**: From the front page, follow "Sign Up", complete the form and see the
message on the Log In page (spec User Story 1)

### Tests for User Story 1

- [ ] T018 [US1] Write `spec/features/user_signs_up_spec.rb` (`type: :feature`) covering User Story 1 scenarios 1–14 with intention-revealing helpers (e.g. `fill_in_sign_up_form(email:, username:, password:, confirmation:)`, `expect_field_error(label, message)`): Sign Up from the header and from the front page button; valid sign up lands on Log In with "You have joined Bookchange, you can now log in." and creates the user without logging in; blank fields show "can't be blank" with email and username kept and password fields empty; mismatch "doesn't match Password"; short password; duplicate email "This email cannot be used" (including ` Alice@Example.com `); duplicate username "has already been taken" (including `Alice` against `alice`); email `alice` "is invalid"; password over 72 characters "is too long (maximum is 72 characters)"; email over 254 or username over 20 characters "is too long"; username of 1 character "is too short (minimum is 2 characters)"; logged-in user visiting `/signup` lands on the home page (use `log_in`; passes once US2 is built). Confirm the tests fail.

### Implementation for User Story 1

- [ ] T019 [P] [US1] Create `app/views/shared/_field_errors.html.erb` taking `record` and `attribute` locals: when `record.errors[attribute]` is present, a `div.invalid-feedback.d-block` with the messages joined by ", " (R-009)
- [ ] T020 [US1] Create `app/controllers/users_controller.rb`: `before_action :redirect_logged_in_user`; `new` (`@user = User.new`); `create` (on save: `flash[:success] = 'You have joined Bookchange, you can now log in.'` and `redirect_to login_path`; otherwise `render :new, status: :unprocessable_content`); private `user_params` permitting `:email, :username, :password, :password_confirmation` with `params.expect(user: [...])` (FR-001–FR-007, FR-011, contracts POST `/users`)
- [ ] T021 [US1] Create `app/views/users/new.html.erb`: centred column (`col-12 col-md-10 col-lg-8 col-xl-6`, as the original), `h3` "Sign Up" and `hr`, `form_with model: @user` with Bootstrap rows for `email_field :email` (label "Email"), `text_field :username` ("Username"), `password_field :password` ("Password"), `password_field :password_confirmation` (label "Confirm Password"); add `is-invalid` to each field with errors and render `shared/field_errors` below it; submit "Sign Up" as `btn btn-primary` (depends on T019)
- [ ] T022 [US1] Run `bundle exec rspec spec/features/user_signs_up_spec.rb` and fix until all scenarios pass, except the logged-in redirect scenario, which needs US2

**Checkpoint**: Visitors can sign up; User Story 1 is testable on its own

---

## Phase 3: User Story 2 - Log in (Priority: P1)

**Goal**: Users log in with email and password and land on the home page; failures show one
generic message; attempts are rate limited

**Independent Test**: With a fabricated user, follow "Log In", enter the details and see the
home page with the username in the header (spec User Story 2)

### Tests for User Story 2

- [ ] T023 [US2] Write `spec/features/user_logs_in_spec.rb` (`type: :feature`) covering User Story 2 scenarios 1–8: Log In from the header; correct details land on the home page with the username in the header and "Username: alice"; wrong password and unknown email both show "Log in error, please try again." on the Log In page; logged-in user visiting `/login` lands on the home page; visitor visiting `/home` sees the Log In page and "You must be logged in to do that."; ` Alice@Example.com ` logs in `alice@example.com`; after 10 attempts, an 11th with correct details shows "Try again later." and does not log in. Confirm the tests fail.

### Implementation for User Story 2

- [ ] T024 [US2] Create `app/controllers/sessions_controller.rb` with `new` and `create`: `rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to login_path, flash: { danger: 'Try again later.' } }` (FR-010a, R-005); `before_action :redirect_logged_in_user, only: [:new, :create]`; `create` uses `User.authenticate_by(email: params[:email], password: params[:password])` (R-004); on success `reset_session`, `session[:user_id] = user.id`, `redirect_to home_path` with no flash (FR-009, FR-012a, R-007); on failure `flash[:danger] = 'Log in error, please try again.'` and `redirect_to login_path` (FR-010)
- [ ] T025 [US2] Create `app/views/sessions/new.html.erb`: same column layout as Sign Up, `h3` "Log In" and `hr`, `form_with url: login_path` with `email_field :email` (label "Email") and `password_field :password` ("Password"), submit "Log In" as `btn btn-primary`; leave out the original's "Forgot password?" link (feature 14)
- [ ] T026 [US2] Run `bundle exec rspec spec/features/user_logs_in_spec.rb spec/features/user_signs_up_spec.rb` and fix until all pass, including US1's logged-in redirect scenario

**Checkpoint**: User Stories 1 and 2 work; users can sign up and log in

---

## Phase 4: User Story 3 - Log out (Priority: P2)

**Goal**: Logged-in users log out from the user menu and return to the front page

**Independent Test**: Log in, open the user menu, click "Log Out" and see the front page with
"You have logged out." (spec User Story 3)

### Tests for User Story 3

- [ ] T027 [US3] Write `spec/features/user_logs_out_spec.rb` (`type: :feature`, `js: true` for the dropdown) covering User Story 3 scenarios 1–3: the user menu shows the username and "Log Out"; clicking it shows the front page, "You have logged out." and the "Sign Up" and "Log In" header buttons; visiting `/home` afterwards shows the Log In page and "You must be logged in to do that." Confirm the tests fail.

### Implementation for User Story 3

- [ ] T028 [US3] Add `destroy` to `app/controllers/sessions_controller.rb`: `reset_session`, then `flash[:info] = 'You have logged out.'` (after the reset, or the flash is lost; R-007), `redirect_to root_path` (FR-013, FR-012a); no `redirect_logged_in_user` or `require_user` on `destroy`
- [ ] T029 [US3] Run `bundle exec rspec spec/features/user_logs_out_spec.rb` and fix until it passes

**Checkpoint**: Users can sign up, log in and log out

---

## Phase 5: User Story 4 - Front page and header (Priority: P2)

**Goal**: The front page and header show the right content for visitors and logged-in users;
messages can be closed

**Independent Test**: Visit `/` logged out and logged in and check the front page and header
for each (spec User Story 4)

### Tests for User Story 4

- [ ] T030 [US4] Write `spec/features/visitor_views_front_page_spec.rb` (`type: :feature`) covering User Story 4 scenarios 1–4: front page heading, lead text and "Sign Up" button; visitor header brand links to `/` with "Sign Up" and "Log In"; logged-in header brand links to `/home` with the username menu containing "Log Out"; closing a message with its close button removes it (`js: true`); page title is "Bookchange"

### Implementation for User Story 4

- [ ] T031 [US4] Run `bundle exec rspec spec/features/visitor_views_front_page_spec.rb` and fix `app/views/shared/_header.html.erb`, `app/views/shared/_messages.html.erb` or `app/views/pages/front.html.erb` until it passes
- [ ] T032 [US4] Check every page in this feature at 375 px wide with Cuprite (resize the window in a `js: true` example or by hand): no horizontal scrolling and the user menu usable; adjust Bootstrap classes in `app/views/shared/_header.html.erb` and the page views if needed (FR-020, SC-005)

**Checkpoint**: All user stories work independently

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Quality and security gates (Principle V) and final checks

- [ ] T033 Run `bundle exec rspec` (the full suite in `spec/`) and fix any failures
- [ ] T034 [P] Run `bundle exec rubocop` (rules in `.rubocop.yml`) and fix offenses in `app/`, `config/`, `db/migrate/` and `spec/` (`bundle exec rubocop -a` for safe fixes)
- [ ] T035 [P] Run `yarn lint:js` and `yarn format:js` on `app/javascript` (no JavaScript changes expected)
- [ ] T036 [P] Run `yarn lint:erb` and `yarn format:erb`, and fix any issues in `app/views`
- [ ] T037 [P] Run `bin/brakeman --no-pager` and `bin/bundler-audit`; fix any warnings, or record the project owner's accepted reason in `config/brakeman.ignore` (Principle V)
- [ ] T038 Walk through quickstart.md's Manual walkthrough (steps 1–12) with `bin/dev` and record any differences from the spec
- [ ] T039 Update feature 1's Status in `.specify/memory/roadmap.md` to "In progress" when implementation starts and "Done" when T033–T038 pass

---

## Dependencies & Execution Order

### Phase Dependencies

- **Foundational (Phase 1)**: No dependencies; blocks all user stories
- **User Stories (Phases 2–5)**: Need Foundational
- **Polish (Phase 6)**: Needs all user stories

### User Story Dependencies

- **US1 Sign up (P1)**: Needs Foundational only, except its logged-in redirect scenario, which
  uses `log_in` and passes once US2 is built (checked in T026)
- **US2 Log in (P1)**: Needs Foundational only; tests use fabricated users, not the Sign Up form
- **US3 Log out (P2)**: Needs US2 (tests log in first; `destroy` goes in the same
  `sessions_controller.rb`)
- **US4 Front page and header (P2)**: Needs Foundational; its logged-in header scenario needs
  US2 for `log_in`

### Within Each User Story

- Tests are written first and must fail
- Views and partials before the full test run
- Story complete before moving to the next

### Parallel Opportunities

- Foundational: T002–T005 together after T001; T007 alongside T006; T010 alongside T009;
  T013, T014, T015 together
- US1 and US2 can be built in parallel after Foundational (different files)
- US1: T019 alongside T018
- Polish: T034–T037 together

---

## Parallel Example: Foundational

```bash
# After T001:
Task: "Create spec/support/capybara.rb (T002)"
Task: "Create spec/support/cache.rb (T003)"
Task: "Create spec/support/macros.rb (T004)"
Task: "Set memory_store in config/environments/test.rb (T005)"

# Layout pieces:
Task: "field_error_proc in config/application.rb (T013)"
Task: "shared/_messages.html.erb (T014)"
Task: "shared/_header.html.erb (T015)"
```

## Parallel Example: User Stories 1 and 2

```bash
# After Phase 1:
Task: "US1: spec/features/user_signs_up_spec.rb, users_controller.rb, users/new.html.erb"
Task: "US2: spec/features/user_logs_in_spec.rb, sessions_controller.rb, sessions/new.html.erb"
```

---

## Implementation Strategy

### MVP First (User Story 1)

1. Phase 1: Foundational
2. Phase 2: User Story 1 (sign up)
3. **Stop and validate**: sign up works on its own

### Incremental Delivery

1. Foundational → model, layout and front page ready
2. US1 → visitors can sign up
3. US2 → users can log in (completes the P1 stories)
4. US3 → users can log out
5. US4 → front page and header fully covered, responsive check
6. Polish → all CI checks pass, roadmap updated

---

## Notes

- [P] tasks = different files, no dependencies on incomplete tasks
- Commit after each phase with a conventional commit message (e.g. `feat: add user sign up`)
- Do not add gems or packages; raise any need with the project owner (Principle VI)
- Original behavior differences are only those in the spec's Differences from the Original
  (KI-001 to KI-013); anything else found during implementation is raised with the project
  owner, not changed silently
