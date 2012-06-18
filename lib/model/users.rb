class User < Sequel::Model
  many_to_many :fictions, :join_table => :subscriptions
  plugin :validation_helpers

  def validate
    super
    validates_presence :account
    validates_unique :account
  end
end
