# Data Model: Sign Up, Log In and Log Out

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-10-30

## User

A person with an account. Table `users`, as in the original, without the original's `token`
column (password reset, roadmap feature 14).

### Fields

| Field | Type | Null | Notes |
|---|---|---|---|
| `id` | bigint | no | Primary key |
| `email` | string | no | Stored lowercase with surrounding spaces removed (KI-001) |
| `username` | string | no | Stored as typed, with surrounding spaces removed (KI-015) |
| `password_digest` | string | no | bcrypt digest (`has_secure_password`, R-001) |
| `created_at` | datetime | no | |
| `updated_at` | datetime | no | |

Virtual attributes from `has_secure_password`: `password`, `password_confirmation`.

### Error messages

Each message is shown next to its field as a full message starting with the field's name
(KI-014), e.g. "Email can't be blank". Field names come from the attribute names, except
`password_confirmation`, which is named "Confirm Password" in `config/locales/en.yml` to match
its label.

### Indexes

| Index | Unique | Purpose |
|---|---|---|
| `email` | yes | One account per email (FR-004). Values are already lowercase. |
| `lower(username)` | yes | One account per username, ignoring letter case (KI-009) |

### Normalization

- `email`: surrounding spaces removed and lowercased, on assignment and in finders such as
  `authenticate_by` (R-006).
- `username`: surrounding spaces removed (KI-015); letter case kept.

### Validations

| Attribute | Rule | Error message (shown next to the field after its name, KI-014) | Spec |
|---|---|---|---|
| `email` | present | can't be blank | FR-002 |
| `email` | valid format (`URI::MailTo::EMAIL_REGEXP`), unless blank | is invalid | FR-002a, KI-005 |
| `email` | at most 254 characters, unless blank | is too long (maximum is 254 characters) | FR-002b, KI-010 |
| `email` | unique | cannot be used | FR-004a, KI-011 |
| `username` | present | can't be blank | FR-002 |
| `username` | 2–20 characters, unless blank | is too short (minimum is 2 characters) / is too long (maximum is 20 characters) | FR-002b, KI-010 |
| `username` | unique, ignoring letter case | has already been taken | FR-004, KI-009 |
| `password` | present on create (`has_secure_password`) | can't be blank | FR-002 |
| `password` | at least 8 characters | is too short (minimum is 8 characters) | FR-003 |
| `password` | at most 72 bytes (`has_secure_password`) | is too long (maximum is 72 characters) | FR-003, KI-004, R-008 |
| `password` | matches confirmation (`has_secure_password`) | doesn't match Password (on `password_confirmation`) | FR-003 |
| `password_confirmation` | present | can't be blank | FR-002 |

### Relationships

None in this feature. Later features add books, Wantlist items, exchanges, notifications and
feedback.

### State

No state transitions. "Logged in" is not stored on the user; it is the user's id in the
browser's session (R-002).

## Session (not stored in the database)

The Rails cookie session holds `user_id` while a user is logged in.

| Event | Session change |
|---|---|
| Log in succeeds | `reset_session`, then `session[:user_id] = user.id` (KI-006) |
| Log out | `reset_session` (KI-006) |
| Browser closed | Session cookie is discarded (KI-012) |
| Account for `user_id` missing | Treated as logged out (`find_by`, R-002) |
