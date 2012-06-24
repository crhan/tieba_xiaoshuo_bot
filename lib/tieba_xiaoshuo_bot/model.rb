require 'sequel'
# connect database
DB = Sequel.connect(YAML.load_file("config/config.yml")["database"], :loggers => [Logger.new(YAML.load_file("config/config.yml")["logger"]["db"])])
# require database model
require 'tieba_xiaoshuo_bot/model/base_model'
require 'tieba_xiaoshuo_bot/model/check_list'
require 'tieba_xiaoshuo_bot/model/error'
require 'tieba_xiaoshuo_bot/model/fictions'
require 'tieba_xiaoshuo_bot/model/subscriptions'
require 'tieba_xiaoshuo_bot/model/users'
require 'tieba_xiaoshuo_bot/model/feedback'
