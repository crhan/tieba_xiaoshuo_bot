# coding: utf-8

module FetchFiction
  class Send
    include Sidekiq::Worker
    sidekiq_options :queue => :send

    def perform fiction_id
      fiction = Fiction.find(:id => fiction_id)
      check_lists = CheckList.find_by_fiction(fiction)
      Subscription.filter(:fiction => fiction).each do |e|
        checked_id = e.checked_id
        send_lists = check_lists.select {|c| c.thread_id.to_i > checked_id.to_i }
        # send message
        Bot.sendMsg e.user, send_lists
        # update checked_id
        last_id = send_lists.first.thread_id.to_i
        $logger.debug "#{e.inspect}.update(:check_id => #{last_id})"
        e.check_id = last_id
        e.save
      end
    end
  end
end
