# -*- encoding : utf-8 -*-
require "spec_helper"

describe Fiction do
  subject {create(:fiction)}
  it "should calc 'encoded_url' from fiction name before create" do
    subject.name.should == "神印王座"
    subject.encoded_url.should == "%C9%F1%D3%A1%CD%F5%D7%F9"
  end

  describe "#url" do
    it "should return the right url" do
      subject.url.should == "http://tieba.baidu.com/f?kw=%C9%F1%D3%A1%CD%F5%D7%F9"
    end
  end

  describe "#get_new_chapters" do
    it do
      aim = [{:thread_id=>1935570165, :title=>"第二百八十三章 圣战前奏（下）"}]
      new_chapter = subject.send(:get_new_chapters, File.read(Pow(Rails.root,"spec/tmp/fiction.html")))
      new_chapter.should == aim
    end
  end
end
