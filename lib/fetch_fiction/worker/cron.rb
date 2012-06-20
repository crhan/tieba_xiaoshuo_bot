# coding: utf-8
class CronFetch
  include Sidekiq::Worker
  sidekiq_options :retry => false
  sidekiq_options :queue => :cronJob

  def perform
    Fiction.each_entry do |e|
      Fetch.perform_async e.id
    end
  end
end
