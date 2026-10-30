# Research: Edit Profile

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-10-30

Decisions made while planning. Rails behavior was checked against the installed
`activemodel-8.1.4` source and in a Rails runner. Decisions from feature 1 are referred to as
001/R-nnn.

## R-001: Password validations when the password is not being changed

- **Decision**: Run the `User` password length and confirmation presence validations only for
  a new user or when a new password is set:
  `validates :password, length: { minimum: 8 }, if: :password_required?` and the same for
  `validates :password_confirmation, presence: true`, with
  `def password_required? = new_record? || !password.nil?`.
- **Rationale**: Checked in a Rails runner: today `User.find(id).update(username: 'yy')` fails
  with "Password is too short (minimum is 8 characters)" and "Confirm Password can't be blank",
  because a loaded user's `password` is `nil` and the minimum length check does not skip `nil`.
  Sign Up keeps exactly the messages it has now (001/R-008), including "is too short" for a
  blank password.
- **Alternatives considered**: `allow_nil: true` on the length check (a blank Sign Up password
  would lose its "is too short" message, a visible change to feature 1); `on: :create` only
  (lets any later code, such as password reset in feature 14, save a short password).

## R-002: Current Password on Update Account (KI-017)

- **Decision**: A `current_password` virtual attribute on `User`, required on every Update
  Account save (spec Clarifications): `validates :current_password, presence: true` and a
  `current_password_correct` validation using `authenticate(current_password)` (only when
  present), both `on: :update_account`. `UsersController#update` saves with
  `@user.save(context: :update_account)`. The message `incorrect` is "is incorrect" and the
  attribute is named "Current Password" in `config/locales/en.yml`.
- **Rationale**: Keeps the rule in the model with the other `User` rules. A named validation
  context applies it only to the Update Account form, so other saves (such as `PasswordChange`
  and password reset in feature 14) are not affected, and a request that leaves out the field
  still fails. The Update Account form never sets a password, so `authenticate` checks against
  the saved digest. Validations without `on:` (email, username, password rules) still run in a
  named context.
- **Alternatives considered**: `on: :update` (would also apply to `PasswordChange`'s
  `user.update`, which has no current password); `has_secure_password`'s built-in
  `password_challenge`, which adds "is invalid" for a blank value as well as any presence error,
  and does not match the field name. An earlier version checked only when the email changed;
  the owner changed this because the field was confusing when it was only sometimes needed.

## R-003: Change Password form (KI-016, KI-017)

- **Decision**: A `PasswordChange` form object (`ActiveModel::Model`) in `app/models` with
  `user`, `current_password`, `new_password` and `new_password_confirmation`. It validates:
  all three present; `current_password` correct (`user.authenticate`); `new_password` at least
  8 characters and no more than 72 bytes (`password_too_long`, as in 001/R-008); and
  `new_password` confirmation. `save` returns `false` if invalid, otherwise
  `user.update(password: new_password, password_confirmation: new_password_confirmation)`.
