# coding: utf-8

module FetchFiction
  class Send
    include Sidekiq::Worker
    sidekiq_options :queue => :send

    def perform fiction_id
      fiction = Fiction.filter(:id => fiction_id)
      check_lists = CheckList.find_by_fiction(fiction)
      Subscription.filter(:fiction => fiction).each do |e|
        checked_id = e.checked_id
        send_lists = check_lists.select {|c| c.thread_id > checked_id }
        # send message
        $bot.sendMsg e.user, send_lists
        # update checked_id
        e.update(:check_id => checked_id)
      end
    end
  end
end
