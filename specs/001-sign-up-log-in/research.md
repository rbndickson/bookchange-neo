# Research: Sign Up, Log In and Log Out

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-10-30

Decisions made while planning. R-001 to R-003 were confirmed by the project owner on
2026-10-30. Rails behavior was checked against the `8-1-stable` source.

## R-001: Password storage

- **Decision**: `has_secure_password` with the `bcrypt` gem. The project owner uncomments
  `gem 'bcrypt', '~> 3.1.7'` in the `Gemfile` before implementation (Principle VI).
- **Rationale**: Same approach as the original. Its built-in validations reject passwords over
  72 bytes (`password_too_long`, KI-004), and it enables `User.authenticate_by` (R-004).
- **Alternatives considered**: argon2 through `has_secure_password`'s `algorithm` option (also
  needs a gem, no benefit for this app); hand-written hashing with OpenSSL (more code to review,
  against Principle VI simplicity).

## R-002: Session design

- **Decision**: Hand-written, mirroring the original: the user's id in the Rails session
  (`session[:user_id]`), with `current_user`, `logged_in?`, `require_user` and `access_denied`
  in `ApplicationController`. Modern Rails pieces replace parts of the original:
  `authenticate_by` (R-004), `rate_limit` (R-005), `normalizes` (R-006) and `reset_session`
  (R-007).
- **Rationale**: The simplest design that meets the spec, and the closest to the original's
  structure (Coding Style). The Rails cookie session has no expiry date, so it ends when the
  browser closes (KI-012, spec Assumptions). No sessions table is needed.
- **Alternatives considered**: The Rails 8 authentication generator. It sets a permanent cookie
  (users stay logged in after the browser closes, against KI-012), names the column
  `email_address`, uses opt-out `allow_unauthenticated_access` instead of the original's
  `require_user` guards, and adds password reset (feature 14). Adapting it means more code than
  writing the small amount needed. Its main benefit, a sessions table that can log out other
  sessions on password change, can be revisited in feature 2 or 14 if needed.
- **Note**: `current_user` uses `User.find_by(id: session[:user_id])` (not the original's
  `find`), so a session for a missing account is treated as logged out (spec Edge Cases).

## R-003: Browser for JavaScript acceptance tests

- **Decision**: Install Chromium with `apt` in the Docker Sandbox during implementation, for
  Cuprite. CI's `ubuntu-latest` runner already has Chrome.
- **Rationale**: The user menu dropdown and closing messages need JavaScript (Bootstrap), and
  the constitution requires Cuprite where JavaScript is involved (Principle IV). No `Gemfile`
  or `package.json` change.
- **Notes**: Ruby 4.0.9 is also not installed in the sandbox yet; the README's Installation
  steps are done at the start of implementation. Chromium running as root in a container
  needs the `no-sandbox` browser option; the Cuprite driver sets it.

## R-004: Even timing for failed log ins (KI-008)

- **Decision**: Log in with `User.authenticate_by(email:, password:)`.
- **Rationale**: When no user has the email, Rails still builds a password digest
  (`new(passwords)`), so an unknown email takes about as long as a wrong password.
- **Alternatives considered**: `User.find_by(email:)&.authenticate(password)`, as in the
  original; fails fast for unknown emails (the issue KI-008 fixes).
- **Note**: `authenticate_by` returns early when the password is blank; this does not depend
  on whether the email exists, so it reveals nothing.

## R-005: Log in rate limit (KI-007)

- **Decision**: `rate_limit to: 10, within: 3.minutes, only: :create` in `SessionsController`,
  with a `with:` block that redirects to the Log In page with `flash[:danger] = 'Try again
  later.'`.
- **Rationale**: Built into Rails 8.1, counted per IP address (`request.remote_ip`, the spec's
  "connection") in the cache store. The 11th attempt within 3 minutes is refused (count > 10).
- **Store per environment**: production uses Solid Cache and development `:memory_store`
  (already configured). Test uses `:null_store`, which never counts, so the test environment
  changes to `:memory_store`, and `Rails.cache.clear` runs before each example so counts do
  not leak between tests (all test requests share one IP). `perform_caching` stays off in
  test, so no views are cached.
- **Alternatives considered**: A separate store for rate limits only (the `store:` option);
  not needed while the app caches nothing else.
- **Note**: The store is read when `SessionsController` loads, so the test cache setting must
  be in `config/environments/test.rb`, not set within a spec.

## R-006: Email and username rules (KI-001, KI-005, KI-009, KI-010, KI-011)

