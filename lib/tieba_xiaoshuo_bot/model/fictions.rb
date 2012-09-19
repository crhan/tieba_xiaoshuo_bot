# coding: utf-8
require "uri"
require 'net/http'

module TiebaXiaoshuoBot
  class Fiction < Sequel::Model
    class HTTPResponseError < StandardError; end
    class NoContentError < StandardError; end
    class ChapterExistError < StandardError; end
    class HTTPMovedPermanentlyError< StandardError; end

    plugin :validation_helpers
    plugin :schema
    many_to_many :users, :join_table => :subscriptions
    one_to_many :check_lists
    include BaseModel
    REGEX = /第.{1,18}[章节]/;

    # primary_key :id
    # index :id
    # String :name
    # String :encode_url
    # Time :created_at
    # Time :updated_at

    def subscriptions
      Subscription.filter(:fiction => self)
    end

    def url
      "http://tieba.baidu.com/f?kw=#{encode_url}"
    end

    def update
      new_chapters.each do |ch|
        begin
          create_chapter ch[:thread_id], ch[:thread_name]
        rescue ChapterExistError
          false
        end
      end
      true
    rescue NoContentError => e
      $logger.debug "NoContentError: #{self.name}.parse_fiction_chapter 没抓到信息呢亲"
      false
    rescue HTTPResponseError => e
      $logger.debug "HTTPResponseError: #{e.message}"
      false
    end

    deprecate :fetch, :update

    private
    def validate
      super
      validates_presence :name
      validates_unique :name
    end

    def before_create
      super
      self.encode_url = URI.encode name.encode("gbk")
    end

    def cookies resp
      resp
        .get_fields('set-cookie')
        .inject(Array.new) { |a,i|
          a.push(i.split('; ').first)
        }
        .join('; ');
    end

    def get_response
      # fetch resource, retry 3 times
      begin
        uri = URI(self.url)
        http = Net::HTTP.new(uri.host)
        if !!@@cookies ||= nil
          resp = http.get(%|#{uri.path}?#{uri.query}|, { "Cookie" => @@cookies })
        else
          resp = http.get("#{uri.path}?#{uri.query}")
        end

        if resp.is_a?(Net::HTTPMovedPermanently)
          @@cookies = cookies(resp)
          raise HTTPMovedPermanentlyError, %|Get cookie: "#{@@cookies}"|
        else
          resp.body.encode("utf-8", "gbk")
        end
      rescue HTTPMovedPermanentlyError => e
        retry
      rescue => e
        retry_time ||= 0
        if retry_time< 3
          $logger.error %|#{e.inspect}, #{__LINE__}|
          retry_time += 1
          $logger.warn %|Retry #{retry_time} time(s)|
          sleep retry_time ** 4 + 5
          retry
        end
        raise HTTPResponseError, "三次 #{self.name}#get_response 均失败了"
      end
    end


    def new_chapters body=get_response
      result = Nokogiri::HTML(body)
      .xpath(%|//img[@alt="置顶"]/../a|)
      .select {|e| REGEX.match e.content}
      .map do |e|
        {
          :thread_id   => e.attribute("href").value.match(/\d+/).to_s.to_i,
          :thread_name => e.child.content.gsub(/^.*?(?=第)/,"").gsub(/\s+/," ")
        }
      end

      raise NoContentError, "#{__FILE__}, line #{__LINE__}: 没有新的章节喔" if result.empty?
      result
    end

    def create_chapter id, name
      id = id.to_i if id.respond_to?(:to_i)
      raise ChapterExistError, ":thead_id #{id} exist" if CheckList.find(:thread_id => id)
      nc = CheckList.new
      nc.thread_id = id
      nc.thread_name = name
      nc.fiction = self
      nc.save
    end
    Fiction.set_dataset DB[:fictions]
  end
end
