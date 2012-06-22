# coding: utf-8

module FetchFiction
  module Worker
    class Send
      include Sidekiq::Worker
      sidekiq_options :queue => :send
      sidekiq_options :retry => false

      # enqueued from Fetch class, get an fiction_id to check with.
      # find the chapter to send (max 5, restrict from CheckList#find_by_fiction method)
      # if `user_id` is given, then only send to that specific user
      # reconnect if IOError
      def perform fiction_id, user_id = nil
        fiction = Fiction.find(:id => fiction_id)
        $logger.info "Running Send #{fiction.name}"

        # return 5 object array from check list
        check_lists = CheckList.find_by_fiction(fiction)
        sub_lists = Subscription.filter(:fiction_id => fiction_id)
        # if `user_id` is given, filter again
        sub_lists = sub_lists.filter(:user_id => user_id) if user_id
        sub_lists.each do |e|
          checked_id = e.checked_id
          send_lists = check_lists.select do |c|
            $logger.debug "#{send_lists.inspect} = #{check_lists}.select {|c| #{c.thread_id.to_i} > #{checked_id.to_i} }"
            c.thread_id.to_i > checked_id.to_i
          end
          return false if send_lists.empty?

          # send message
          $bot.sendMsg e.user, send_lists
          e.user.sended # counter += 1
          # update checked_id
          last_id = send_lists.last.thread_id
          $logger.debug "#{e.inspect}.update(:check_id => #{last_id})"
          e.check_id = last_id
          e.save
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
  end
end
