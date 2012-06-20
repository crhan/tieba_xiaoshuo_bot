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
      TrueClass :activate?, :default => true
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
end
