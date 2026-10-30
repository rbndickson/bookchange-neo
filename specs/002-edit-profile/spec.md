# Feature Specification: Edit Profile

**Feature Branch**: `002-edit-profile`

**Created**: 2026-10-30

**Status**: Draft

**Input**: User description: "roadmap feature 2" (Roadmap feature 2: Edit profile)

## Original Behavior Reproduced

This feature reproduces the original application's account update behavior, added 2016-01-13
(reference: `UsersController#edit/update` and `require_correct_user`, `users/edit` and
`users/_form`, the `User` validations, `ApplicationController#access_denied` and the
"Update Account" entry in `shared/_header`). Where the original changed after the feature was
first added, the final version of that behavior is the reference.

The validation rules, normalization and messages for email, username and password are the
ones approved in feature 1 (KI-001, KI-004, KI-005, KI-009 to KI-011, KI-014, KI-015) and apply
here unchanged. Approved fixes and accepted behavior for this feature, including moving the
password change to its own page, are listed under Differences from the Original (KI-016 to
KI-019).

## Clarifications

### Session 2026-10-30

- Q: Should the new wording for the Change Password page be used as proposed? → A: Yes:
  "Change Password" for the heading, link and button; "Current Password", "New Password" and
  "Confirm New Password" for the fields; "Your password was changed." on success; error messages
  naming the fields as labelled.
- Q: On the Update Account page, should the limit of 10 submissions in 3 minutes count every
  save, or only saves that change the email? → A: Every save, whatever it changes (the simplest
  rule, as with log in).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Update username or email (Priority: P1)

A logged-in user opens "Update Account" from the user menu in the header, sees a form filled in
with their current email and username, changes them and saves. They are taken to the home page
with a message telling them their profile was updated.

**Why this priority**: It is the core of the feature: users can correct or change the details
other users will see (the username) and that they log in with (the email).

**Independent Test**: Log in, open the user menu, click "Update Account", change the username,
click "Update" and confirm the home page shows "Your profile was updated." and the new username
in the header.

**Acceptance Scenarios**:

1. **Given** a logged-in user, **When** they open the user menu in the header, **Then** they see
   an "Update Account" option above "Log Out".
2. **Given** a logged-in user, **When** they click "Update Account", **Then** they see the
   "Update Account" page with Email and Username filled in with their current values, an empty
   Current Password field, an "Update" button and a "Change Password" link.
3. **Given** a logged-in user on the Update Account page, **When** they change the username to
   a new valid username, leave Current Password blank and click "Update", **Then** the username
   is saved, they are taken to the home page and see "Your profile was updated.", and the header
   shows the new username (KI-017).
4. **Given** a logged-in user on the Update Account page, **When** they change the email to a
   new valid email, enter their current password in Current Password and click "Update",
   **Then** the email is saved, they are taken to the home page and see "Your profile was
   updated.", and they can log in with the new email from then on (KI-017, KI-019).
5. **Given** a logged-in user on the Update Account page, **When** they change the email and
   leave Current Password blank, **Then** nothing is saved and they see "Current Password can't
   be blank" (KI-017).
6. **Given** a logged-in user on the Update Account page, **When** they change the email and
   enter a wrong Current Password, **Then** nothing is saved and they see "Current Password is
   incorrect" (KI-017).
7. **Given** a logged-in user on the Update Account page, **When** they clear the email or
   username and click "Update", **Then** nothing is saved and they see the form again with an
   error naming the blank field (e.g. "Username can't be blank"), with the other values they
   entered kept (except Current Password).
8. **Given** another account with the email `bob@example.com`, **When** a user changes their
   email to ` Bob@Example.com ` with the correct Current Password, **Then** nothing is saved and
   they see "Email cannot be used" (KI-001, KI-011).
9. **Given** another account with the username `bob`, **When** a user changes their username to
   `Bob`, **Then** nothing is saved and they see "Username has already been taken" (KI-009).
10. **Given** a logged-in user on the Update Account page, **When** they enter an invalid email
    (e.g. `alice`), an email longer than 254 characters, or a username shorter than 2 or longer
    than 20 characters, **Then** nothing is saved and they see the same error as on Sign Up
    (KI-005, KI-010).
11. **Given** 10 submissions of the Update Account form from the same connection in the last 3
    minutes, whatever they changed, **When** it is submitted again, even with valid details,
    **Then** nothing is saved, they are returned to the Update Account page and see "Try again
    later." (KI-017).

---

### User Story 2 - Change password (Priority: P1)

A logged-in user follows "Change Password" from the Update Account page, enters their current
password and a new password twice, and saves. Other browsers logged in to their account are
logged out.

**Why this priority**: Users need to be able to replace a password they think is weak or known
to someone else; until roadmap feature 14 (password reset) this is the only way to change it.

**Independent Test**: Log in, open "Update Account", follow "Change Password", enter the current
password and a new password twice, click "Change Password", log out and confirm logging in works
with the new password and not the old one.

**Acceptance Scenarios**:

1. **Given** a logged-in user on the Update Account page, **When** they click "Change Password",
   **Then** they see the "Change Password" page with empty Current Password, New Password and
   Confirm New Password fields and a "Change Password" button.
