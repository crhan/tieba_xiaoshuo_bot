class Subscriptions < Sequel::Model
  # create_table? :subscriptions do
  #   primary_key :id
  #   foreign_key :fiction_id, :fictions
  #   foreign_key :user_id, :users
  #   foreign_key :check_id, :check_lists
  # end
  many_to_one :user
  many_to_one :fiction
end
