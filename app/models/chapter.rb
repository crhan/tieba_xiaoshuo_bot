# -*- encoding : utf-8 -*-
class Chapter < ActiveRecord::Base
  belongs_to :fiction
  attr_accessible :title, :thread_id, :fiction, :active
  validates :title, :thread_id, :presence => true
  validates :thread_id, :uniqueness => true
  before_create :deactive_same_fiction_title

  protected
  def deactive_same_fiction_title
    Chapter.where(active: true, title: self.title).update_all(active: false)
  end
end