- **Decision**:
  - `normalizes :email, with: ->(email) { email.strip.downcase }`. Rails also applies it to
    finder values, so `authenticate_by(email: ' Alice@Example.com ')` finds `alice@example.com`.
  - Email: presence; length maximum 254; format `URI::MailTo::EMAIL_REGEXP`; uniqueness with
    the message "This email cannot be used". Length and format use `allow_blank: true`, so a
    blank email only shows "can't be blank".
  - Username: presence; length 2–20; uniqueness with `case_sensitive: false`. Stored and shown
    as typed.
  - Database unique indexes back both: on `email` (already lowercase) and on `lower(username)`.
- **Rationale**: Built-in Rails validations and `normalizes` (Coding Style prefers it). The
  unique indexes stop duplicates from two sign ups at the same moment.
- **Alternatives considered**: PostgreSQL `citext` for usernames (needs an extension, less
  conventional); a stricter email pattern (not needed for the spec).

## R-007: New session on log in and log out (KI-006)

- **Decision**: Call `reset_session` before setting `session[:user_id]` on log in, and on log
  out. Set the flash after `reset_session`.
- **Rationale**: Rails' `reset_session` also clears the flash (`self.flash = nil` in
  `ActionDispatch::Flash`), so a flash set before it would be lost. Setting it after keeps
  "You have logged out." on the next page.

## R-008: Password rules (KI-004, KI-013)

- **Decision**: Keep `has_secure_password`'s default validations (presence on create,
  confirmation, 72-byte maximum). Add `validates :password, length: { minimum: 8 }` and
  `validates :password_confirmation, presence: true`. Override the `password_too_long` message
  for `User#password` to "is too long (maximum is 72 characters)" in `config/locales/en.yml`.
- **Rationale**: Any password over 72 characters is also over 72 bytes, so the one built-in
  check covers both limits in the spec with one error message, instead of two "too long"
  errors at once. A password under 72 characters but over 72 bytes (many emoji) gets the same
  message; this is rare and the spec only requires "an error that it is too long".
- **Notes**: Not adding a password presence validation avoids a duplicate "can't be blank"
  (`has_secure_password` already adds one). A blank password shows "can't be blank" and "is
  too short (minimum is 8 characters)", as the original did. Feature 2 (edit profile) will
  revisit when the password confirmation is required.

## R-009: Forms and error display

- **Decision**: ERB forms with `form_with` and Bootstrap 5 form classes. Each invalid field
  gets `is-invalid` and its messages in an `invalid-feedback` element, joined with ", " (as
  bootstrap_form did in the original), shown through a shared partial. Set
  `config.action_view.field_error_proc` to return the field unchanged, so Rails' default
  `field_with_errors` wrapper does not break Bootstrap's layout.
- **Rationale**: The original used the `bootstrap_form` gem; the new stack has no form gem, and
  adding one needs approval (Principle VI). A small partial is enough for two forms.
- **Turbo**: A failed sign up renders the form with status `422 Unprocessable Content`, which
  Turbo requires to show it. Failed log in redirects, as the original does.

## R-010: Log out request (KI-002)

- **Decision**: `delete 'logout'` route, and a `button_to 'Log Out', logout_path, method:
  :delete` styled with `dropdown-item` in the user menu.
- **Rationale**: `button_to` builds a form with the CSRF token, so other sites cannot log users
  out; styled as a menu item it looks like the original's link.

## R-011: Header, dropdown and messages

- **Decision**: Bootstrap 5 navbar in `shared/_header`; the user menu is a Bootstrap dropdown
  (`data-bs-toggle="dropdown"`); messages in `shared/_messages` as `alert alert-<type>
  alert-dismissible` with a close button (`data-bs-dismiss="alert"`). The brand uses the
  Bootstrap Icons book icon (`bi-book`) in place of the original's Font Awesome icon.
- **Rationale**: Bootstrap's JavaScript is already imported in `app/javascript/application.js`
  with `@popperjs/core`; its data attributes work after Turbo page changes because Bootstrap
  listens on the document. No Stimulus controller is needed.
- **Flash types**: `:success`, `:danger` and `:info` map directly to Bootstrap alert classes.
  `:info` is used only for "You have logged out.", as in the original (spec FR-019).

## R-012: Acceptance test setup

- **Decision**: `spec/support` with Capybara and Cuprite setup (Rack::Test by default, Cuprite
  for `js: true`) and a `log_in(user)` helper, loaded from `rails_helper.rb`. Fabricators
  `:user` (with `sequence` for email and username), `:alice` and `:bob`.
- **Rationale**: Matches the original's `spec/support/macros.rb` and fabricators. Fabrication's
  `sequence` replaces Faker, which is not in the stack.
- **JavaScript tests**: Log out through the dropdown, and closing a message, use `js: true`.
  Other scenarios use Rack::Test, which is faster.
