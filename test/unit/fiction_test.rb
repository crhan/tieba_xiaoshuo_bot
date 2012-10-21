# -*- encoding : utf-8 -*-
require 'test_helper'

class FictionTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "should calc 'encoded_url' from fiction name before create" do
    fiction = Fiction.create(:name => "修真世界")
    assert fiction.valid?
    assert fiction.encoded_url == "%D0%DE%D5%E6%CA%C0%BD%E7"
  end

  test "should not create two fiction name the same" do
    Fiction.create!(:name => "修真世界")
    assert_raise(ActiveRecord::RecordInvalid) { Fiction.create!(:name => "修真世界") }
  end
end
