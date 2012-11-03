# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  attr_accessible :account, :active, :send_count
  has_many :fictions, :through => :subscriptions
  has_many :subscriptions
  has_many :feedbacks

  def get_chapter(subs=self.subscriptions)
    subs.inject([]) do |sum, sub|
      sum <<  sub.new_chapters.inject([]) do |chapters, ch|
                chapters << sub.fiction.name
                chapters << ch.to_s
              end.uniq.join("\n")
    end.select{|e| !e.blank?}.join("\n\n").force_encoding("utf-8")
  end

  def deactivate
    self.active = false
    save!
  end
end
