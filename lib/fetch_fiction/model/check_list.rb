# coding: utf-8
module FetchFiction
  class CheckList < Sequel::Model
    plugin :validation_helpers
    plugin :schema
    many_to_one :fiction

    unless table_exists?
      set_schema do
        Integer :thread_id, :primary_key => true
        foreign_key :fiction_id, :fictions
        String :thread_name
        Time :created_at
      end
      create_table
    end
    def to_s
      %|#{self.fiction.name}\n#{self.thread_name}, http://wapp.baidu.com/m?kz=#{thread_id}|
    end

    def validate
      validates_presence [:thread_id, :thread_name, :fiction_id]
    end

    def before_save
      self.created_at ||= Time.now
      super
    end

    # return 5 Fiction Thread object array by reverse order
    def self.find_by_fiction fiction, return_num = 5
      if fiction.instance_of? Fiction
        self.filter(:fiction => fiction)
      elsif fiction.instance_of? Fixnum
        self.filter(:fiction_id => fiction)
      elsif fiction.instance_of? String
        self.filter(:fiction_id => fiction.to_i)
      else
        raise TypeError, "Need a Fiction object or a Fixnum refer to fiction_id. But I got a #{fiction.class}"
      end.order(:thread_id).reverse.limit(return_num).all.reverse
    end
  end
end
