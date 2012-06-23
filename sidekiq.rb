# coding: utf-8
$:.unshift 'lib'
require 'bundler/setup'
require 'tieba_xiaoshuo_bot'

include TiebaXiaoshuoBot
$bot = Bot.instance

$logger.debug Worker::CronFetch.sidekiq_options
$logger.debug Worker::OnlineCheck.sidekiq_options
$logger.debug Worker::Send.sidekiq_options
$logger.debug Worker::Fetch.sidekiq_options
$logger.debug Worker::LogError.sidekiq_options
$logger.debug Worker::Sub.sidekiq_options
$logger.debug Worker::UnSub.sidekiq_options
#Jabber::debug = true
