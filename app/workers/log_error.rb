# -*- encoding : utf-8 -*-
class LogError
  include Sidekiq::Worker
  def perform(exception, message, backtrace)
    Error.create!(:exception => exception, :message => message, :backtrace => backtrace)
  end
end
