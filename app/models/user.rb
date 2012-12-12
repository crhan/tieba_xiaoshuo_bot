# -*- encoding : utf-8 -*-
class User < ActiveRecord::Base
  attr_accessible :account, :active, :send_count
  has_many :fictions, :through => :subscriptions
  has_many :subscriptions
  has_many :feedbacks
  scope :active, where(active: true)

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

  def sub fic_name
    sub = Subscription.find_or_create_by_user_id_and_fiction_id(self.id,
                                                    Fiction.find_or_create_by_name(fic_name).id)
    sub.sub
  end

  def unsub fic_name
    sub = Subscription.find_or_create_by_user_id_and_fiction_id(self.id,
                                                Fiction.find_or_create_by_name(fic_name).id)
    sub.unsub
  end
  alias subscribe sub
  alias unsubscribe unsub
end
