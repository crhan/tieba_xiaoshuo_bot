require 'sequel'
# connect database
DB = Sequel.connect(YAML.load_file("config/database.yml")["database"], :loggers => [Logger.new('log/db.log')])
# require database model
require 'tieba_xiaoshuo_bot/model/base_model'
require 'tieba_xiaoshuo_bot/model/check_list'
require 'tieba_xiaoshuo_bot/model/error'
require 'tieba_xiaoshuo_bot/model/fictions'
require 'tieba_xiaoshuo_bot/model/subscriptions'
require 'tieba_xiaoshuo_bot/model/users'
