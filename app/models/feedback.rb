# -*- encoding : utf-8 -*-
class Feedback < ActiveRecord::Base
  attr_accessible :msg, :user
  belongs_to :user
end
