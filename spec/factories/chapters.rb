# -*- encoding : utf-8 -*-
FactoryGirl.define do
  sequence(:thread_id) {|n| 1000+n}
  sequence(:title) {|n| "第#{n}章"}
  factory :chapter do
    thread_id
    title
    fiction_id 1
  end
end
