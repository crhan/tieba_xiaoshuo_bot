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

    def cron?
      active?
    end

    def check?
      deactive?
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
        Subscription.create(:user => self, :fiction => fic)
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

    def active_fictions
      Fiction.join(:subscriptions, :fiction_id => :id).filter(:active)
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

  end
  User.set_dataset DB[:users].order(:id)
end
