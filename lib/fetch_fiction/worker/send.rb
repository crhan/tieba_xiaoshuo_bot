# coding: utf-8

module FetchFiction
  class Send
    @queue = :send
    @retry_time = 0

    # enqueued from Fetch class, get an fiction_id to check with.
    # find the chapter to send (max 5, restrict from CheckList#find_by_fiction method)
    # reconnect if IOError
    def self.perform fiction_id
      fiction = Fiction.find(:id => fiction_id)
      $logger.info "Running Send #{fiction.name}"

      check_lists = CheckList.find_by_fiction(fiction)
      Subscription.filter(:fiction => fiction).each do |e|
        checked_id = e.checked_id
        send_lists = check_lists.select do |c|
          $logger.debug "#{send_lists.inspect} = #{check_lists}.select {|c| #{c.thread_id.to_i} > #{checked_id.to_i} }"
          c.thread_id.to_i > checked_id.to_i
        end
        return false if send_lists.empty?

        # send message
        $bot.sendMsg e.user, send_lists
        # update checked_id
        last_id = send_lists.last.thread_id
        $logger.debug "#{e.inspect}.update(:check_id => #{last_id})"
        e.check_id = last_id
        e.save
      end
    rescue IOError => e
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
