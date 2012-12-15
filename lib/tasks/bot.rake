namespace :bot do
  PID_FILE = File.expand_path("../../../tmp/pids/bot.pid", __FILE__)

  desc %{Run the IM Gateway}
  task :run do
    require "bot/client"
    Jabber::debug = false

    # get bot config from #{app.root}/config/bot.yml
    BOT_CONFIG = YAML::load(File.new(File.expand_path("../../../config/bot.yml", __FILE__)))
    host, port = BOT_CONFIG["host"], BOT_CONFIG["port"]

    # write this workers pid to PIDFILE
    File.open(PID_FILE, 'w') {|f| f << Process.pid}
    EM.run do
      EM::start_server host, port, Bot::Client
      EM.add_periodic_timer(2.minutes) do
        Bot.logger.info %{every 2 minutes run a fetch}
        FetchWorker.perform_async
      end
      Bot.logger.info %{Running Bot server on #{BOT_CONFIG["port"]}}
      TCPSocket.open(host, port).close
    end
  end
end
