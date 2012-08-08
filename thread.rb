#!/usr/bin/env ruby
# coding: utf-8
$:.unshift File.expand_path("../lib", __FILE__)
require 'bundler/setup'
require 'yaml'
CONFIG = YAML.load_file("config/config.yml")["test"]
require 'tieba_xiaoshuo_bot'
require 'pry'
require 'pry-nav'

$logger = Logger.new($stdout)

include TiebaXiaoshuoBot
include Jabber
# Jabber::debug = true
#$bot = Bot.new gtalk
binding.pry
