class Command
  include Sidekiq::Worker
  def perform(user, msg)
    re = /^[-_]+(\w+)/
    comm = re.match(msg)[1]
    args = re.match(msg).post_match.strip.split(/\s+/)
    __send__ "func_#{comm}", user, *args
  end
end
