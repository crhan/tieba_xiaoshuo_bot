#coding: utf-8
require 'nokogiri'

module TiebaXiaoshuoBot
  module Worker
    class Fetch
      include Sidekiq::Worker
      sidekiq_options :retry => false
      sidekiq_options :queue => :fetch

      # fetch thread from tieba.baidu.com and check if new thread had come.
      # if true then enqueue the Send Class
      def perform fiction_id
        fiction = Fiction.find( :id => fiction_id )
        fiction_name = fiction.name
        $logger.info "Running Fetch #{fiction_name}"

        # fetch and see if needs to send
        Send.perform_async fiction_id if fiction.fetch
      end

    end
  end
end
