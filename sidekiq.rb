# coding: utf-8
$:.unshift File.expand_path("../lib", __FILE__)
require 'bundler/setup'
require 'tieba_xiaoshuo_bot'

include TiebaXiaoshuoBot
gtalk = YAML.load_file("config/config.yml")["gtalk"]
$bot = Bot.new gtalk

$logger.debug Worker::CronFetch.sidekiq_options
$logger.debug Worker::OnlineCheck.sidekiq_options
$logger.debug Worker::Send.sidekiq_options
$logger.debug Worker::Fetch.sidekiq_options
$logger.debug Worker::LogError.sidekiq_options
$logger.debug Worker::Sub.sidekiq_options
$logger.debug Worker::UnSub.sidekiq_options
Jabber::debug = true
