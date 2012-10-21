# -*- encoding : utf-8 -*-
class Subscription < ActiveRecord::Base
  belongs_to :fiction
  belongs_to :user
  belongs_to :chapter
  attr_accessible :active
end
