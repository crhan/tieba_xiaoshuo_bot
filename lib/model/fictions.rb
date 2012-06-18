class Fiction < Sequel::Model
  many_to_many :users, :join_table => :subscriptions
  one_to_many :check_lists
end