2. **Given** a logged-in user on the Change Password page, **When** they enter their current
   password, a new password of 8–72 characters and the same in Confirm New Password, and click
   "Change Password", **Then** the password is changed, they stay logged in, are taken to the
   home page and see "Your password was changed." (KI-016).
3. **Given** a user who has changed their password, **When** they log in, **Then** the new
   password works and the old one gives "Log in error, please try again."
4. **Given** a user logged in on two browsers, **When** they change their password on one,
   **Then** the other browser is logged out: its next page needing a logged-in user takes it to
   the Log In page with "You must be logged in to do that." (KI-018).
5. **Given** a logged-in user on the Change Password page, **When** they leave any field blank
   and click "Change Password", **Then** the password is not changed and they see an error
   naming each blank field (e.g. "Current Password can't be blank").
6. **Given** a logged-in user on the Change Password page, **When** they enter a wrong Current
   Password, **Then** the password is not changed and they see "Current Password is incorrect"
   (KI-017).
7. **Given** a logged-in user on the Change Password page, **When** New Password and Confirm New
   Password do not match, **Then** the password is not changed and they see "Confirm New
   Password doesn't match New Password".
8. **Given** a logged-in user on the Change Password page, **When** the new password is shorter
   than 8 characters, or longer than 72 characters or 72 bytes, **Then** the password is not
   changed and they see "New Password is too short (minimum is 8 characters)" or "New Password
   is too long (maximum is 72 characters)" (KI-004).
9. **Given** 10 submissions of the Change Password form from the same connection in the last 3
   minutes, **When** it is submitted again, even with correct details, **Then** the password is
   not changed, they are returned to the Change Password page and see "Try again later."
   (KI-017).

---

### User Story 3 - Only the owner can update an account (Priority: P1)

The Update Account and Change Password pages act only on the logged-in user's own account.
Visitors are sent to log in, and logged-in users trying to reach another account's Update
Account page are turned away.

**Why this priority**: Without it any user could change another user's details and take over
their account.

**Independent Test**: Logged out, visit a user's Update Account address and confirm the Log In
page is shown; logged in as another user, visit it and confirm the home page is shown with
"You do not have access."

**Acceptance Scenarios**:

1. **Given** a visitor who is not logged in, **When** they visit the Update Account or Change
   Password page or submit either form, **Then** they are taken to the Log In page and see "You
   must be logged in to do that."
2. **Given** a logged-in user, **When** they visit another user's Update Account page or submit
   a change to another user's account, **Then** nothing is changed, they are taken to the home
   page and see "You do not have access."
3. **Given** a logged-in user, **When** they visit the Update Account page of an account that
   does not exist, **Then** they are taken to the home page and see "You do not have access."

---

### Edge Cases

- Saving the Update Account form without changing anything succeeds with "Your profile was
  updated." and needs no Current Password.
- Changing the email only in letter case or surrounding spaces (e.g. ` Alice@Example.com ` when
  the email is `alice@example.com`) is not a change of email (KI-001), so no Current Password is
  needed and the email stays the same.
- Changing the username only in letter case (`alice` to `Alice`) is allowed; it is the same
  user's own username (KI-009).
- On the Update Account page, Current Password is only checked when the email changes; if it is
  filled in for a username-only change it is ignored.
- After a failed save, the header still shows the saved username, not the one typed into the
  form.
- If a save fails for any reason, nothing is changed, including any valid fields in the same
  submission.
- The user's own email and username do not count as "already used" when saving.
- A new password that is the same as the current one is accepted.
- Changing the email or username does not log the user out or log out other browsers; only a
  password change does (KI-018).

## Differences from the Original

The original's bugs, quirks and weaknesses found while writing this spec (its Known Issues),
with the project owner's decision on each, approved on 2026-10-30. KI numbers continue from
feature 1 and are referred to by the requirements below.

### Fixes and improvements

- **KI-016 – Password changed on the same form as the profile**: the original's Update Account
  form has Password and Confirm Password fields that are required on every save, and whatever is
  typed becomes the new password, so changing only the username means typing a password again.
  Decision: **fix** – the password is changed on its own "Change Password" page, reached by a
  "Change Password" link on the Update Account page; the Update Account form has no new password
  fields (FR-002, FR-009).
- **KI-017 – Current password not asked for**: the original never asks for the current
  password, so anyone using a logged-in browser (for example a shared computer) can change the
  account's email and password and take it over. Decision: **fix** – the correct current
  password is needed to change the email or the password, but not the username; submissions of
  each form are limited to 10 per connection within 3 minutes, as with log in (KI-007), so the
  current password cannot be guessed without limit (FR-005, FR-010, FR-013).
- **KI-018 – Other sessions stay logged in after a password change**: in the original, other
  browsers logged in to the account stay logged in after the password is changed, so someone who
  knew the old password keeps access. Decision: **fix** – changing the password ends every other
  session for the account; the browser that made the change stays logged in (FR-012).

### Accepted behavior

