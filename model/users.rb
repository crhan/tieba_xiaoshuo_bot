class User < Sequel::Model
  many_to_many :fictions, :join_table => :subscriptions
end
