# -*- encoding : utf-8 -*-
class Command
  include Sidekiq::Worker
  sidekiq_options :retry => false
  def perform(from, msg)
    re = /^[ -_]+(\w+)/
    comm = re.match(msg)[1]
    args = re.match(msg).post_match.strip.split(/\s+/)
    user = User.find_by_account(from)
    __send__ "func_#{comm}", user, *args
  end

  private
  def func_sub user, *args
    fic_name, = *args
    msg = user.sub(fic_name)
    Bot::Gateway.deliver user.account, msg
    FetchWorker.perform_async(fic_name)
  rescue SubscriptionError => e
    LogError.perform_async(e.class, e.message, e.backtrace)
  end

  def func_unsub user, *args
    fic_name, = *args
    msg = user.unsub(fic_name)
    Bot::Gateway.deliver user.account, msg
  rescue SubscriptionError => e
    LogError.perform_async(e.class, e.message, e.backtrace)
  end

  def func_check user, *args
    Bot::Gateway.deliver user.account, user.new_chapers
  end

  def __func_update
    Subscription.active_fictions.each {|fic| fic.update }
  end
end
