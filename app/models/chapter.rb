# -*- encoding : utf-8 -*-
class Chapter < ActiveRecord::Base
  attr_accessible :title, :thread_id, :fiction, :active
  before_create :deactive_same_fiction_title
  belongs_to :fiction
  validates :title, :thread_id, :presence => true
  validates :thread_id, :uniqueness => true
  default_scope order("thread_id")
  scope :newer_than, ->(id) {where("id > ?", id)}
  scope :active, where(active: true)
  scope :newer_than_and_limit, ->(id, num=20) { newer_than(id).limit(num).reorder("thread_id DESC").reverse }

  def to_s
    "#{self.title}, http://wapp.baidu.com/m?kz=#{thread_id}"
  end

  protected
  def deactive_same_fiction_title
    Chapter.where(title: self.title, fiction_id: self.fiction.id).update_all(active: false)
  end
end
