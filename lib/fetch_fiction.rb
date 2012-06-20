module FetchFiction
  require 'sequel'
  require 'logger'
  $logger = Logger.new($stdout)
  # connect database
  DB = Sequel.connect('sqlite://db/xiaoshuo.db', :loggers => [$logger])
  # require database model
  Dir.glob "./lib/**/*.rb" do |f|
    require f
  end
end
