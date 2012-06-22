# coding: utf-8

module FetchFiction
  module Worker
    class UnSub
      include Sidekiq::Worker
      sidekiq_options :queue => :command
      sidekiq_options :retry => false

      def perform comm, user_id
        user = User.find(:id => user_id)
        fic_name = comm[5..-1].gsub(/[\s ]/,"")
        $logger.debug %|"#{user.account}" request to unsubscribe "#{fic_name}"|
        if fic_name.empty? # what do you mean by giving empty name?
          raise ArgumentError, %|我怎么检测到了空的名字呢？你输入的是不是"#{comm}"?|
        end
        # TODO check if the subscription is exists
        if user.unsubscribe fic_name
          $bot.sendMsg user,%|我已经帮你退订了【#{fic_name}】小说啦！|
          $logger.info %|add "#{fic_name}" subsciption for user "#{user.account}"|
          true
        else
          $bot.sendMsg user,%|退订【#{fic_name}】小说失败，你是不是还没订阅它啊？|
          $logger.info %|User "#{user.account}" unsubscribe "#{fic_name}" failed|
          false
        end
      rescue ArgumentError => e
        Worker::LogError.perform_async self, %|**#{user.name}** #{e.message}|
        sendMsg user, e.message
      end
    end
  end
end
