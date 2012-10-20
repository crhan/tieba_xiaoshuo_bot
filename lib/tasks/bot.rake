namespace :bot do
  desc %{Run the IM Gateway}
  task :run => :environment do
    require 'bot'
    BOT_CONFIG = YAML::load(File.new(File.expand_path("../../../config/bot.yml", __FILE__)))
     EventMachine.run {
       EventMachine.connect '127.0.0.1', 8081, Bot
     }
  end
end
