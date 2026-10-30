# Routes Contract: Sign Up, Log In and Log Out

**Feature**: [spec.md](../spec.md) | **Plan**: [../plan.md](../plan.md) | **Date**: 2026-10-30

The pages and requests this feature exposes. Paths follow the original's routes; only log out
changes method (KI-002). All responses are HTML.

## Routes

| Method | Path | Action | Name | Who |
|---|---|---|---|---|
| GET | `/` | `pages#front` | `root` | Everyone |
| GET | `/home` | `pages#home` | `home` | Logged-in users |
| GET | `/signup` | `users#new` | `signup` | Visitors |
| POST | `/users` | `users#create` | `users` | Visitors |
| GET | `/login` | `sessions#new` | `login` | Visitors |
| POST | `/login` | `sessions#create` | `login` | Visitors |
| DELETE | `/logout` | `sessions#destroy` | `logout` | Logged-in users |

Original: `get 'logout'`. Changed to `delete` (KI-002).

## Requests and responses

### GET `/`

- Front page (FR-015): heading, lead text and "Sign Up" button linking to `/signup`.
- Shown to visitors and logged-in users, as in the original.

### GET `/home`

- Logged in: temporary home page showing the username (FR-016).
- Not logged in: redirect to `/login`, flash `danger` "You must be logged in to do that."
  (FR-014).

### GET `/signup`

- Visitor: Sign Up form (FR-001).
- Logged in: redirect to `/home` (FR-011, KI-003).

### POST `/users`

Parameters: `user[email]`, `user[username]`, `user[password]`, `user[password_confirmation]`.

- Logged in: redirect to `/home` (FR-011, KI-003).
- Valid: create the user, redirect to `/login`, flash `success` "You have joined Bookchange,
  you can now log in." Not logged in (FR-006).
- Invalid: status `422`, Sign Up form with field errors, email and username kept, password
  fields empty (FR-007).

### GET `/login`

- Visitor: Log In form (FR-008).
- Logged in: redirect to `/home` (FR-011).

### POST `/login`

Parameters: `email`, `password`.

- Rate limited: more than 10 requests from one IP within 3 minutes → redirect to `/login`,
  flash `danger` "Try again later." The request is not processed, even with correct details
  (FR-010a, KI-007).
- Logged in: redirect to `/home` (FR-011).
- Correct details: new session with the user's id, redirect to `/home` (FR-009, FR-012a). No
  flash, as in the final original.
- Wrong details (unknown email, wrong password or blank): redirect to `/login`, flash `danger`
  "Log in error, please try again." Same timing whether or not the email exists (FR-010,
  KI-008).

### DELETE `/logout`

- Requires a valid CSRF token (KI-002).
- Logged in: session reset, redirect to `/`, flash `info` "You have logged out." (FR-013,
  FR-012a).
- Not logged in: same result (resetting an empty session is harmless; as in the original).

## Shared layout

- Header (FR-017, FR-018):
  - Visitor: brand (book icon and "Bookchange") linking to `/`; "Sign Up" and "Log In"
    buttons.
  - Logged in: brand linking to `/home`; user menu labelled with the username, containing a
    "Log Out" button.
- Messages (FR-019): one dismissible alert per flash, styled `alert-success`, `alert-danger`
  or `alert-info`.
- Page title: "Bookchange" (FR-021).
