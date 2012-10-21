# -*- encoding : utf-8 -*-
class Fiction < ActiveRecord::Base
  attr_accessible :encoded_url, :name
  has_many :chapters
  has_many :users, :through => :subscriptions
end
