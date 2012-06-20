require "uri"
class Fiction < Sequel::Model
  plugin :validation_helpers
  plugin :schema
  many_to_many :users, :join_table => :subscriptions
  one_to_many :check_lists

  unless table_exists?
    set_schema do
      primary_key :id
      index :id
      String :name
      String :encode_url
    end
    create_table
  end

  def validate
    super
    validates_presence :name
  end

  def before_save
    self.encode_url = URI.encode name.encode("gbk")
  end

  def subscriptions
    Subscription.filter(:fiction => self)
  end
  def url
    "http://tieba.baidu.com/f?kw=#{encode_url}"
  end
end
