# Quickstart: Sign Up, Log In and Log Out

**Feature**: [spec.md](./spec.md) | **Plan**: [plan.md](./plan.md) | **Date**: 2026-10-30

How to check the feature works, automatically and by hand. Routes and messages are in
[contracts/routes.md](./contracts/routes.md); field rules are in
[data-model.md](./data-model.md).

## Prerequisites

- Inside the Docker Sandbox (`sbx run claude`). Its environment was set up on 2026-10-30
  (Ruby 4.0.9, Yarn, PostgreSQL, Chromium for JavaScript tests (R-003), gems including
  bcrypt, JavaScript packages, assets and databases).
- PostgreSQL running: after a sandbox restart, `sudo service postgresql start`, then check
  with `pg_isready`.

## Automated checks

```bash
bin/rails db:migrate
bundle exec rspec
bundle exec rubocop
yarn lint:js && yarn format:js:check
yarn lint:erb && yarn format:erb:check
bin/brakeman --no-pager
bin/bundler-audit
```

Expected: all pass. The acceptance tests in `spec/features` cover every acceptance scenario
in the spec (SC-002).

## Manual walkthrough

Start the app with `bin/dev`. To view it from the host, ask the project owner to publish the
port (`sbx ports <sandbox-name> --publish 3000:3000`) and start the server bound to all
interfaces (`bin/dev` with `BINDING=0.0.0.0` or `bin/rails server -b 0.0.0.0`).

| # | Steps | Expected |
|---|---|---|
| 1 | Visit `/` logged out | Front page heading, lead text, "Sign Up" button; header shows "Sign Up" and "Log In" |
| 2 | Sign up with `alice@example.com`, `alice`, `password` twice | Log In page, "You have joined Bookchange, you can now log in." |
| 3 | Sign up again with ` Alice@Example.com `, `Alice` | "Email cannot be used", "Username has already been taken" |
| 4 | Sign up with `bob@example.com`, username `b`, password `short` twice | "Username is too short (minimum is 2 characters)", "Password is too short (minimum is 8 characters)" |
| 5 | Log in with ` ALICE@example.com ` and `password` | Home page with the username; header shows the user menu "alice" |
| 6 | Visit `/login` and `/signup` while logged in | Redirected to the home page |
| 7 | Open the user menu, click "Log Out" | Front page, "You have logged out.", logged-out header |
| 8 | Visit `/home` | Log In page, "You must be logged in to do that." |
| 9 | Log in with a wrong password, then an unknown email | "Log in error, please try again." both times |
| 10 | Submit the Log In form 11 times within 3 minutes | 11th: "Try again later." even with correct details |
| 11 | Close a message with its × button | The message disappears |
| 12 | Repeat 1, 2 and 7 at 375 px wide (browser dev tools) | No horizontal scrolling; menu usable (SC-005) |

The server's email format check (KI-005) can't be reached by hand, because the browser's
email field blocks invalid emails first; the model and acceptance tests cover it.

After step 10, wait 3 minutes (or restart the server, as development uses an in-memory cache)
before logging in again.
