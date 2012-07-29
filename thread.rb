#!/usr/bin/env ruby
# coding: utf-8
$:.unshift 'lib'
require 'bundler/setup'
require 'tieba_xiaoshuo_bot'
require 'tieba_xiaoshuo_bot/patch/gtalk_message_patch'
require 'pry'
require 'pry-nav'

$logger = Logger.new($stdout)

include TiebaXiaoshuoBot
include Jabber
# Jabber::debug = true
gtalk = YAML.load_file("config/config.yml")["gtalk"]
$bot = Bot.new gtalk
binding.pry
