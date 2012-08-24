# coding: utf-8
$:.unshift 'lib'
require 'bundler/setup'
require 'clockwork'
require 'sidekiq'
require 'tieba_xiaoshuo_bot/worker/cron'
include Clockwork

handler do |job|
  eval job
end

# check fiction every 5 minutes
every 5.minutes, "TiebaXiaoshuoBot::Worker::CronFetch.perform_async"
# check connect status evert 10 seconds
every 5.minutes, "TiebaXiaoshuoBot::Worker::OnlineCheck.perform_async"
