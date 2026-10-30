# Feature Specification: Sign Up, Log In and Log Out

**Feature Branch**: `001-sign-up-log-in`

**Created**: 2026-10-30

**Status**: Complete

**Input**: User description: "We will do the first feature on the roadmap" (Roadmap feature 1:
Sign up, log in and log out)

## Original Behavior Reproduced

This feature reproduces the original application's account and session behavior, added
2016-01-06 – 01-08 and refined later (reference: `UsersController#new/create`,
`SessionsController`, `ApplicationController#current_user/require_user/access_denied`,
`PagesController#front`, `User` validations, `shared/_header` and `shared/_messages`, and the
`user_registers` and `user_signs_in` feature specs). Where the original changed after the
feature was first added, the final version of that behavior is the reference (e.g. the app name
"Bookchange" rather than the early "Bookswap", and no "You are now logged in." message).

Parts of the original's pages that belong to later roadmap features are left out until those
features are built (see Assumptions). Approved fixes and accepted behavior are listed under
Differences from the Original (KI-001 to KI-015).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Sign up (Priority: P1)

A visitor who wants to exchange books creates an account by giving their email, a username and
a password (entered twice). After signing up they are taken to the log in page with a message
telling them they have joined and can now log in.

**Why this priority**: No other feature can be used without an account; it is the entry point
to the whole application.

**Independent Test**: From the front page, follow "Sign Up", complete the form and confirm the
account is created and the "You have joined Bookchange, you can now log in." message is shown on
the log in page.

**Acceptance Scenarios**:

1. **Given** a visitor on the front page, **When** they click "Sign Up" in the header, **Then**
   they see the Sign Up form with Email, Username, Password and Confirm Password fields.
2. **Given** a visitor on the front page, **When** they click the "Sign Up" button in the main
   front page content, **Then** they see the Sign Up form.
3. **Given** a visitor on the Sign Up form, **When** they enter a new email, a new username and
   a matching password of at least 8 characters and click "Sign Up", **Then** their account is
   created, they are taken to the Log In page and see "You have joined Bookchange, you can now
   log in."
4. **Given** a visitor on the Sign Up form, **When** they leave any field blank and click
   "Sign Up", **Then** no account is created and they see the form again with an error naming
   each blank field next to it (e.g. "Email can't be blank"), with the other values they entered kept (except passwords).
5. **Given** a visitor on the Sign Up form, **When** the password and Confirm Password do not
   match, **Then** no account is created and they see "The passwords do not match" (changed in
   feature 2, KI-014).
6. **Given** a visitor on the Sign Up form, **When** the password is shorter than 8 characters,
   **Then** no account is created and they see "Password is too short (minimum is 8
   characters)".
7. **Given** an existing account, **When** a visitor signs up with the same email, **Then** no
   account is created and they see "Email cannot be used" (KI-011); **When** they sign up with
   the same username, **Then** no account is created and they see "Username has already been
   taken".
8. **Given** an account with the email `alice@example.com`, **When** a visitor signs up with
   ` Alice@Example.com `, **Then** no account is created and they see "Email cannot be used"
   (KI-001, KI-011).
9. **Given** a visitor on the Sign Up form, **When** they enter an email in an invalid format
   (e.g. `alice`), **Then** no account is created and they see "Email is invalid" (KI-005).
10. **Given** a visitor on the Sign Up form, **When** the password is longer than 72
    characters, or longer than 72 bytes (e.g. many accented letters or emoji), **Then** no
    account is created and they see "Password is too long (maximum is 72 characters)"
    (KI-004).
11. **Given** a logged-in user, **When** they visit the Sign Up page, **Then** they are taken to
    the home page instead (KI-003).
12. **Given** an account with the username `alice`, **When** a visitor signs up with the
    username `Alice`, **Then** no account is created and they see "Username has already been
    taken" (KI-009).
