# -*- encoding : utf-8 -*-
require 'test_helper'

class ChapterTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "should deactive the same chapter title in one fiction" do
    Chapter.create(fiction: Fiction.find(1), title: "第二章", thread_id: 192411234)
    chapter_ar = Chapter.unscoped.where(title: "第二章", active: true)
    assert_equal 2, chapter_ar.count
    assert_equal 192411234, chapter_ar.where(fiction_id: 1).first.thread_id
    assert !Chapter.find_by_thread_id(192311233).active
  end
end
