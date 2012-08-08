# coding: utf-8
require 'bundler/setup'
require 'logger'

$:.unshift File.expand_path("..", __FILE__)

$logger = Logger.new($stdout)
#$logger.level = Logger::INFO

require 'tieba_xiaoshuo_bot/model'
require 'tieba_xiaoshuo_bot/worker'
require 'tieba_xiaoshuo_bot/bot'
