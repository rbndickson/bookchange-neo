# Routes Contract: Edit Profile

**Feature**: [spec.md](../spec.md) | **Plan**: [../plan.md](../plan.md) | **Date**: 2026-10-30

The pages and requests this feature adds. Update Account follows the original's routes; Change
Password is new (KI-016). All responses are HTML. Feature 1's routes are unchanged
([001 routes](../../001-sign-up-log-in/contracts/routes.md)).

## Routes

| Method | Path | Action | Name | Who |
|---|---|---|---|---|
| GET | `/users/:id/edit` | `users#edit` | `edit_user` | The account's user |
| PATCH | `/users/:id` | `users#update` | `user` | The account's user |
| GET | `/password/edit` | `passwords#edit` | `edit_password` | Logged-in users |
| PATCH | `/password` | `passwords#update` | `password` | Logged-in users |

Original: `resources :users, only: [:create, :show, :edit, :update]`; `show` comes with
feature 5.

## Requests and responses

### Access (all four routes)

- Not logged in: redirect to `/login`, flash `danger` "You must be logged in to do that."
  (FR-015).
- Users routes, logged in as a different user or for an id with no account: redirect to
  `/home`, flash `danger` "You do not have access." Nothing is changed (FR-016).

### GET `/users/:id/edit`

- Update Account form (FR-002): heading "Update Account"; Email and Username filled in; empty
  Current Password; "Update" button; "Change Password" link to `/password/edit`.

### PATCH `/users/:id`

Parameters: `user[email]`, `user[username]`, `user[current_password]`.

- Rate limited: more than 10 requests from one IP within 3 minutes → redirect to
  `/users/:id/edit`, flash `danger` "Try again later." Nothing is saved (FR-013).
- Valid: save, redirect to `/home`, flash `success` "Your profile was updated." (FR-006).
- Invalid: status `422`, Update Account form with field errors, email and username as entered,
  Current Password empty; header shows the saved username (FR-007).
- Current Password is needed for every save (FR-005).

### GET `/password/edit`

- Change Password form (FR-008): heading "Change Password"; empty Current Password, New Password
  and Confirm New Password; "Change Password" button.

### PATCH `/password`

Parameters: `password_change[current_password]`, `password_change[new_password]`,
`password_change[new_password_confirmation]`.

- Rate limited: more than 10 requests from one IP within 3 minutes → redirect to
  `/password/edit`, flash `danger` "Try again later." Nothing is saved (FR-013).
- Valid: change the password, start a new session for the current browser (still logged in),
  redirect to `/home`, flash `success` "Your password was changed." Other sessions for the
  account are logged out (FR-011, FR-012).
- Invalid: status `422`, Change Password form with field errors and all fields empty (FR-011).

## Header

- User menu (logged in): "Update Account" (link to `/users/:id/edit` for the current user),
  then "Log Out" (FR-001).

## Messages

| Key | Text |
|---|---|
| `users.update.updated` | "Your profile was updated." |
| `users.update.rate_limited` | "Try again later." |
| `passwords.update.changed` | "Your password was changed." |
| `passwords.update.rate_limited` | "Try again later." |