13. **Given** a visitor on the Sign Up form, **When** they enter an email longer than 254
    characters or a username longer than 20 characters, **Then** no account is created and they
    see "Email is too long (maximum is 254 characters)" or "Username is too long (maximum
    is 20 characters)" (KI-010).
14. **Given** a visitor on the Sign Up form, **When** they enter a one-character username,
    **Then** no account is created and they see "Username is too short (minimum is 2
    characters)" (KI-010).

---

### User Story 2 - Log in (Priority: P1)

A user with an account logs in with their email and password and is taken to their home page.
Wrong details show a single generic error so the page does not reveal whether an email has an
account.

**Why this priority**: Every later feature acts on behalf of a logged-in user; signing up alone
gives no value without logging in.

**Independent Test**: With an existing account, follow "Log In" from the front page, enter the
email and password and confirm the home page is shown with the username in the header.

**Acceptance Scenarios**:

1. **Given** a visitor on the front page, **When** they click "Log In" in the header, **Then**
   they see the Log In form with Email and Password fields.
2. **Given** a registered user on the Log In form, **When** they enter their email and correct
   password and click "Log In", **Then** they are taken to the home page and the header shows
   their username.
3. **Given** a registered user on the Log In form, **When** they enter their email and a wrong
   password, **Then** they are returned to the Log In form and see "Log in error, please try
   again."
4. **Given** a visitor on the Log In form, **When** they enter an email with no account,
   **Then** they are returned to the Log In form and see the same "Log in error, please try
   again." message.
5. **Given** a logged-in user, **When** they visit the Log In page, **Then** they are taken to
   the home page instead.
6. **Given** a visitor who is not logged in, **When** they visit the home page directly,
   **Then** they are taken to the Log In page and see "You must be logged in to do that."
7. **Given** a user who signed up with `alice@example.com`, **When** they log in with
   ` Alice@Example.com ` and the correct password, **Then** they are taken to the home page
   (KI-001).
8. **Given** 10 log in attempts from the same connection in the last 3 minutes, **When**
   another log in is attempted from that connection, even with correct details, **Then** the
   user is not logged in, is returned to the Log In page and sees "Try again later." (KI-007).

---

### User Story 3 - Log out (Priority: P2)

A logged-in user logs out from the user menu in the header, ending their session and returning
to the front page.

**Why this priority**: Needed for shared devices and to switch accounts, but the application is
usable for a single session without it.

**Independent Test**: Log in, open the user menu in the header, click "Log Out" and confirm the
front page is shown with "You have logged out." and the logged-out header.

**Acceptance Scenarios**:

1. **Given** a logged-in user, **When** they open the user menu (showing their username) in the
   header, **Then** they see a "Log Out" option.
2. **Given** a logged-in user, **When** they click "Log Out", **Then** their session ends, they
   are taken to the front page, see "You have logged out." and the header shows "Sign Up" and
   "Log In" again.
3. **Given** a user who has logged out, **When** they visit the home page, **Then** they are
   taken to the Log In page and see "You must be logged in to do that."

---

### User Story 4 - Front page and header (Priority: P2)

Visitors arrive at a simple front page that introduces Bookchange and invites them to sign up.
The header shows different options depending on whether the user is logged in.

**Why this priority**: Gives the other stories a starting point; its full content arrives with
roadmap feature 15.

**Independent Test**: Visit the root address logged out and logged in and confirm the front page
content and the header for each state.

**Acceptance Scenarios**:

1. **Given** a visitor, **When** they visit the root address, **Then** they see the heading
   "Exchange books you have read for something new.", the text "Save space in your home and help
   the environment without giving up paper books." and a "Sign Up" button.
2. **Given** a visitor, **When** they view any page, **Then** the header shows the Bookchange
   name and book icon linking to the front page, and "Sign Up" and "Log In" buttons.
3. **Given** a logged-in user, **When** they view any page, **Then** the header shows the
   Bookchange name and book icon linking to the home page, and a user menu labelled with their
   username containing "Log Out".
4. **Given** any page showing a message (success, error or information), **When** the user
   closes the message, **Then** it is dismissed.

