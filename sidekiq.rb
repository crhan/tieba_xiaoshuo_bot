# coding: utf-8
require 'bundler/setup'
require './lib/fetch_fiction/rexml_utf_patch'
require './lib/fetch_fiction'
require './lib/fetch_fiction/bot'
Dir.glob './**/worker/*.rb' do |f|
  require f
end
include FetchFiction
$bot = Bot.instance

$logger.debug CronFetch.sidekiq_options
$logger.debug OnlineCheck.sidekiq_options
$logger.debug Send.sidekiq_options
$logger.debug Fetch.sidekiq_options
$logger.debug LogError.sidekiq_options
