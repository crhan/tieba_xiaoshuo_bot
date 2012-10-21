# -*- encoding : utf-8 -*-
require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase
  test "shoud_not subscribe same fiction again" do
    assert_raise(ActiveRecord::RecordInvalid) do
      Subscription.create!(user: User.first, fiction:Fiction.first)
    end
  end
end
