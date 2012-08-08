# coding: utf-8
module TiebaXiaoshuoBot
  class User < Sequel::Model
    many_to_many :fictions, :join_table => :subscriptions
    one_to_many :feedbacks, :key => :reporter_id
    plugin :validation_helpers
    include BaseModel

    # primary_key :id
    # index :id
    # String :account
    # Fixnum :total_count, :default => 0
    # TrueClass :active, :default => true
    # Time :created_at
    # Time :updated_at

    def validate
      super
      validates_presence :account
      validates_unique :account
    end

    def subscriptions
      Subscription.filter(:user => self)
    end

    def send_prepare options={}
      fiction_id = options[:fiction_id]
      send_count = 0
      send_msg = ""

      fiction_list(fiction_id).each do |fiction|
        sub = subscription(fiction)
        last_chapter = nil
        chapters(fiction, sub.last_id).each do |cl|
          send_count += 1
          send_msg << "\n" unless send_msg.empty?
          send_msg << cl.to_s
          last_chapter = cl
        end
        sub.update_last(last_chapter.thread_id) if last_chapter
      end
      self.sended(send_count)
      [send_msg, send_count]
    end

    def sended num = 1
      self.total_count += num
      self.save
      num
    end

    def cron?
      active?
    end

    def check?
      deactive?
    end

    def active?
      self.active
    end

    def deactive?
      !self.active
    end

    def mode
      if cron?
        "cron"
      elsif check?
        "check"
      end
    end

    def switch_mode
      if cron?
        self.active = false
        self.save
        "check"
      elsif check?
        self.active = true
        self.save
        Worker::Send.perform_async nil, self.id, false
        "cron"
      else
        raise RuntimeError, "简直不能相信这里出错2"
      end
    end

    # 订阅小说
    # 成功返回 true
    # 异常返回 false
    def subscribe fiction_name
      create_sub(fiction_name).active_it
    rescue => e
      false
    end

    # 退订小说
    # 成功返回 true
    # 失败返回 false
    def unsubscribe fiction_name
      begin
        get_sub(fiction_name).deactive_it
      rescue =>e
        false
      end
    end

    alias sub_fiction subscribe
    alias unsub_fiction unsubscribe

    def active_fictions
      Fiction.join(:subscriptions, :fiction_id => :id).filter(:active, :user_id => id)
    end

    def list_subscriptions
      count = 1
      sub = self.subscriptions.reverse_order(:active).order_append(:id)
      msg = "你订阅了以下小说:\n"
      sub.each do |e|
        msg << %|\t#{count}. #{e.fiction.name}\t#{"（已退订）" if e.deactive?}\n|
        count += 1
      end
      msg
    end

    alias list_sub list_subscriptions

    private
    def chapters fiction, last_id
      CheckList.find_by_fiction(fiction, last_id)
    end

    def subscription fiction
      Subscription.find(:user => self, :fiction => fiction)
    end

    def fiction_list fiction_id = nil
      if fiction_id
        Fiction.filter(:id => fiction_id)
      else
        self.active_fictions
      end
    end

    def create_fic fic_name
      Fiction.find_or_create(:name => fic_name)
    end

    def create_sub fic_name
      Subscription.find_or_create(:user => self, :fiction => create_fic(fic_name))
    end

    def get_sub fic_name
      Subscription.find(:user => self, :fiction => create_fic(fic_name))
    end

  end
  User.set_dataset DB[:users].order(:id)
end
