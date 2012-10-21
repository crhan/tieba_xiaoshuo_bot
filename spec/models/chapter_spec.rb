# -*- encoding : utf-8 -*-
require "spec_helper"
require 'pry'

describe Chapter do
  it "should deactive the same chapter title in one fiction" do
    create_list(:chapter, 4)
    create_list(:chapter_2, 4)
    create(:chapter, title: "第2章")
    chapter_ar = Chapter.unscoped.where(title: "第2章")
    chapter_ar.count.should equal(3)
    chapter_ar.where(fiction_id: 1, active: true).first.thread_id.should equal(1009)
    Chapter.unscoped.find_by_thread_id(1002).active?.should be_false
  end
end
