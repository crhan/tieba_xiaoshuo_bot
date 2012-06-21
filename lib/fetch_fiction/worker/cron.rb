# coding: utf-8
module FetchFiction
  class CronFetch
    @queue = :cronJob

    def self.perform
      $logger.info 'Running CronFetch.'
      Fiction.each_entry do |e|
        Resque.enqueue Fetch, e.id
        $logger.info "Enqueue Fetch #{Fiction.find(:id => e.id).name}"
      end
    end
  end
end
