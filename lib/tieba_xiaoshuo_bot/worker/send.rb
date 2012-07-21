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
        $logger.debug %|Running Worker::Send fiction_id = #{fiction_id}, user_id = #{user_id}, info = #{info}|
        send = 0 if info # sum up the chapter send to user this time
        if user_id
          # if `user_id` is given then send all the active fiction for this user
          user = User.find(:id => user_id)
          fiction = user.active_fictions
          $logger.debug %|fiction =>\n #{fiction.all}|
          $logger.debug %|send to single user "#{user.account}"|
        else
          fiction = Fiction.filter(:id => fiction_id)
        end
        fiction.each do |f|
          $logger.debug "Running Send #{f.name}"

          # if `user_id` is given, ignore the `user.active` flag
          sub_lists = if user_id
                        $logger.debug %|Subscription.filter(:fiction_id => #{ f.id }, :user_id => #{ user_id })|
                        Subscription.filter(:fiction_id => f.id, :user_id => user_id)
                      else
                        $logger.debug %|Subscription.active_users #{ f.id }|
                        Subscription.active_users f.id
                      end
          $logger.debug %|sub_lists =>\n#{sub_lists.all}|
          sub_lists.each do |e|
            checked_id = e.checked_id
            send_lists = CheckList.find_by_fiction f,checked_id
            next if send_lists.empty?

            # send message
            $bot.sendMsg e.user, send_lists.all, true# send_lists will be an array with .all
            send += e.user.sended(send_lists.count) if info # counter += 1
            # update checked_id
            last_id = send_lists.last.thread_id
            $logger.debug "#{e.inspect}.update(:check_id => #{last_id})"
            e.check_id = last_id
            e.save
          end
        end
        $bot.sendMsg user, %|本次为您送上了 #{send} 章小说~| if info
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
  end
end
