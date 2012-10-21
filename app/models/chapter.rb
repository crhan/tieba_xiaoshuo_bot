# -*- encoding : utf-8 -*-
class Chapter < ActiveRecord::Base
  belongs_to :fiction
  attr_accessible :title, :thread_id, :fiction, :active
  before_create :deactive_same_fiction_title

  protected
  def deactive_same_fiction_title
    Chapter.where(active: true, title: self.title).update_all(active: false)
  end
end
