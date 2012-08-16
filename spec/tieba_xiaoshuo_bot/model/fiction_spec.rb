# coding: utf-8
require 'spec_helper'

module TiebaXiaoshuoBot
  describe Fiction do
    describe "the first fiction" do
      subject {Fiction[1]}
      it "should have the encoded url" do
        subject.encode_url.should_not be_nil
        subject.created_at.should_not be_nil
        subject.updated_at.should_not be_nil
      end

      specify {should have(2).subscriptions}
      specify {lambda {subject.send(:new_chapters, "")}.should raise_error(TiebaXiaoshuoBot::Fiction::NoContentError)}
      specify {lambda {subject.send(:get_response)}.should_not raise_error}
      specify {lambda {subject.send(:create_chapter, 1777176400, "aha")}.should raise_error}
      specify {lambda {subject.send(:create_chapter, 1777176401, "aha")}.should_not raise_error}
    end
  end
end

