# Data Model: Edit Profile

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-10-30

No database changes: no migration, no new tables or columns.

## User (changed)

Table `users` from feature 1 ([001 data model](../001-sign-up-log-in/data-model.md)). Fields,
indexes, normalization and the email and username rules are unchanged.

### Changes

| Change | Detail | Research |
|---|---|---|
| Password rules only when needed | Minimum 8 characters and Confirm Password presence apply to a new user, or when a password is set (`password_required?`) | R-001 |
| `current_password` virtual attribute | On update, when the email changes: required ("can't be blank") and must match the saved password ("is incorrect") | R-002 |
| Session token | `generates_token_for :session`, based on the password salt; a new password makes existing tokens invalid | R-004 |

### Error messages

| Attribute | Field name | Messages |
|---|---|---|
| `current_password` | "Current Password" | "can't be blank", "is incorrect" |

Field names and the "is incorrect" message are in `config/locales/en.yml`
(`activerecord.attributes.user` and `activerecord.errors.models.user`).

## PasswordChange (new form object)

Not stored: an `ActiveModel::Model` used by the Change Password form, which saves the new
password to its `user` (R-003).

### Attributes

| Attribute | Field name | Rules |
|---|---|---|
| `user` | | The logged-in user |
| `current_password` | "Current Password" | Required; must match the user's saved password ("is incorrect") |
| `new_password` | "New Password" | Required; at least 8 characters; no more than 72 bytes ("is too long (maximum is 72 characters)"); confirmed |
| `new_password_confirmation` | "Confirm New Password" | Required; must match ("doesn't match New Password") |

`save` returns `false` when invalid; otherwise it updates the user's password.

Field names and messages are in `config/locales/en.yml` (`activemodel.attributes.
password_change` and `activemodel.errors.models.password_change`).

## State changes

| Event | Effect |
|---|---|
| Email changed | Takes effect at once; next log in uses the new email (KI-019) |
| Password changed | New digest and salt; every session token made before stops working, so other browsers are logged out (KI-018); the current browser gets a new session and token (R-005) |
