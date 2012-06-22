# coding: utf-8
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
        foreign_key :check_id, :check_lists
        TrueClass :active, :default => true
      end
      create_table
    end

    def validate
      super
      validates_unique [:user_id, :fiction_id]
      # unique relations btw user and fiction
    end

    # sorry for the misunderstood of check_list
    def checked_id
      self.check_id || 0
    end

    def unsubscribe
      self.active = false
      self.save
    end

    def active?
      self.active
    end

    def deactive?
      ! self.active
    end

    def self.active_fictions
      self.filter(:active).select(:fiction_id).group(:fiction_id)
    end

  end
  #Subscription.set_dataset DB[:subscriptions].filter(:active)
end
