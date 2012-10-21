# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  attr_accessible :account, :active, :send_count
  has_many :fictions, :through => :subscriptions
  has_many :subscriptions
  has_many :feedbacks
end
