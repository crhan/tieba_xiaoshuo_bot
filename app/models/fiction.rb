# -*- encoding : utf-8 -*-
require "uri"
require "net/http"

class Fiction < ActiveRecord::Base
  class HTTPMovedPermanentlyError< StandardError; end

  attr_accessible :encoded_url, :name
  before_create :generate_encoded_url
  validates :name, :presence => true, :uniqueness => true
  has_many :users, :through => :subscriptions
  has_many :subscriptions
  has_many :chapters

  REGEX = /第.{1,18}[章节]/;

  def url
    "http://tieba.baidu.com/f?kw=#{self.encoded_url}"
  end

  def update_chapters chapter_list=get_new_chapters
    chapters = []
    chapter_list.each do |ch|
      chapter = Chapter.create(:fiction => self, :title => ch[:title], :thread_id => ch[:thread_id])
      chapters << chapter if chapter.valid?
    end
    !chapters.blank?
  end


  protected
  def generate_encoded_url
    self.encoded_url = URI.encode name.encode("gbk")
  end


  private
  def get_new_chapters body=fetch_tieba_response
    Nokogiri::HTML(body)
    .xpath(%|//img[@alt="置顶"]/../a|)
    .select {|e| REGEX.match e.content}
    .map do |e|
      {
        :thread_id   => e.attribute("href").value.match(/\d+/).to_s.to_i,
        :title => e.child.content.gsub(/^.*?(?=第)/,"").gsub(/\s+/," ")
      }
    end
  end

  def fetch_tieba_response
    # fetch resource, retry 3 times
    uri = URI(self.url)
    http = Net::HTTP.new(uri.host)
    retry_time = 0
    begin
      resp = http.get %|#{uri.path}?#{uri.query}|
      if resp.is_a?(Net::HTTPMovedPermanently)
        cookies = nil
        raise HTTPMovedPermanentlyError, %|Get cookie: "#{@@cookies}"|
      else
        resp.body.encode("utf-8", "gbk")
      end
    rescue HTTPMovedPermanentlyError => e
      Rails.logger.warn %|e.class found|
      retry
    rescue => e
      if retry_time< 3
        Rails.logger.error %|#{e.class}, #{e.message}, #{e.backtrace}|
          retry_time += 1
        Rails.logger.warn %|#{self.name} Retry #{retry_time} time(s)|
          sleep retry_time ** 4 + 5
        retry
      end
      raise HTTPResponseError, "三次 #{self.name}#get_response 均失败了"
    end
  end

  def cookies(resp=nil)
    @@cookies ||= resp
                  .get_fields('set-cookie')
                  .inject(Array.new) {|a,i|
                    a << i.split('; ').first
                  }.join('; ') rescue ""
  end
  def cookies=(data)
      @@cookies = data
  end
end