---

### Edge Cases

- Leading or trailing spaces in the email on Sign Up or Log In are removed (KI-001).
- The same email entered with different letter case (e.g. `Alice@Example.com` vs
  `alice@example.com`) is the same account: signing up again with it shows "Email cannot be used",
  and logging in with either works (KI-001).
- A logged-in user visiting the Sign Up page is taken to the home page (KI-003).
- A failed Log In clears the entered email (the original redirects back to an empty form);
  this is reproduced.
- Very long passwords: passwords longer than 72 characters, or longer than the password
  storage limit of 72 bytes, are rejected with an error rather than silently shortened
  (KI-004).
- An email in an invalid format (e.g. `alice`) is rejected with "Email is invalid", even if the
  browser's own check is bypassed (KI-005).
- Usernames that differ only in letter case (`Alice` and `alice`) count as the same username
  for uniqueness, but each is shown as the user typed it (KI-009).
- Leading or trailing spaces in a username are removed before it is checked and saved, so
  ` alice ` is the same username as `alice` and ` a ` is too short (KI-015).
- Repeated log in attempts from one connection are limited; after 10 in 3 minutes, further
  attempts are refused with "Try again later." until the 3 minutes have passed (KI-007).
- A user whose session refers to an account that no longer exists is treated as logged out
  (accounts cannot be deleted in the original, so this only guards against stale sessions).
- Closing the browser ends the session, as in the original; there is no "remember me".

## Differences from the Original

The original's bugs, quirks and weaknesses found while writing this spec (its Known Issues),
with the project owner's decision on each, approved on 2026-10-30. KI numbers are referred to
by the requirements below.

### Fixes and improvements

Where this app deliberately behaves differently from the original.

- **KI-001 – Email is case- and space-sensitive**: the original stores the email exactly as
  typed, checks uniqueness case-sensitively and looks up the exact email on Log In, so
  `Alice@example.com` and `alice@example.com` can be two accounts and a user who signed up with
  capitals cannot log in typing lowercase. Decision: **fix** – emails are stored in lowercase
  with surrounding spaces removed, on Sign Up and Log In, so uniqueness and Log In ignore letter
  case and surrounding spaces (FR-004, FR-008).
- **KI-002 – Log out is a plain link (GET request)**: any page or image link pointing at the log
  out address can log a user out without their action. Decision: **fix** – Log Out is a form
  submission protected against cross-site requests, looking the same to the user as a menu
  item (FR-013).
- **KI-003 – Sign Up is shown to logged-in users**: the original redirects logged-in users away
  from Log In but not from Sign Up, so a logged-in user can create another account while still
  logged in as the first. Decision: **fix** – logged-in users visiting Sign Up are taken to the
  home page, as with Log In (FR-011).
- **KI-004 – Long passwords silently shortened**: the original's password storage only uses the
  first 72 bytes and the original disabled the check, so longer passwords are silently
  shortened. Decision: **fix** – passwords are limited to 72 characters, and passwords over
  72 bytes are also rejected, with an error (FR-003).
- **KI-005 – No email format check on the server**: the original relies only on the browser's
  email field. Decision: **fix** – the email format is also checked on the server, and an
  invalid email is rejected with "Email is invalid" (FR-002a).
- **KI-006 – Session not renewed on log in**: the original keeps the same session identifier
  before and after logging in. Decision: **fix** – a new session is started on log in and log
  out (a security improvement with no visible change) (FR-012a).
- **KI-007 – Unlimited log in attempts**: the original never limits failed log ins, so
  passwords can be guessed without limit. Decision: **fix** – after 10 log in attempts from one
  connection within 3 minutes, further attempts are refused with "Try again later." (FR-010a).
- **KI-008 – Log in speed shows whether an email has an account**: the original fails at once
  for an unknown email but checks the password first for a known one, so timing log in attempts
  shows which emails have accounts. Decision: **fix** – a failed log in takes about the same
  time whether or not the email has an account (FR-010, SC-004).
