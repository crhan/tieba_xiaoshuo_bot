# coding: utf-8
module FetchFiction
  class User < Sequel::Model
    many_to_many :fictions, :join_table => :subscriptions
    plugin :validation_helpers
    plugin :schema

    unless table_exists?
      set_schema do
        primary_key :id
        index :id
        String :account
        Fixnum :total_count, :default => 0
        TrueClass :active, :default => true
      end
      create_table
    end

    def validate
      super
      validates_presence :account
      validates_unique :account
    end

    def subscriptions
      Subscription.filter(:user => self)
    end

    def sended
      self.total_count += 1
      self.save
      total_count
    end

    def deactive
      self.active = false
      self.save
    end
    def active?
      self.active
    end
    def deactive
      !self.active
    end

    # check if this user has subscriped given fiction
    def subscribed? fiction
      if fiction.instance_of? String
        fic = Fiction.find(:name => fiction)
        Subscription.filter(:fiction => fic, :user_id => self.id)
      elsif fiction.instance_of? Fiction
        Subscription.filter(:fiction => fiction, :user_id => self.id)
      elsif fiction.instance_of? Fixnum
        Subscription.filter(:fiction_id => fiction, :user_id => self.id)
      else
        raise ArgumentError, "Please send me a Fiction object, but you gave me a '#{fiction.inspect}', it's a #{fiction.class}"
      end
    end

  end
  User.set_dataset DB[:users].order(:id)
end
