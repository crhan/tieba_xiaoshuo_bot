module FetchFiction
  class CheckList < Sequel::Model
    plugin :validation_helpers
    plugin :schema
    many_to_one :fiction

    unless table_exists?
      set_schema do
        primary_key :id
        foreign_key :fiction_id, :fictions
        String :thread_id
        String :thread_name
        Time :created_at
      end
      create_table
    end
    def to_s
      %|#{self.fiction.name}\n#{self.thread_name}, http://wapp.baidu.com/m?kz=$1|
    end

    def validate
      validates_presence [:thread_id, :thread_name, :fiction_id]
    end

    def before_save
      self.created_at ||= Time.now
      super
    end

    # return 5 Fiction Thread object array by reverse order
    def self.find_by_fiction fiction
      if fiction.instance_of? Fiction
        self.filter(:fiction => fiction)
      elsif fiction.instance_of? Fixnum
        self.filter(:fiction_id => fiction)
      else
        raise TypeError, "Need a Fiction object or a Fixnum refer to fiction_id"
      end.order(:thread_id).reverse.limit(5).all.reverse
    end
  end
end
