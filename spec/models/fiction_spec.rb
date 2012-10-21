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
end
