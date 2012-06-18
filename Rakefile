require 'pry'
require 'sequel'
require 'logger'

CWD = File.dirname(__FILE__)
task :default => :test

desc "Drop database if exist and migration the database to db/xiaoshuo.db"
task :init do
  DB_PATH = File.join(CWD,"db","xiaoshuo.db")
  DB_MIGRATION_PATH = File.join(CWD,"db","migration")
  FileUtils.rm(DB_PATH) and puts "DB dropped" rescue 0
  connect
  Sequel.extension :migration
  Sequel::Migrator.run($db,DB_MIGRATION_PATH)
end

task :prepare do
  connect
  require_model
end

desc "Just a test"
task :test do
  puts __FILE__
end

private
def connect
  $db = Sequel.connect('sqlite://db/xiaoshuo.db', :test => true, :loggers => [Logger.new($stdout)])
end

def require_model
  Dir.glob "./lib/model/*.rb" do |f|
    require f
  end
end
