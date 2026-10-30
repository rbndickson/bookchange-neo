# Rate limit counts are kept in the cache, so clear it to keep examples independent.
RSpec.configure do |config|
  config.before do
    Rails.cache.clear
  end
end
