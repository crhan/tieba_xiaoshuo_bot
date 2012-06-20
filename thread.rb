#!/usr/bin/env ruby
# coding: utf-8
require 'bundler/setup'
require 'xmpp4r'
require 'sequel'
require 'pry'
require 'nokogiri'
require 'logger'
require 'sidekiq'
require './sidekiq'

# connect database
DB = Sequel.connect('sqlite://db/xiaoshuo.db')
# require database model
Dir.glob "./lib/**/*.rb" do |f|
  require f
end
$logger = Logger.new($stdout)


binding.pry
