# -*- encoding : utf-8 -*-
class Roster
  include Sidekiq::Worker
  sidekiq_options :retry => false
  def perform(jid)
    User.find_or_create_by_account(jid)
  end
end
