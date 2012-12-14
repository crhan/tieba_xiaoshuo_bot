# -*- encoding : utf-8 -*-
require "spec_helper"
describe User do
  fixtures :users

  it "should fixture right" do
    user = users(:one)
    user.id.should == 1
    user.account.should == "crhan123@gmail.com"
    user.active.should be_true
    User.should have(2).all
  end
end
