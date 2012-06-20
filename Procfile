web:  bundle exec rackup config/config.ru
sidekiq: bundle exec sidekiq -r ./sidekiq.rb -q cronJob -q fetch_tieba
sidekiqCron: bundle exec clockwork clock.rb
