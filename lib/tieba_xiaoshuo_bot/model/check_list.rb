# coding: utf-8
module TiebaXiaoshuoBot
  class CheckList < Sequel::Model
    plugin :validation_helpers
    plugin :schema
    many_to_one :fiction
    include BaseModel

    # Integer :thread_id, :primary_key => true
    # foreign_key :fiction_id, :fictions
    # String :thread_name
    # Time :created_at
    # Time :updated_at

    def to_s
      %|#{self.fiction.name}\n#{self.thread_name}, http://wapp.baidu.com/m?kz=#{thread_id}|
    end

    def validate
      validates_presence [:thread_id, :thread_name, :fiction_id]
    end

    def before_create
      super
      CheckList.filter(:thread_name => self.thread_name, :fiction_id => self.fiction_id).update(:active => false)
    end

    # return 5 Fiction Thread object array by reverse order
    def self.find_by_fiction fiction, last_check
      if fiction.instance_of? Fiction
        self.filter(:fiction => fiction)
      elsif fiction.instance_of? Fixnum
        self.filter(:fiction_id => fiction)
      elsif fiction.instance_of? String
        self.filter(:fiction_id => fiction.to_i)
      else
        raise TypeError, "Need a Fiction object or a Fixnum refer to fiction_id. But I got a #{fiction.class}"
      end.filter{thread_id > last_check}
    end
  end
  CheckList.set_dataset DB[:check_lists].filter(:active).order(:thread_id)
end
