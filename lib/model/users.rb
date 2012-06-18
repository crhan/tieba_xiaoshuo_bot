class User < Sequel::Model
  # create_table? :users do
  #   primary_key :id
  #   index :id
  #   String :account
  #   Fixnum :total_count, :default => 0
  # end
  many_to_many :fictions, :join_table => :subscriptions
  plugin :validation_helpers

  def validate
    super
    validates_presence :account
    validates_unique :account
  end

  def subscriptions
    Subscription.filter(:user => self)
  end
end
