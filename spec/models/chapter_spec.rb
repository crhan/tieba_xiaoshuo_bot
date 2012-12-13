# -*- encoding : utf-8 -*-
require "spec_helper"

describe Chapter do
  it "should deactive the same chapter title in one fiction" do
    list1 = create_list(:chapter, 4)
    ch = create(:chapter, title: list1[1].title)
    chapter_ar = Chapter.where(title: list1[1].title)
    chapter_ar.count.should equal(2)
    chapter_ar.where(fiction_id: 1, active: true).first.thread_id.should equal(ch.thread_id)
    Chapter.find_by_thread_id(list1[1].thread_id).active?.should be_false
  end
end
