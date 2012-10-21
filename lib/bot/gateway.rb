module Bot
  class Gateway
    BOT_CONFIG = YAML::load(File.open(File.join(Rails.root, "config/bot.yml")))
    class << self
      def deliver(to, message)
        hash = {send_to: to, content: message}
        socket.print JSON.generate(hash)
      end

      private
      def socket
        @@socket ||= TCPSocket.open(BOT_CONFIG["host"], BOT_CONFIG["port"])
      end
    end
  end
end
