require 'bundler/setup'
require 'clockwork'
require './lib/fetch_fiction'
include Clockwork

handler do |job|
  eval job
end

every 30, "CronFetch.perform_async"