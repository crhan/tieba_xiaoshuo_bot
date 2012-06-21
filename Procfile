web:  bundle exec rackup config/config.ru
sidekiq_cron: bundle exec sidekiq -r ./sidekiq_cron.rb -q cronJob -q fetch -v
sidekiq_bot: bundle exec sidekiq -r ./sidekiq_bot.rb -q send -v -c 1
sidekiqCron: bundle exec clockwork clock.rb
