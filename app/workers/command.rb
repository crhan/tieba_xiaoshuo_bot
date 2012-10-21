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
    Subscription.create!(user: user,
                                  fiction: Fiction.find_or_create_by_name(fic_name))
    Bot::Gateway.deliver user.account, %{订阅"#{fic_name}"成功}
  rescue ActiveRecord::RecordInvalid => e
    # 你已经订阅过啦
    Bot::Gateway.deliver user.account, %{订阅"#{fic_name}"失败: 您已订阅}
  end

  def func_check user, *args
    Bot::Gateway.deliver user.account, user.new_chapers
  end

end
