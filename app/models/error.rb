class Error < ActiveRecord::Base
  attr_accessible :backtrace, :exception, :message
end
