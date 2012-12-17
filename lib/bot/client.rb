# -*- encoding : utf-8 -*-
$:.unshift File.expand_path("..", __FILE__)
require "json"
require "eventmachine"
require "xmpp4r/client"
require "xmpp4r/roster"
require "rexml_utf_patch"
require "gtalk_message_save_patch"
require "sidekiq"
require "hpricot"
require "active_support/core_ext"

# require sidekiq worker
Dir.glob(File.expand_path("../../../app/workers/*.rb", __FILE__)).each do |w|
  require w
end
require File.expand_path("../../../config/initializers/sidekiq.rb", __FILE__)

module Bot

  class << self
    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end

  class Client < EventMachine::Connection
    class << self
      attr_reader :connect_mutex
    end

    def initialize
      super
      @@connect_mutex ||= Mutex.new
      do_connection
      add_default_callbacks
    end

    def post_init
      do_connection
      Bot.logger.debug %{connected: someone}
    end

    # assume that this protocol only receive format in JSON
    #   {"send_to":"who_receive@example.com","content":"what you want to say"}
    def receive_data(data)
      Bot.logger.debug %{receive: #{data}}
      json_data = JSON.parses(data, symbolize_names: true)
      case json_data[:type]
      when :reconnect
        do_connection
      when :message
        deliver json_data
      end
    rescue => e
      Error::log(e)
    end

    def unbind(data)
      Bot.logger.debug %{unbind: #{data}}
    end


    private

    def deliver(hash)
      send_to, content = hash[:send_to], hash[:content]
      msg = Jabber::Message.new(send_to).set_type(:chat).set_body(content)
      cl.send(msg)
    end

    def do_connection
      if cl.is_disconnected?
        connect_mutex.synchronize do
          cl.connect
          cl.auth(BOT_CONFIG["password"])
          cl.send(Jabber::Presence.new)
          Bot.logger.info "Jabber Connected! Account: #{BOT_CONFIG['account']}"
        end
      end
      cl
    rescue ThreadError => e
      Error.log(e)
      sleep 0.1
      retry
    end

    def add_default_callbacks
      auto_update_roster_item
      auto_accept_subscription_resquest
      add_message_callback
    end

    def auto_update_roster_item
      # register the exist subscription to User model
      roster.add_query_callback do |r|
        roster.items.each do |k,v|
          # create user if not exist
          jid = v.jid.strip.to_s
          Roster.perform_async(jid)
          Bot.logger.debug "user #{jid} found in rosterItem"
        end
      end
    end

    def auto_accept_subscription_resquest
      # accept any of the XMPP subscription request
      roster.add_subscription_request_callback do |item,presence|
        roster.accept_subscription(presence.from)
        # send back subscription request
        cl.send(Jabber::Presence.new.set_type(:subscribe).set_to(presence.from))
        # greating to the new friend
        Bot.logger.info "accept roster subscription from #{presence.from.to_s}"
        cl.send(Jabber::Message.new(presence.from, @about_message).set_type(:chat))
      end
    end

    def add_message_callback
      cl.add_message_callback do |m|
        if m.type == :chat and ! m.body.nil?
          msg = Hpricot(m.body).to_plain_text
          user = m.from.strip.to_s
          Bot.logger.debug %|--start parsing "#{msg}" from user "#{user}"|
          parse_msg user, msg
          Bot.logger.debug %|--stop parsing "#{msg}" from user "#{user}"|
        end
      end
    end

    def parse_msg(user, msg)
      case msg
      when /^-/
        Command.perform_async(user, msg)
      else
        Message.perform_async(user, msg)
      end
    end

    def cl
      @@cl ||= Jabber::Client.new(myJID)
    end

    def roster
      @@roster ||= Jabber::Roster::Helper.new(cl)
    end

    def myJID
      @@jid ||= Jabber::JID.new("#{BOT_CONFIG['account']}/xiaoshuoBot")
    end

    def connect_mutex
      @@connect_mutex
    end
  rescue Jabber::ServerDisconnected => e
    Error::log(e)
    do_connection
    sleep 0.5
    retry
  rescue => e
    Error::log(e)
    do_connection
    raise e
  end

  module Error
    module_function

    def log(e)
      cont = [e.class.to_s, e.message, e.backtrace]
      LogError.perform_async(*cont)
    end
  end
end
