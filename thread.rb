#!/usr/bin/env ruby
# coding: utf-8
$:.unshift 'lib'
require 'bundler/setup'
require 'tieba_xiaoshuo_bot'
require 'pry'

$logger = Logger.new($stdout)

include TiebaXiaoshuoBot
include Jabber
Jabber::debug = true
binding.pry
