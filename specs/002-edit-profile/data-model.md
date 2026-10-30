# Data Model: Edit Profile

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-10-30

No database changes: no migration, no new tables or columns.

## User (changed)

Table `users` from feature 1 ([001 data model](../001-sign-up-log-in/data-model.md)). Fields,
indexes, normalization and the email and username rules are unchanged.

### Changes

| Change | Detail | Research |
|---|---|---|
| Password rules only when needed | Minimum 8 characters and Confirm Password presence apply on Sign Up and Change Password (`:create` and `:change_password` contexts) | R-001 |
| `current_password` virtual attribute | On every Update Account save and password change (`:update_account` and `:change_password` contexts): required ("can't be blank") and must match the saved password ("is incorrect") | R-002 |
| Change Password rules | In the `:change_password` context, `password` is required ("can't be blank") and the length and confirmation rules apply | R-003 |
| Mismatch message | "The passwords do not match", shown without a field name (Sign Up and Change Password) | R-003 |
| Session token | `generates_token_for :session`, based on the password salt; a new password makes existing tokens invalid | R-004 |

### Error messages

| Attribute | Field name | Messages |
|---|---|---|
| `current_password` | "Current Password" | "can't be blank", "is incorrect" |

Field names and the "is incorrect" message are in `config/locales/en.yml`
(`activerecord.attributes.user` and `activerecord.errors.models.user`).

## State changes

| Event | Effect |
|---|---|
| Email changed | Takes effect at once; next log in uses the new email (KI-019) |
| Password changed | New digest and salt; every session token made before stops working, so other browsers are logged out (KI-018); the current browser gets a new session and token (R-005) |
