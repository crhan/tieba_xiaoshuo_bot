# coding: utf-8
require './lib/fetch_fiction'
require './lib/fetch_fiction/bot'
Dir.glob './**/worker/*.rb' do |f|
  require f
end
$bot = FetchFiction::Bot.instance
