class Roster
  include Sidekiq::Worker
  def perform(jid)
    User.find_or_create_by_account(jid)
  end
end
