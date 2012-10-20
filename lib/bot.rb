# -*- encoding : utf-8 -*-
$:.unshift File.expand_path("..", __FILE__)
require "eventmachine"
require "xmpp4r/client"
require "xmpp4r/roster"
require "rexml_utf_patch"
require "gtalk_message_save_patch"
require "sidekiq"
require "hpricot"

class Bot < EventMachine::Connection
  class << self
    def logger
      @logger ||= Logger.new(STDOUT)
    end
  end

  def post_init
    do_connection
    auto_update_roster_item
    auto_accept_subscription_resquest
    add_message_callback
  end

  private
  def do_connection
    cl.connect
    cl.auth(BOT_CONFIG["password"])
    cl.send(Jabber::Presence.new)
    Bot.logger.info "Jabber Connected! Account: #{BOT_CONFIG['account']}"
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
    @cl ||= Jabber::Client.new(myJID)
  end

  def roster
    @roster ||= Jabber::Roster::Helper.new(cl)
  end

  def myJID
    @jid ||= Jabber::JID.new("#{BOT_CONFIG['account']}/xiaoshuoBot")
  end
end
