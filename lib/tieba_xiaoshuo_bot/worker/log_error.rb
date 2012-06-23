# coding: utf-8

module TiebaXiaoshuoBot
  module Worker
    class LogError
      include Sidekiq::Worker
      sidekiq_options :queue => :log
      sidekiq_options :retry => false

      def perform err_class, msg
        $logger.info "errorLog created by :class => #{err_class}, :msg => #{msg}"
        new_e = Error.create(:class => err_class, :msg => msg)
      end
    end
  end
end
