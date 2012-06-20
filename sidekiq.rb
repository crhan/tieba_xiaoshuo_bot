require 'active_support/all'
require './lib/fetch_fiction'
Sidekiq.configure_server do |config|
  config.redis = { :namespace => 'fiction', :url => 'redis://localhost:6379/' }
end

Sidekiq.configure_client do |config|
  config.redis = { :namespace => 'fiction' }
end

Dir.glob './**/worker/*.rb' do |f|
  require f
end
