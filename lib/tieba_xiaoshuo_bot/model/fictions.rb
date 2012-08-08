# coding: utf-8
require "uri"
module TiebaXiaoshuoBot
  class Fiction < Sequel::Model
    plugin :validation_helpers
    plugin :schema
    many_to_many :users, :join_table => :subscriptions
    one_to_many :check_lists
    include BaseModel

    # primary_key :id
    # index :id
    # String :name
    # String :encode_url
    # Time :created_at
    # Time :updated_at

    def validate
      super
      validates_presence :name
      validates_unique :name
    end

    def before_create
      super
      self.encode_url = URI.encode name.encode("gbk")
    end

    def subscriptions
      Subscription.filter(:fiction => self)
    end
    def url
      "http://tieba.baidu.com/f?kw=#{encode_url}"
    end

    def fetch
      # fetch resource, retry 3 times
      require 'net/http'
      begin
        times ||= 0
        body = Net::HTTP.get_response(URI.parse(self.url)).body.encode("utf-8", "gbk")
        $logger.debug "Get #{self.url} response lengh #{body.size}"
      rescue => e
        if times < 3
          $logger.error e.inspect
          times += 1
          sleep 5 ** times
          $logger.warn %|Retry #{times} time(s)|
          retry
        end
      end

      update = false
      # test the response
      reg = /第.{1,18}[章节]/;
      doc = Nokogiri::HTML(body)
            .xpath(%|//div[@class="th_lz"]/img[@alt="置顶"]/../a|)
            .select {|e| reg.match e.content}
            .map do |e|
              {
                :thread_id   => e.attribute("href").value.match(/\d+/).to_s,
                :thread_name => e.child.content.gsub(/^.*?(?=第)/,"").gsub(/\s+/," ")
              }
            end
      if doc
        $logger.info "#{doc.size} chapter(s) find from #{self.name}"
        doc.each do |e|
          thread_id   = e[:thread_id]
          thread_name = e[:thread_name]
          $logger.info %|thread_id: #{thread_id},  threadname: #{thread_name}|
          # New charper find, set update flag
          unless CheckList.find(:thread_id => thread_id.to_i)
            # find checklist has the same name and make them false
            nc = CheckList.new
            nc.thread_id = thread_id.to_i
            nc.thread_name = thread_name
            nc.fiction = self
            nc.save
            update = true
          end
        end
      end
      if update
        $logger.info "Enqueue Send #{self.name}"
      else
        $logger.info "No update in Fetch #{self.name}"
      end
      update
    end
  end
  Fiction.set_dataset DB[:fictions]
end
