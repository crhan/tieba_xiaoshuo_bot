#!/usr/bin/env ruby
# coding: utf-8
require 'bundler/setup'
require './lib/fetch_fiction/rexml_utf_patch'
require 'xmpp4r'
require 'sequel'
require 'pry'
require 'nokogiri'
require 'logger'
require 'sidekiq'

$logger = Logger.new($stdout)
# connect database
DB = Sequel.connect(YAML.load_file("config/database.yml")["database"])
# require database model
Dir.glob "./lib/**/*.rb" do |f|
  require f
end


include FetchFiction
include Jabber
msg = Message.new("crhan123@gmail.com","haha")
binding.pry
