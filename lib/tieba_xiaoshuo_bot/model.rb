require 'sequel'
# connect database
DB = Sequel.connect(CONFIG["database"], :loggers => [Logger.new(CONFIG["logger"]["db"])])
# require database model
require 'tieba_xiaoshuo_bot/model/base_model'
require 'tieba_xiaoshuo_bot/model/check_list'
require 'tieba_xiaoshuo_bot/model/error'
require 'tieba_xiaoshuo_bot/model/fictions'
require 'tieba_xiaoshuo_bot/model/subscriptions'
require 'tieba_xiaoshuo_bot/model/users'
require 'tieba_xiaoshuo_bot/model/feedback'
