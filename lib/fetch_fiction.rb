# coding: utf-8
require 'bundler/setup'
require 'logger'
require 'sequel'
require 'sidekiq'
require 'pry'
module FetchFiction
  $logger = Logger.new($stdout)

  # connect database
  DB = Sequel.connect('sqlite://db/xiaoshuo.db', :loggers => [$logger])
  # require database model
  Dir.glob "./lib/**/*.rb" do |f|
    require f
  end

end
