# -*- encoding : utf-8 -*-
require "spec_helper"

describe Subscription do
  fixtures :subscriptions, :chapters
  subject {subscriptions(:one)}
  it "should not subscribe same fiction again" do
    -> {Subscription.create!(user: User.first, fiction:Fiction.first)}.should raise_error(ActiveRecord::RecordInvalid)
  end

  describe "#new_chapters" do
    specify { should have(2).new_chapters }
    it "should change chapter_id to the lastest" do
      list = create_list(:chapter, 30)
      c = subject.new_chapters
      subject.chapter_id.should equal(list.last.id)
    end
  end

  describe "new user" do
    context "with 29 exist chapters" do
      it "should not receive more than 20 chapters" do
        create_list(:chapter, 30)
        Chapter.should have(32).all
        should have(20).new_chapters
      end
    end

    context "with 4 exist chapters" do
      it "should receive 4 chapters" do
        create_list(:chapter, 2)
        should have(4).new_chapters
      end
    end
  end
end
