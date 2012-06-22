# coding: utf-8
require 'bundler/setup'
require 'clockwork'
require 'sidekiq'
require './lib/fetch_fiction/worker/cron'
include Clockwork

handler do |job|
  eval job
end

every 300, "FetchFiction::Worker::CronFetch.perform_async"
every 10, "FetchFiction::Worker::OnlineCheck.perform_async"
