# -*- encoding : utf-8 -*-
require "spec_helper"

describe Subscription do
  subject {create(:subscription)}
  it "should not subscribe same fiction again" do
    subject
    -> {Subscription.create!(user: User.first, fiction:Fiction.first)}.should raise_error(ActiveRecord::RecordInvalid)
  end

  describe "#new_chapters" do
    it "should change chapter_id to the lastest" do
      c = subject.new_chapters
      last_c = c.to_a.sort{|a,b| a.thread_id <=> b.thread_id}.last
      subject.chapter_id.should equal(last_c.id)
    end
  end

  describe "new user" do
    context "with 29 exist chapters" do
      it "should not receive more than 20 chapters" do
        create_list(:chapter, 25)
        subject.new_chapters.count.should eq(29)
      end
    end

    context "with 4 exist chapters" do
      it "should receive 4 chapters" do
        subject.new_chapters.count.should == 4
      end
    end
  end
end
