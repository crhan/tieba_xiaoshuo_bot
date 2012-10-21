# -*- encoding : utf-8 -*-
class Subscription < ActiveRecord::Base
  attr_accessible :active, :user, :fiction, :chapter
  belongs_to :fiction
  belongs_to :user
  belongs_to :chapter
  validates :fiction, :user, :presence => true

end
