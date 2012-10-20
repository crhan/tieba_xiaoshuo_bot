class Message
  include Sidekiq::Worker
  def perform(user, msg)
    Feedback.create(:user => user, :msg => msg)
  end
end
