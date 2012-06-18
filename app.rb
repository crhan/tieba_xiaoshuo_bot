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

# Jabber::debug = true
myJID = Jabber::JID.new("crhan.xiaoshuo@gmail.com")
myPassword = 'GefEnsAnift('
cl = Jabber::Client.new(myJID)
cl.connect
cl.auth(myPassword)
#cl.send(Presence.new)
logger.info "Connected ! send messages to #{myJID.strip.to_s}."

main_thread = Thread.current
roster = Jabber::Roster::Helper.new(cl)
roster.add_query_callback do |r|
  roster.items.each do |k,v|
    # create user if not exist
    jid = v.jid.to_s
    unless User.first(:account => jid)
      a = User.new
      a.account = jid
      a.save
      logger.debug "user #{jid} added"
    end
  end
end
binding.pry
