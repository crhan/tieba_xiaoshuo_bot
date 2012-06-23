# coding: utf-8

module TiebaXiaoshuoBot
  module Worker
    class LogError
      include Sidekiq::Worker
      sidekiq_options :queue => :log
      sidekiq_options :retry => false

      def perform err_class, msg, backtrace = nil
        $logger.warn "errorLog created by :class => #{err_class}, :msg => #{msg}"
        $logger.warn "and back trace:\n#{backtrace}" if backtrace
        new_e = Error.create(:class => err_class, :msg => msg, :backtrace => nil)
      end
    end
  end
end
