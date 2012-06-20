#coding: utf-8
require 'nokogiri'

module FetchFiction
  class Fetch
    include Sidekiq::Worker
    sidekiq_options :retry => false
    sidekiq_options :queue => :fetch_tieba

    def perform fiction_id
      fiction = Fiction.find( :id => fiction_id )
      # fetch resource, retry 3 times
      require 'net/http'
      begin
        times ||= 0
        body = Net::HTTP.get_response(URI.parse(fiction.url)).body.encode("utf-8", "gbk")
        $logger.debug "Get #{fiction.url} response lengh #{body.size}"
      rescue => e
        if times < 3
          $logger.error e.inspect
          times += 1
          sleep 5 ** times
          $logger.debug %|Retry #{times} time(s)|
          retry
        end
      end
      reg = /第.{1,18}[章节]/;
      doc = Nokogiri::HTML(body)
      .xpath(%|//div[@class="th_lz"]/img[@alt="置顶"]/../a|)
      .select {|e| reg.match e.content}
      if doc
        $logger.debug %|#{doc.size} chapter(s) find from #{fiction.name}|
          doc.each do |e|
          thread_id = e.attribute("href").value.match(/\d+/).to_s
          thread_name = e.child.content.gsub(/^\s/,"")
          $logger.debug %|thread_id: #{thread_id},  threadname: #{thread_name}|
          begin
            CheckList.find_or_create(
              :fiction => fiction,
              :thread_id => thread_id,
              :thread_name => thread_name
            )
          rescue => e
            $logger.error e.message
            $logger.error e.backtrace
          end
          end
        # TODO call send message here if doc.nil?
      end # if doc end
    end
  end
end