- **KI-009 – Usernames differing only in letter case**: the original allows `Alice` and `alice`
  as separate users, letting one user pose as another where usernames are shown. Decision:
  **fix** – username uniqueness ignores letter case; usernames are still shown as typed
  (FR-004).
- **KI-010 – No length limits for email or username**: the original accepts values of any
  length. Decision: **fix** – email is limited to 254 characters (the longest the email
  standards allow) and username to 2–20 characters (FR-002b).
- **KI-014 – Error messages do not name the field**: the original shows only the message next
  to each field (e.g. "can't be blank"). Decision: **fix** – each message starts with the
  field's name (e.g. "Email can't be blank"); the password confirmation is named "Confirm
  Password", as its label (FR-007). Changed in feature 2 (approved 2026-10-30): a password
  mismatch shows "The passwords do not match", without a field name, so the same message fits
  Sign Up and Change Password.
- **KI-015 – Usernames keep surrounding spaces**: the original saves the username exactly as
  typed, so ` alice ` and `alice` are different usernames that look the same. Decision: **fix**
  – surrounding spaces are removed from the username before it is checked and saved, as with
  emails (FR-004).

### Accepted behavior

Where this app deliberately keeps the original's behavior (KI-011 changes only the wording of
a message).

- **KI-011 – Sign Up shows when an email is already registered**: the original shows "has
  already been taken" on Email, so anyone can check whether an email has an account. Hiding it
  fully would need an email confirmation step the original does not have. Decision:
  **reproduce**, but change the message to "Email cannot be used" (FR-004a).
- **KI-012 – No server-side session timeout**: a session only ends on log out or when the
  browser is closed, and browsers that restore tabs can keep it alive for a long time.
  Decision: **reproduce**.
- **KI-013 – Weak passwords are allowed**: the only password rule is a minimum of 8 characters,
  so common passwords such as `password` are accepted. Decision: **reproduce**.

## Requirements *(mandatory)*

### Functional Requirements

**Sign up**

- **FR-001**: Visitors MUST be able to create an account with an email, a username, a password
  and a password confirmation.
- **FR-002**: Email, username, password and password confirmation MUST all be required.
- **FR-002a**: The email MUST be in a valid email format, checked on the server; an invalid
  email MUST be rejected with "Email is invalid" (KI-005).
- **FR-002b**: The email MUST be no more than 254 characters, and the username MUST be 2–20
  characters (KI-010).
- **FR-003**: The password MUST be 8–72 characters and no more than 72 bytes (KI-004), and
  MUST match the confirmation.
- **FR-004**: Email and username MUST each be unique across all accounts. Emails MUST be stored
  in lowercase with surrounding spaces removed, so uniqueness ignores letter case (KI-001).
  Username uniqueness MUST ignore letter case, while usernames are shown as typed (KI-009).
  Usernames MUST be stored with surrounding spaces removed (KI-015).
- **FR-004a**: Signing up with an email that already has an account MUST show the error "Email
  cannot be used" (KI-011).
- **FR-005**: Passwords MUST be stored so that they cannot be read back (one-way protected), and
  MUST never be shown or re-filled in forms.
- **FR-006**: On successful sign up the visitor MUST be taken to the Log In page with the message
  "You have joined Bookchange, you can now log in." and MUST NOT be logged in automatically.
- **FR-007**: On failed sign up the form MUST be shown again with an error next to each invalid
  field, starting with the field's name (KI-014), and the non-password values kept.

**Log in and log out**

- **FR-008**: Users MUST be able to log in with their email and password; the email entered MUST
  be matched ignoring letter case and surrounding spaces (KI-001).
- **FR-009**: On successful log in the user MUST be taken to the home page.
- **FR-010**: On failed log in (unknown email or wrong password) the user MUST be returned to
  the Log In page with the message "Log in error, please try again.", without revealing which
  detail was wrong, and MUST take about the same time whether or not the email has an account
  (KI-008).
