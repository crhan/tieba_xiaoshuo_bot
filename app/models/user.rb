# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  attr_accessible :account, :active, :send_count
  has_many :feedbacks
  has_many :fictions, :through => :subscriptions
end
