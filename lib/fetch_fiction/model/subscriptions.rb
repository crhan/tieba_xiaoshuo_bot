module FetchFiction
  class Subscription < Sequel::Model
    plugin :validation_helpers
    plugin :schema
    many_to_one :user
    many_to_one :fiction

    unless table_exists?
      set_schema do
        primary_key :id
        foreign_key :fiction_id, :fictions
        foreign_key :user_id, :users
        foreign_key :check_id, :check_lists, :default => true
        TrueClass :activate?, :default => true
      end
      create_table
    end

    # sorry for the misunderstood of check_list
    def checked_id
      check_id
    end

  end
end