- **Rationale**: Error messages are built from attribute names, and the spec needs "New
  Password" and "Confirm New Password" here while Sign Up keeps "Password" and "Confirm
  Password". A separate model gives the form its own names (`activemodel.attributes.
  password_change` in `config/locales/en.yml`), e.g. "Confirm New Password doesn't match New
  Password". `User`'s own validations still run on save (R-001), so the stored password always
  meets the rules.
- **Note**: A blank New Password shows "can't be blank" and "is too short (minimum is 8
  characters)", as Sign Up does for Password (001/R-008).
- **Cost**: The three password rules (minimum 8, 72 bytes, confirmation) are written in both
  `User` and `PasswordChange`.
- **Alternatives considered**: Saving through `User` and renaming its errors (Rails' confirmation
  message interpolates "Password", so messages would still read "doesn't match Password");
  validation contexts on `User` (same naming problem).

## R-004: Logging out other sessions on password change (KI-018)

- **Decision**: Store a session token instead of the user id:
  `generates_token_for :session do password_salt.last(10) end` on `User`. Log in sets
  `session[:user_token] = user.generate_token_for(:session)`, and `current_user` becomes
  `User.find_by_token_for(:session, session[:user_token])`. A password change gives a new salt,
  so tokens in other browsers stop matching and those browsers are logged out on their next
  request.
- **Rationale**: The pattern Rails uses for its own password reset tokens
  (`has_secure_password` defines `password_salt`; checked in a Rails runner). Tokens are signed,
  so they cannot be forged, and no table or migration is needed. It keeps 001/R-002's cookie
  session, so sessions still end when the browser closes (KI-012).
- **Alternatives considered**: A `sessions` table (as in the Rails authentication generator,
  001/R-002): more code and a migration for the same result here. Storing the salt fragment
  next to `session[:user_id]`: hand-written comparison of what `generates_token_for` already
  does.
- **Note**: The app has not been deployed, so no existing sessions are affected; a browser
  logged in to a local development server before this change needs to log in again. A deleted
  account still gives `nil` (spec feature 1 Edge Cases).

## R-005: Keeping the current browser logged in after a password change

- **Decision**: After a successful change, `reset_session`, set `session[:user_token]` to a new
  token for the new salt, then set the flash (after `reset_session`, 001/R-007).
- **Rationale**: The old token stops matching once the salt changes, so the current session
  needs a new one to stay logged in (FR-012). Starting a new session at the same time renews
  the session identifier, as on log in (KI-006), with no visible change (spec Assumptions).

## R-006: Routes and controllers

- **Decision**:
  - Update Account: `resources :users, only: [:create, :edit, :update]`, giving
    `GET /users/:id/edit` and `PATCH /users/:id` as in the original, in `UsersController` with
    the original's `set_user` (`User.find_by(id: params[:id])`), `require_user` and
    `require_correct_user` guards.
  - Change Password: `resource :password, only: [:edit, :update]`, giving `GET /password/edit`
    and `PATCH /password`, in a new `PasswordsController` with `require_user`. It always acts on
    `current_user`, so no id is in the address (spec Assumptions).
- **Rationale**: RESTful and conventional (Principle III). `set_user` loads a separate `User`
  object from `current_user`, so after a failed save the header still shows the saved username
  (FR-007), as in the original.
- **Note**: Password reset in feature 14 uses its own controllers (`ForgotPasswordsController`,
  `PasswordResetsController`), so `PasswordsController` does not clash.

## R-007: Rate limits (KI-017)

- **Decision**: `rate_limit to: 10, within: 3.minutes, only: :update` in both controllers, with
  a `with:` block redirecting to the same page with `flash[:danger]` "Try again later.",
  declared after the `require_user` and `require_correct_user` guards.
- **Rationale**: As log in (001/R-005). Rails keys counts by controller as well as IP address,
  so each form has its own limit (FR-013) and neither uses up log in's. Declaring the limit
  after the guards means visitors and other users get the access messages, and the redirect can
  use `current_user`. Every `update` request counts, whatever it changes (spec Clarifications).
- **Tests**: The test cache store is already `:memory_store` and cleared before each example
  (001/R-005).

## R-008: Pages and header

- **Decision**: `users/edit.html.erb` and `passwords/edit.html.erb` with the same layout,
  Bootstrap form rows and `shared/_field_errors` partial as Sign Up (001/R-009). Failed saves
  render with status `422`. The header's user menu gets an "Update Account" `link_to`
  `edit_user_path(current_user)` with class `dropdown-item`, above "Log Out".
- **Rationale**: Matches the existing pages (FR-017). The original shared a `users/_form`
  partial between Sign Up and Update Account; the forms no longer share their password fields,
  so separate views are simpler.
- **Messages**: success messages use `flash[:success]`, as in the original.
