# coding: utf-8
class CronFetch
  @queue = :cron

  def self.perform
    Fiction.each_entry do |e|
      Resque.enqueue Fetch, e.id
    end
  end
end
