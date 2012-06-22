# coding: utf-8

module FetchFiction
  module Worker
    class Sub
      include Sidekiq::Worker
      sidekiq_options :queue => :command
      sidekiq_options :retry => false

      def perform comm, user_id
        user = User.find(:id => user_id)
        # remove all white space to get the name
        fic_name = comm[3..-1].gsub(/[\s ]/,"")
        $logger.debug %|"#{user.account}" request to subscribe "#{fic_name}"|
        if fic_name.empty? # what do you mean by giving empty name?
          raise ArgumentError, %|fiction name empty error, please specify a fiction name which can find in tieba.baidu.com|
        end
        # TODO check if the subscription is exists
        if user.subscribed? fic_name
          $bot.sendMsg user,%|你已经订阅了【fic_name】小说啦！|
          $logger.info %|User "#{user.account}" subscribe "#{fic_name}" again|
          return false
        end
        fic = if Fiction.find(:name => fic_name)
                Fiction.find(:name=> fic_name)
              else
                $logger.info %|New Fiction "#{fic_name}" added|
                Fiction.create(:name => fic_name)
              end # finish get the Fiction object
        user.add_fiction(fic)
        fic.fetch # fetch now! TODO is there any need to async it?
        Worker::Send.perform_async fic.id, user.id # send to this user
        $logger.info %|add "#{fic.name}" subsciption for user "#{user.account}"|
      rescue ArgumentError => e
        Worker::LogError.perform_async self, e.message
        sendMsg user, e.message
      end
    end
  end
end
