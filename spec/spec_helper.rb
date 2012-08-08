$:.unshift File.expand_path("../../lib", __FILE__)
require 'yaml'
CONFIG = YAML.load_file("config/config.yml")["test"]
require 'tieba_xiaoshuo_bot'
