require 'xmpp4r/client'
require 'xmpp4r/roster'
module FetchFiction
  class Bot
    def initialize
      connect
      auto_update_roster_item
      auto_accept_subscription_resquest
    end

    def connect
      # loggin to gtalk server
      # Jabber::debug = true
      myJID = Jabber::JID.new("crhan.xiaoshuo@gmail.com")
      myPassword = 'GefEnsAnift('
      @cl = Jabber::Client.new(myJID)
      @cl.connect
      @cl.auth(myPassword)
      # set online
      @cl.send(Presence.new)
      $logger.info "Connected ! send messages to #{myJID.strip.to_s}."
      # get the roster
      @roster = Jabber::Roster::Helper.new(cl)
    end

    def auto_update_roster_item
      # register the exist subscription to User model
      @roster.add_query_callback do |r|
        @roster.items.each do |k,v|
          # create user if not exist
          jid = v.jid.to_s
          user = User.find_or_create(:account => jid)
          $logger.debug "user #{jid} found in rosterItem"
        end
      end
    end

    def auto_accept_subscription_resquest
      # accept any of the XMPP subscription request
      roster.add_subscription_request_callback do |item,presence|
        roster.accept_subscription(presence.from)
        # send back subscription request
        cl.send(Presence.new.set_type(:subscribe).set_to(presence.from))
        # greating to the new friend
        cl.send(Message.new(presence.from, "hello, my new friend~").set_type("chat"))
      end
    end
  end
end
