$:.unshift File.expand_path("../../lib", __FILE__)
require 'yaml'
CONFIG = YAML.load_file("config/config.yml")["test"]
require 'simplecov'
require 'faker'
require 'tieba_xiaoshuo_bot'
require 'sidekiq/testing'
include TiebaXiaoshuoBot

RSpec.configure do |config|
  config.around(:each) do |example|
    DB.transaction(:rollback=>:always){example.run}
  end
end

