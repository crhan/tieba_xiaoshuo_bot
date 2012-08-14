# coding: utf-8

module TiebaXiaoshuoBot
  module Worker
    class Send
      include Sidekiq::Worker
      sidekiq_options :queue => :send
      sidekiq_options :retry => false

      # enqueued from Fetch class, get an fiction_id to check with.
      # find the chapter to send (max 5, restrict from CheckList#find_by_fiction method)
      # if `user_id` is given, then only send to that specific user
      # reconnect if IOError
      def perform fiction_id, user_id = nil, info = false
        if user_id
          user = User.find(:id => user_id)
          send_msg, count = user.send_prepare
          if count >0
            $bot.sendMsg user, send_msg
            sleep 1
            $bot.sendMsg user, %|本次为您送上了 #{count} 章小说~|
          else
            $bot.sendMsg user, %|好像没有新的小说更新哦~|
          end
        else
          cron_sub_list(fiction_id).each do |sub|
            user = User.find(:id => sub.user_id)
            send_msg, count = user.send_prepare(:fiction_id => fiction_id)
            $bot.sendMsg user, send_msg if count > 0
          end
        end

      rescue IOError => e # IOError means disconnect from XMPP server
        if @retry_time < 3
          @retry_time += 1
          $logger.error "#{e.inspect}: retry #{@retry_time} time(s)"
          $bot.reconnect
          sleep 4 ** @retry_time
          retry
        end
        raise e
      end
    end

    private
    def cron_sub_list fiction_id
      Subscription.active_users fiction_id
    end
  end
end
