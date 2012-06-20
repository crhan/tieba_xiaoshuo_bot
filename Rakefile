# encoding: utf-8
require 'bundler/setup'
require './lib/fetch_fiction'

CWD = File.dirname(__FILE__)
task :default => :test

desc "Drop database if exist and migration the database to db/xiaoshuo.db"
task :init do
  DB_PATH = File.join(CWD,"db","xiaoshuo.db")
  DB_MIGRATION_PATH = File.join(CWD,"db","migration")
  FileUtils.rm(DB_PATH) and puts "DB dropped" rescue 0
  # connect
  # Sequel.extension :migration
  # Sequel::Migrator.run($db,DB_MIGRATION_PATH)
end

desc "Prepare for the testing dataset"
task :prepare do
  connect
  require_model

  # insert user date
  USER_LIST = %W/crhan123@gmail.com ruohanc@gmail.com/
  USER_LIST.each do |e|
    User.create :account => e
  end

  # insert fiction data
  FICTION_LIST = %W/天珠变 吞噬星空 遮天 修真世界/
  FICTION_LIST.each do |e|
    t = Fiction.create :name => e
    User.first.add_fiction(t)
  end

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