- **FR-010a**: Log in attempts MUST be limited to 10 per connection within 3 minutes; attempts
  over the limit MUST be refused, returning the user to the Log In page with the message "Try
  again later." (KI-007).
- **FR-011**: A logged-in user visiting the Log In or Sign Up page MUST be taken to the home
  page (Sign Up: KI-003).
- **FR-012**: A logged-in user MUST stay logged in across pages until they log out or close the
  browser.
- **FR-012a**: A new session MUST be started when a user logs in and when they log out
  (KI-006).
- **FR-013**: Logged-in users MUST be able to log out from the user menu in the header; logging
  out MUST end the session, take them to the front page and show "You have logged out." Log Out
  MUST be a form submission protected against cross-site requests, not a plain link, and MUST
  look like the other menu items (KI-002).
- **FR-014**: Pages that need a logged-in user (in this feature, the home page) MUST send
  visitors to the Log In page with the message "You must be logged in to do that."

**Pages and layout**

- **FR-015**: The root address MUST show the front page, visible to everyone, with the heading,
  lead text and "Sign Up" button described in User Story 4.
- **FR-016**: The home page MUST be available to logged-in users only, and MUST show their
  username as a temporary home page until roadmap feature 3 replaces it.
- **FR-017**: The header MUST show the Bookchange name and icon on every page, linking to the
  front page for visitors and to the home page for logged-in users.
- **FR-018**: The header MUST show "Sign Up" and "Log In" for visitors, and a user menu labelled
  with the username containing "Log Out" for logged-in users.
- **FR-019**: Success, error and information messages MUST be shown at the top of the next page
  in matching styles (success, danger, info) and be dismissible.
- **FR-020**: The Sign Up, Log In, front and home pages and the header MUST be usable on phone,
  tablet and desktop screen widths.
- **FR-021**: The page title MUST be "Bookchange".

### Key Entities

- **User**: a person with an account. Has an email (unique, used to log in), a username (unique,
  shown to other users in later features) and a protected password. Later features add books,
  Wantlist items, exchanges, notifications and feedback to the user.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A new visitor can go from the front page to a created account and logged in in
  under 2 minutes.
- **SC-002**: 100% of the acceptance scenarios in this spec pass as automated browser tests.
- **SC-003**: No password can be recovered from stored account data.
- **SC-004**: A failed log in shows the same message, and takes about the same time, whether the
  email exists or not, in 100% of cases.
- **SC-005**: Every page in this feature can be used at a 375 pixel wide screen without
  horizontal scrolling.

## Assumptions

- **Scope of pages**: only the parts of the original's pages that belong to this feature are
  built. Left out until their roadmap features: the front page's "Learn More" button and book
  lists (15), the header's search (12), notifications (7), "Add book" (3), My Books (4),
  Wantlist (6), Exchanges (9, 10) links, and the user menu's "Update Account" (2) and "My Page"
  (5) entries, and the Log In page's "Forgot password?" link (14).
- **Home page**: until feature 3 adds "Latest Additions", the home page is a temporary page
  showing the username, as in the original at the time this feature was added.
- **Sign Up form labels**: "Email", "Username", "Password", "Confirm Password" and a "Sign Up"
  button; Log In form: "Email", "Password" and a "Log In" button, as in the original.
- **Error messages** use the standard wording shown in the original ("can't be blank", "is too
  short (minimum is 8 characters)", "has already been taken"), after the field's name (KI-014),
  except the duplicate email message (KI-011) and the password mismatch message ("The passwords
  do not match", feature 2).
- **No account token**: the original also generated a random token for each user on sign up; it
  is only used for password reset, so it is left to roadmap feature 14.
- **Session length**: the session lasts until log out or the browser is closed, as in the
  original (KI-012); a longer-lived "remember me" session would be a behavior change needing
  approval.
- **Password protection technology** (the original used bcrypt, not currently in the project)
  is decided in the plan; adding a gem needs the project owner's approval.
