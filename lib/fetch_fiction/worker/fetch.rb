#coding: utf-8
require 'nokogiri'

module FetchFiction
  class Fetch
    include Sidekiq::Worker
#    sidekiq_options :retry => false
    sidekiq_options :queue => :fetch_tieba

    # fetch thread from tieba.baidu.com and check if new thread had come.
    # if true then enqueue the Send Class
    def perform fiction_id
      @update = false
      fiction = Fiction.find( :id => fiction_id )
      fiction_name = fiction.name
      $logger.info "Running Fetch #{fiction_name}"

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
          $logger.warn %|Retry #{times} time(s)|
          retry
        end
      end

      # test the response
      reg = /第.{1,18}[章节]/;
      doc = Nokogiri::HTML(body)
            .xpath(%|//div[@class="th_lz"]/img[@alt="置顶"]/../a|)
            .select {|e| reg.match e.content}
      if doc
        $logger.info "#{doc.size} chapter(s) find from #{fiction.name}"
        doc.each do |e|
          thread_id = e.attribute("href").value.match(/\d+/).to_s
          thread_name = e.child.content.gsub(/^\s/,"")
          $logger.info %|thread_id: #{thread_id},  threadname: #{thread_name}|
          # New charper find, set update flag
          unless CheckList.find(:thread_id => thread_id.to_i)
            nc = CheckList.new
            nc.thread_id = thread_id.to_i
            nc.thread_name = thread_name
            nc.fiction = fiction
            nc.save
            @update = true
          end
        end
      end
      if @update
        Send.perform_in 5, fiction_id
        $logger.info "Enqueue Send #{fiction_name}"
      else
        $logger.info "No update in Fetch #{fiction_name}"
      end
    end

  end
end
