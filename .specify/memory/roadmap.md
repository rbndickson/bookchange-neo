# Bookchange Roadmap

The order to rebuild the features of the original application
(https://github.com/rbndickson/bookchange), following the order they were added in its commit
history. Each feature builds on the ones before it.

## How to use

- Work through the features in order, one `/speckit-specify` per feature.
- Update a feature's Status and Spec when its state changes.
- Statuses: Not started, Specified, Planned, Tasks ready, In progress, Done.
- The original's files are the reference for behavior and style (see the constitution,
  Principle I and Coding Style).

## Features

| # | Feature | Added in original | Original reference | Status | Spec |
|---|---|---|---|---|---|
| 1 | Sign up, log in and log out | 2016-01-06 – 01-08 | `UsersController#new/create`, `SessionsController`, `PagesController#front` | Done | [spec](../../specs/001-sign-up-log-in/spec.md) |
| 2 | Edit profile | 2016-01-13 | `UsersController#edit/update` | Not started | |
| 3 | Add a book, with ISBN lookup | 2016-01-13 – 01-20 | `BooksController#new/create/autofill`, `BookInformation`, `GoogleBook`, `WorldcatBook`, `PagesController#home` | Not started | |
| 4 | My Books: edit and remove books | 2016-01-21 – 01-22 | `PagesController#my_books`, `BooksController#edit/update/destroy` | Not started | |
| 5 | User page with their books | 2016-01-22 | `UsersController#show` | Not started | |
| 6 | Wantlist | 2016-01-25 – 01-26 | `WantlistItem`, `WantlistItemsController` | Not started | |
| 7 | Notifications | 2016-01-31 | `Notification`, `NotificationsController`, `WantlistItemNotificationCreator` | Not started | |
| 8 | Book page | 2016-02-01 | `BooksController#show` | Not started | |
| 9 | Find exchanges | 2016-02-02 | `PagesController#find_exchanges` | Not started | |
| 10 | Wantlist matching and exchanges | 2016-02-03 – 02-08 | `Exchange`, `ExchangeBook`, `ExchangesController`, `ExchangeBooksController#create` | Not started | |
| 11 | Sending and receiving books | 2016-02-09 – 02-24 | `ExchangeBooksController#update`, `BooksController#update` (sent), `BookNotificationCreator`, `ExchangeBookNotificationCreator` | Not started | |
| 12 | Search | 2016-02-24 – 02-25 | `BooksController#search`, `Book.search` | Not started | |
| 13 | Feedback | 2016-02-27 | `Feedback`, `FeedbacksController`, user page | Not started | |
| 14 | Password reset | 2016-02-29 | `ForgotPasswordsController`, `PasswordResetsController`, `AppMailer` | Not started | |
| 15 | Front and Learn More pages | 2016-03-02, redesigned 2017-12 | `PagesController#front/learn_more` | Not started | |

## Notes

- Notifications (7) start with the Wantlist addition notification; later features add their own
  notification types (exchange confirmed, book sent, book received, book taken).
- Feature 1 needs a simple front page as the root page; its full content comes in feature 15.
- Responsive design is part of every feature, not a separate step (the original added it at the
  end, in 2016-03).
- Known technology gaps to resolve in the relevant plans: password hashing (1), book information
  APIs, including the retired WorldCat API (3), search without Elasticsearch (12), email
  delivery (14).

## Not rebuilt

- UI mockup pages (`UiController`, `/ui`): design prototypes from before the features were built.
- Hosting and deployment setup (Heroku, CircleCI, staging environment): replaced by the new
  project's own setup.
