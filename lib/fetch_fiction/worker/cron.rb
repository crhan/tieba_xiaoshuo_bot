# coding: utf-8
module FetchFiction
  class CronFetch
    include Sidekiq::Worker
    sidekiq_options :queue => :cronJob
    sidekiq_options :retry => false

    def perform
      $logger.info 'Running CronFetch.'
      # check active subscription
      Subscription.active_fictions.each do |s|
        fiction = s.fiction
        Fetch.perform_async fiction.id
        $logger.info "Enqueue Fetch #{Fiction.find(:id => fiction.id).name}"
      end
    end
  end

  class OnlineCheck
    include Sidekiq::Worker
    sidekiq_options :queue => :cronJob
    sidekiq_options :retry => false

    def perform
      $logger.warn "Reconnected" if  $bot.reconnect
    end
  end
end
