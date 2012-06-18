#!/usr/bin/env ruby
# coding: utf-8

require 'bundler/setup'
require 'xmpp4r/client'
require 'xmpp4r/roster'
require 'sequel'
require 'logger'
require 'pry'

logger = Logger.new($stdout)
# connect database
DB = Sequel.connect('sqlite://db/xiaoshuo.db', :loggers => [logger])
# require database model
Dir.glob "./lib/model/*.rb" do |f|
  require f
end

# loggin to gtalk server
# Jabber::debug = true
myJID = Jabber::JID.new("crhan.xiaoshuo@gmail.com")
myPassword = 'GefEnsAnift('
cl = Jabber::Client.new(myJID)
cl.connect
cl.auth(myPassword)
#cl.send(Presence.new)
logger.info "Connected ! send messages to #{myJID.strip.to_s}."

# get the roster and register the exist subscription to User model
roster = Jabber::Roster::Helper.new(cl)
roster.add_query_callback do |r|
  roster.items.each do |k,v|
    # create user if not exist
    jid = v.jid.to_s
    user = User.find_or_create(:account => jid)
    logger.debug "user #{jid} found in rosterItem"
  end
end
# accept any of the XMPP subscription request
roster.add_subscription_request_callback do |item,presence|
  roster.accept_subscription(presence.from)
  # send back subscription request
  cl.send(Presence.new.set_type(:subscribe).set_to(presence.from))
  # greating to the new friend
  cl.send(Message.new(presence.from, "hello, my new friend~").set_type("chat"))
end
binding.pry
