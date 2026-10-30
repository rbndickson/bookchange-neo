require 'capybara/rspec'
require 'capybara/cuprite'

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(app, window_size: [1200, 800], browser_options: { 'no-sandbox': nil })
end

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :cuprite
