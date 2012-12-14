# -*- encoding : utf-8 -*-
class SubscriptionError < StandardError; end
class Subscription < ActiveRecord::Base
  attr_accessible :active, :user, :fiction, :chapter
  belongs_to :fiction
  belongs_to :user
  belongs_to :chapter
  validates :fiction_id, :user_id, :presence => true
  validates :fiction_id, :uniqueness => { :scope => :user_id }
  delegate :name, :to => :fiction, :prefix => true
  delegate :chapters, :to => :fiction
  delegate :update_chapters, :to => :fiction
  scope :active_fictions, where(active: true).group(:fiction_id)
  scope :active, where(active: true)

  def new_chapters
    c = self.chapters.newer_than_and_limit(self.chapter_id)
    unless c.blank?
      self.chapter_id = c.last.id
      self.save!
    end
    c
  end

  def chapter_id
    self.chapter.try(:id) || 0
  end

  def unsub
    return "你已经退订小说《#{self.fiction_name}》" unless self.active?
    self.active = false
    self.save
    return "退订《#{self.fiction_name}》成功" unless self.active?
    raise SubscriptionError, "#{__FILE__}:#{__LINE__}, 不知道为啥错了"
  end

  def sub
    return "你已经订阅过小说 《#{self.fiction_name}》" if self.active?
    self.active = true
    self.save
    return "订阅《#{self.fiction_name}》成功" if self.active?
    raise SubscriptionError, "#{__FILE__}:#{__LINE__}, 不知道为啥错了"
  end
end
