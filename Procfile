web:  bundle exec rackup config/config.ru
sidekiq: bundle exec sidekiq -r ./sidekiq.rb -q cronJob -q send -v
sidekiqCron: bundle exec clockwork clock.rb
