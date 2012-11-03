# -*- encoding : utf-8 -*-
class Command
  include Sidekiq::Worker
  def perform(from, msg)
    re = /^[-_]+(\w+)/
    comm = re.match(msg)[1]
    args = re.match(msg).post_match.strip.split(/\s+/)
    user = User.find_by_account(from)
    __send__ "func_#{comm}", user, *args
  end

  private
  def func_sub user, *args
    fic_name, = *args
    fiction = Fiction.find_or_create_by_name(fic_name)
    msg = Subscription.find_or_create_by_user_id_and_fiction_id(user, fiction).sub
    Bot::Gateway.deliver user.account, msg
  rescue SubscriptionError => e
    LogError.perform_async(e.class, e.message, e.backtrace)
  end

  def func_unsub user, *args
    fic_name, = *args
    fiction = Fiction.find_or_create_by_name(fic_name)
    msg = Subscription.find_or_create_by_user_id_and_fiction_id(user, fiction).unsub
    Bot::Gateway.deliver user.account, msg
  rescue SubscriptionError => e
    LogError.perform_async(e.class, e.message, e.backtrace)
  end

  def func_check user, *args
    Bot::Gateway.deliver user.account, user.new_chapers
  end

end
