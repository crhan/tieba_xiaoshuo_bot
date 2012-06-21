web:  bundle exec rackup config/config.ru
sidekiq: bundle exec sidekiq -r ./sidekiq.rb -q fetch -q send -q cronJob -q log
cron: bundle exec clockwork clock.rb
