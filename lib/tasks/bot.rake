namespace :bot do
  desc %{Run the IM Gateway}
  task :run do
    require "bot/client"
    Jabber::debug = false
    BOT_CONFIG = YAML::load(File.new(File.expand_path("../../../config/bot.yml", __FILE__)))
    host, port = BOT_CONFIG["host"], BOT_CONFIG["port"]
     EM.run {
       EM::start_server host, port, Bot::Client
       EM.add_periodic_timer(10.minutes) do
         Bot.logger.info %{every 10 minutes run a job}
       end
       Bot.logger.info %{Running Bot server on 8081}
       TCPSocket.open(host, port).close
     }
  end
end