- **KI-019 – Email changes are not confirmed**: the original lets a user change their email to
  any address without confirming they own it, because it has no email confirmation step (as with
  KI-011). Decision: **reproduce** – a new email takes effect at once (FR-004).

## Requirements *(mandatory)*

### Functional Requirements

**Update Account**

- **FR-001**: The header's user menu MUST contain "Update Account", above "Log Out", linking to
  the logged-in user's Update Account page.
- **FR-002**: The Update Account page MUST have the heading "Update Account", a form with Email
  and Username filled in with the user's saved values, an empty Current Password field and an
  "Update" button, and a "Change Password" link to the Change Password page (KI-016).
- **FR-003**: Users MUST be able to change their username under the same rules and messages as
  Sign Up (feature 1: FR-002, FR-002b, FR-004, FR-007), without their current password.
- **FR-004**: Users MUST be able to change their email under the same rules, normalization and
  messages as Sign Up (feature 1: FR-002, FR-002a, FR-002b, FR-004, FR-004a, FR-007); a changed
  email takes effect at once, without confirmation (KI-019).
- **FR-005**: Changing the email MUST need the user's current password in Current Password: a
  blank one MUST show "Current Password can't be blank" and a wrong one "Current Password is
  incorrect" (KI-017).
- **FR-006**: On a successful save the user MUST be taken to the home page with the message
  "Your profile was updated."
- **FR-007**: On a failed save nothing MUST be changed, and the form MUST be shown again with an
  error next to each invalid field, starting with the field's name, with the entered email and
  username kept and Current Password empty. The header MUST keep showing the saved username.

**Change Password**

- **FR-008**: The Change Password page MUST have the heading "Change Password" and a form with
  empty Current Password, New Password and Confirm New Password fields and a "Change Password"
  button.
- **FR-009**: Users MUST be able to change their password; all three fields MUST be required,
  the new password MUST follow the Sign Up password rules (feature 1: FR-003) and match Confirm
  New Password, with messages naming the fields as labelled (e.g. "Confirm New Password doesn't
  match New Password") (KI-014, KI-016).
- **FR-010**: A wrong Current Password MUST show "Current Password is incorrect" and leave the
  password unchanged (KI-017).
- **FR-011**: On a successful change the user MUST stay logged in and be taken to the home page
  with the message "Your password was changed."; on a failed one the form MUST be shown again
  with an error next to each invalid field and all fields empty.
- **FR-012**: When the password is changed, every other session for the account MUST end; the
  session that made the change MUST stay logged in (KI-018).

**Both pages**

- **FR-013**: Submissions of the Update Account form and of the Change Password form MUST each be
  limited to 10 per connection within 3 minutes, counting every submission whatever it changes;
  submissions over the limit MUST change nothing
  and return the user to the same page with the message "Try again later." (KI-017).
- **FR-014**: Password values MUST never be shown or re-filled in either form.
- **FR-015**: Visitors who are not logged in MUST be sent to the Log In page with "You must be
  logged in to do that." when they visit either page or submit either form.
- **FR-016**: Logged-in users MUST only be able to view and update their own account; visiting
  or submitting to another account's, or a non-existent account's, Update Account page MUST
  change nothing and take them to the home page with "You do not have access." The Change
  Password page MUST only ever act on the logged-in user's own account.
- **FR-017**: Both pages MUST be usable on phone, tablet and desktop screen widths, in the same
  style as the Sign Up page.

### Key Entities

- **User** (from feature 1): email, username and protected password, now changeable by the user.
  A password change also ends the user's other sessions.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A logged-in user can change their username in under 1 minute from any page.
- **SC-002**: 100% of the acceptance scenarios in this spec pass as automated browser tests.
- **SC-003**: In 100% of attempts, a user cannot view or change another user's account.
- **SC-004**: In 100% of attempts, the email or password cannot be changed without the correct
  current password.
- **SC-005**: After a password change, 100% of the account's other sessions are logged out on
  their next request.
- **SC-006**: Both pages can be used at a 375 pixel wide screen without horizontal scrolling.

## Assumptions

- **Scope of pages**: the user menu's "My Page" entry (5) and the header links from later
  features are still left out, as in feature 1.
- **Labels and wording** follow the original for Update Account: the menu item and heading
  "Update Account", fields "Email" and "Username", button "Update" and the message "Your profile
  was updated." The Current Password field, the Change Password page and link, its labels
  ("Current Password", "New Password", "Confirm New Password"), its button and the message "Your
  password was changed." are new with KI-016 and KI-017, and approved by the project owner.
- **Current Password messages** use the standard wording for a blank field ("can't be blank")
  and "is incorrect" for a wrong password, after the field's name (KI-014).
- **Account address**: the Update Account page is reached at an address naming the account, as
  in the original, which is why other users' and non-existent accounts need the "You do not have
  access." check. The Change Password page is new and always acts on the logged-in user, so it
  needs no such check.
- **Session renewal**: a password change keeps the current browser logged in; whether its
  session identifier is also renewed (as on log in, KI-006) is decided in the plan, with no
  visible change.
- **No account deletion**: the original has no way to delete an account, so neither does this
  feature.
