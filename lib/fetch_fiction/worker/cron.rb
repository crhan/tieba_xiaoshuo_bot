# coding: utf-8
module FetchFiction
  class CronFetch
    @queue = :cronJob

    def self.perform
      Fiction.each_entry do |e|
        Resque.enqueue Fetch, e.id
      end
    end
  end
end
