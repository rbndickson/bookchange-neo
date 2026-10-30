source 'https://rubygems.org'

gem 'rails', '~> 8.1.4'
gem 'propshaft'
gem 'pg', '~> 1.1'
gem 'puma', '>= 5.0'
gem 'jsbundling-rails'
gem 'turbo-rails'
gem 'stimulus-rails'
gem 'cssbundling-rails'

gem 'bcrypt', '~> 3.1.7'

gem 'tzinfo-data', platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem 'solid_cache'
gem 'solid_queue'
gem 'solid_cable'

gem 'bootsnap', require: false

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[ mri windows ], require: 'debug/prelude'

  gem 'bundler-audit', require: false
  gem 'brakeman', require: false # Static analysis for security vulnerabilities

  gem 'rspec-rails'
  gem 'fabrication'
  gem 'capybara'
  gem 'cuprite'

  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'
end
