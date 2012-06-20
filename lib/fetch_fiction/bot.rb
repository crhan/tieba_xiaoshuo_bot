# coding: utf-8
module FetchFiction
  require 'xmpp4r/client'
  require 'xmpp4r/roster'
  class Bot
    def initialize
      connect
      auto_update_roster_item
      auto_accept_subscription_resquest
      add_message_callback
    end

    def self.close
      @@cl.close
    end
    def self.cl
      @@cl
    end

    # receive an User object and an array of CheckList objects
    def self.sendMsg user, send_lists
      msg = Jabber::Message.new(user.account).set_type("chat")
      send_lists.each do |e|
        @@cl.send(msg.set_body(e.to_s))
        $logger.info "Send Message to #{user.account}, with #{e.to_s}"
      end
    end

    private
    def connect
      # loggin to gtalk server
      # Jabber::debug = true
      myJID = Jabber::JID.new("crhan.xiaoshuo@gmail.com")
      myPassword = 'GefEnsAnift('
      @@cl = Jabber::Client.new(myJID)
      @@cl.connect
      @@cl.auth(myPassword)
      # set online
      @@cl.send(Jabber::Presence.new)
      $logger.info "Connected ! send messages to #{myJID.strip.to_s}."
      # get the roster
      @@roster = Jabber::Roster::Helper.new(@@cl)
    end

    def auto_update_roster_item
      # register the exist subscription to User model
      @@roster.add_query_callback do |r|
        @@roster.items.each do |k,v|
          # create user if not exist
          jid = v.jid.to_s
          user = User.find_or_create(:account => jid)
          $logger.debug "user #{jid} found in rosterItem"
        end
      end
    end

    def auto_accept_subscription_resquest
      # accept any of the XMPP subscription request
      @@roster.add_subscription_request_callback do |item,presence|
        @@roster.accept_subscription(presence.from)
        # send back subscription request
        @@cl.send(Presence.new.set_type(:subscribe).set_to(presence.from))
        # greating to the new friend
        @@cl.send(Jabber::Message.new(presence.from, "hello, my new friend~").set_type("chat"))
      end
    end

    def add_message_callback
      @@cl.add_message_callback do |m|
        if m.type != :error
          m2 = Message.new("crhan123@gmail.com", "#{m.to_s}")
          m2.type = m.type
          @@cl.send(m2)
          if m.body == 'exit'
            m2 = Message.new(m.from, "Exiting ...")
            m2.type = m.type
            @@cl.send(m2)
            $mainthread.wakeup
          end
        end
      end
    end
  end
end
