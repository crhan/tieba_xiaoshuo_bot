# coding: utf-8
require 'bundler/setup'
require './lib/fetch_fiction/rexml_utf_patch'
require './lib/fetch_fiction'
Dir.glob './**/worker/*.rb' do |f|
  require f
end
require './lib/fetch_fiction/bot'
include FetchFiction
$bot = Bot.instance

$logger.debug Worker::CronFetch.sidekiq_options
$logger.debug Worker::OnlineCheck.sidekiq_options
$logger.debug Worker::Send.sidekiq_options
$logger.debug Worker::Fetch.sidekiq_options
$logger.debug Worker::LogError.sidekiq_options
$logger.debug Worker::Sub.sidekiq_options
$logger.debug Worker::UnSub.sidekiq_options
#Jabber::debug = true
