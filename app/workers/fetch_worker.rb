# -*- encoding : utf-8 -*-
class FetchWorker
  include Sidekiq::Worker
  sidekiq_options :retry => false
  def perform fic_name=nil
    if fic_name
      fetch fic_name
    else
      fetch_all
    end

    User.active.each do |user|
      Bot::Gateway.deliver user.account, user.get_chapter
    end
  end

  private
  def fetch(fic_name)
    Fiction.find_by_name(fic_name).update_chapters
  end

  def fetch_all
    Subscription.active_fictions.each do |fic|
      fic.update_chapters
    end
  end
end
