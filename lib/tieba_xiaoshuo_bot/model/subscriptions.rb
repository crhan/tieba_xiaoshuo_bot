# coding: utf-8
module TiebaXiaoshuoBot
  class Subscription < Sequel::Model
    plugin :validation_helpers
    many_to_one :user
    many_to_one :fiction
    include BaseModel

    # primary_key :id
    # foreign_key :fiction_id, :fictions
    # foreign_key :user_id, :users
    # foreign_key :check_id, :check_lists
    # TrueClass :active, :default => true
    # Time :created_at
    # Time :updated_at

    def validate
      super
      validates_unique [:user_id, :fiction_id]
      # unique relations btw user and fiction
    end

    # sorry for the misunderstood of check_list
    def checked_id
      self.check_id || 0
    end

    def sub_active
      if self.active == true
        false
      else
        self.active = true
        self.save
        true
      end
    end

    def sub_deactive
      if self.active == false
        false
      else
        self.active = false
        self.save
        true
      end
    end

    def active?
      active
    end

    def deactive?
      !active
    end

    class << self
      def active_fictions
        self.filter(:active).select(:fiction_id).group(:fiction_id)
      end

      def active_users fiction_id
        self.join(:users, :id=> :user_id).select(:fiction_id,:user_id,:check_id,:subscriptions__active,:users__active___user_active).filter(:users__active, :fiction_id => fiction_id)
      end
    end
  end
  Subscription.set_dataset DB[:subscriptions]
end
