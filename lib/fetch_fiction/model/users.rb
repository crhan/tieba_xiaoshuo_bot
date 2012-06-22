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

    # 订阅小说
    # 成功返回 true
    # 失败返回 false
    def subscribe fiction_name
      fic = Fiction.find_or_create(:name => fiction_name)
      sub = Subscription.find(:user => self, :fiction => fic)
      $logger.info %|**#{self.account}** 想订阅【#{fiction_name}】|
      if sub # if subscription exists
        sub.sub_active # active it (return false if it is active)
      else
        self.add_fiction(fic)
        true
      end
    end

    # 退订小说
    # 成功返回 true
    # 失败返回 false
    def unsubscribe fiction_name
      $logger.info %|**#{self.account}** 想退订【#{fiction_name}】|
      fic = Fiction.find(:name => fiction_name)
      if fic # check if fiction exists
        sub = Subscription.find(:user => self, :fiction => fic)
        if sub # check if subscriptions exists
          sub.sub_deactive # deactive it (return false if it is deactive already)
        end
      end
    end
  end
  User.set_dataset DB[:users].order(:id)
end
