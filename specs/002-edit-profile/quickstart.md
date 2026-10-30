# Quickstart: Edit Profile

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-10-30

How to check the feature works, automatically and by hand. Routes and messages are in
[contracts/routes.md](./contracts/routes.md); field rules are in
[data-model.md](./data-model.md).

## Prerequisites

- Inside the Docker Sandbox (`sbx run claude`), set up as for feature 1
  ([001 quickstart](../001-sign-up-log-in/quickstart.md)).
- PostgreSQL running: after a sandbox restart, `sudo service postgresql start`, then check
  with `pg_isready`.
- No migration is needed for this feature.

## Automated checks

```bash
bundle exec rspec
bundle exec rubocop
yarn lint:js && yarn format:js:check
yarn lint:erb && yarn format:erb:check
bin/brakeman --no-pager
bin/bundler-audit
```

Expected: all pass. The acceptance tests in `spec/features` cover every acceptance scenario
in the spec (SC-002), and feature 1's tests still pass.

## Manual walkthrough

Start the app with `bin/dev` (see feature 1's quickstart for viewing it from the host). Sign up
`alice@example.com` / `alice` and `bob@example.com` / `bob`, both with the password `password`,
and log in as alice.

| # | Steps | Expected |
|---|---|---|
| 1 | Open the user menu | "Update Account" above "Log Out" |
| 2 | Click "Update Account" | Email and Username filled in, empty Current Password, "Update" button, "Change Password" link |
| 3 | Change the username to `alice2`, enter Current Password `password`, click "Update" | Home page, "Your profile was updated.", header shows "alice2" |
| 4 | Change the username to `Bob`, with Current Password `password` | "Username has already been taken"; header still shows "alice2" |
| 5 | Change the username or email with Current Password blank, then wrong | "Current Password can't be blank", then "Current Password is incorrect" |
| 6 | Change the email to `alice2@example.com` with Current Password `password` | "Your profile was updated."; log out and log in with the new email |
| 7 | Visit bob's `/users/<bob's id>/edit`, and `/users/999999/edit` | Home page, "You do not have access." |
| 8 | Log out; visit `/users/<alice's id>/edit` and `/password/edit` | Log In page, "You must be logged in to do that." |
| 9 | Log in as alice in two browsers (e.g. one private window) | Both logged in |
| 10 | In one, Update Account → "Change Password"; enter `password`, `newpassword` twice | Home page, "Your password was changed.", still logged in |
| 11 | In the other browser, reload | Logged out: next page needing log in shows "You must be logged in to do that." |
| 12 | Log out; log in with `password`, then `newpassword` | First fails, second works |
| 13 | On Change Password, submit mismatched or short new passwords, or a wrong current password | "The passwords do not match", "Password is too short (minimum is 8 characters)", "Current Password is incorrect" |
| 14 | Submit the Update Account form 11 times within 3 minutes | 11th: "Try again later." |
| 15 | Repeat 2 and 10 at 375 px wide (browser dev tools) | No horizontal scrolling (SC-006) |

After step 14, wait 3 minutes (or restart the server, as development uses an in-memory cache)
before saving again. A browser logged in to the development server before this feature was
built needs to log in again (R-004).
