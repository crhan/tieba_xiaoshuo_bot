require "uri"
class Fiction < Sequel::Model
  # create_table? :fictions do
  #   primary_key :id
  #   index :id
  #   String :name
  #   String :url
  # end
  many_to_many :users, :join_table => :subscriptions
  one_to_many :check_lists
  plugin :validation_helpers

  def validate
    super
    validates_presence :name
  end

  def before_save
    self.url = URI.encode name.encode("gbk")
  end
end
