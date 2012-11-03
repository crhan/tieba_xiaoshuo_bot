# -*- encoding : utf-8 -*-
class Message
  include Sidekiq::Worker
  def perform(user, msg)
    Feedback.create!(:user => User.find_by_account(user), :msg => msg)
  end
end
