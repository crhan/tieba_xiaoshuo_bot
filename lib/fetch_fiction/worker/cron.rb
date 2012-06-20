# coding: utf-8
module FetchFiction
  class CronFetch
    include Sidekiq::Worker
    sidekiq_options :retry => false
    sidekiq_options :queue => :cronJob

    def perform
      Fiction.each_entry do |e|
        Fetch.perform_in 5, e.id
      end
    end
  end
end
