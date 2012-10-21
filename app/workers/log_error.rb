class LogError
  include Sidekiq::Worker
  def perform(exception, message)
    Error.create!(:exception => exception, :message => message)
  end
end
