# Bookchange

A web application for exchanging books, featuring a double opt-in system.

Made with Ruby on Rails.

## Installation

Install Ruby, Node.js, Yarn and PostgreSQL, checking the code for the correct versions.

- Install Ruby gems: `bundle install`
- Install JavaScript packages: `yarn install`
- Set up the database: `bin/rails db:prepare` (creates the database and loads the schema)

## Running the app in development

- `bin/dev` (starts the Rails server and the JavaScript and CSS watchers)

## Developing with an AI agent

AI agents work on this project inside a Docker Sandbox, using the `sbx` CLI, rather than directly
on the host.

- Sign in to Docker: `sbx login`
- From the project directory, start Claude Code in a sandbox: `sbx run claude`
  (the current directory is mounted as the sandbox's workspace)
- Inside the sandbox, set up the project with the Installation steps above
- List sandboxes: `sbx ls`
- Stop a sandbox without removing it: `sbx stop <name>`

## Running the tests

- `bundle exec rspec`

## Linting and formatting

CI runs the checks below, so run them before pushing.

| | Ruby | JavaScript | ERB |
|---|---|---|---|
| Tool | RuboCop | oxlint and oxfmt | Herb |
| Lint | `bundle exec rubocop` | `yarn lint:js` | `yarn lint:erb` |
| Lint and fix | `bundle exec rubocop -a` | `yarn lint:js:fix` | `yarn lint:erb:fix` |
| Format | `bundle exec rubocop -a` | `yarn format:js` | `yarn format:erb` |
| Check formatting | `bundle exec rubocop` | `yarn format:js:check` | `yarn format:erb:check` |

RuboCop handles both linting and formatting for Ruby.

## Security checks

- Static analysis of the Rails code: `bin/brakeman`
- Known vulnerabilities in Ruby gems: `bin/bundler-audit`
- Known vulnerabilities in JavaScript packages: `yarn audit`
