# coding: utf-8

module TiebaXiaoshuoBot
  module Worker
    class Sub
      include Sidekiq::Worker
      sidekiq_options :queue => :command
      sidekiq_options :retry => false

      def perform fic_name, user_id
        user = User.find(:id => user_id)
        # remove all white space to get the name
        $logger.debug %|"#{user.account}" request to subscribe "#{fic_name}"|
        if fic_name.empty? # what do you mean by giving empty name?
          raise ArgumentError, %|我怎么检测到了空的名字呢？|
        end
        if user.subscribe fic_name
          $bot.sendMsg user,%|看到那【#{fic_name}】了吗？这本小说值得一战！|
          fic = Fiction.find(:name => fic_name)
          fic.update # fetch now!
          Worker::Send.perform_async fic.id, user.id # send to this user
          $logger.info %|add "#{fic.name}" subsciption for user "#{user.account}"|
          true
        else
          $bot.sendMsg user,%|订阅【#{fic_name}】小说失败， 你是不是已经订阅过了？|
          $logger.info %|User "#{user.account}" subscribe "#{fic_name}" again|
          false
        end
      rescue ArgumentError => e
        Worker::LogError.perform_async self, %|**#{user.name}** #{e.message}|
        sendMsg user, e.message
      end
    end
  end
end
