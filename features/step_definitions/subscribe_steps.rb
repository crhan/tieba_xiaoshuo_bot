# -*- encoding : utf-8 -*-
Given /^a fiction name with "(.*?)" and user account "(.*?)"$/ do |arg1, arg2|
  FactoryGirl.create :user
end

When /^"(.*?)" subscribe the never ever new Fiction "(.*?)"$/ do |arg1, arg2|
  FactoryGirl.create :fiction
end

When /^"(.*?)" get a feedback which is "(.*?)"$/ do |arg1, arg2|
  a = double("feature")
  binding.pry
end
