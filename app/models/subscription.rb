# -*- encoding : utf-8 -*-
class Subscription < ActiveRecord::Base
  attr_accessible :active, :user, :fiction, :chapter
  belongs_to :fiction
  belongs_to :user
  belongs_to :chapter
  validates :fiction_id, :user_id, :presence => true
  validates :fiction_id, :uniqueness => { :scope => :user_id }
  scope :active, where(active: true)

  def new_chapters
    self.fiction.chapters.newer_than(self.chapter_id)
  end

  def chapter_id
    self.chapter.try(:id) || 0
  end

  def unsub
    self.active = false
    save!
  end
end
