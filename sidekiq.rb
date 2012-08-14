# coding: utf-8
$:.unshift File.expand_path("../lib", __FILE__)
require 'bundler/setup'
CONFIG = YAML.load_file("config/config.yml")["production"]
require 'tieba_xiaoshuo_bot'

$bot = TiebaXiaoshuoBot::Bot.new CONFIG["gtalk"]

Jabber::debug = true
