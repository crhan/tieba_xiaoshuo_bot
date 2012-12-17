# -*- encoding : utf-8 -*-
module Bot
  class Gateway
    BOT_CONFIG = YAML::load(File.open(File.join(Rails.root, "config/bot.yml")))
    class << self
      def deliver(to, message)
        hash = {type: :message, send_to: to, content: message}

        # open Socket each time
        TCPSocket.open(BOT_CONFIG["host"], BOT_CONFIG["port"]) do |s|
          s.print JSON.generate(hash)
        end
      end

    end
  end
end
