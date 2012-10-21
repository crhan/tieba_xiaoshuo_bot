# -*- encoding : utf-8 -*-
require "spec_helper"

describe Subscription do
  it "should not subscribe same fiction again" do
    create(:subscription)
    -> {Subscription.create!(user: User.first, fiction:Fiction.first)}.should raise_error(ActiveRecord::RecordInvalid)
  end
end
