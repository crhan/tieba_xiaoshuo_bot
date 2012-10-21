# -*- encoding : utf-8 -*-
FactoryGirl.define do

  sequence(:thread_id_num) {|n| 1000+n}

  factory :chapter do
    thread_id { generate(:thread_id_num) }
    sequence(:title) do |n|
      "第#{n}章"
    end
    fiction

    factory :chapter_2 do
      association :fiction, factory: :fiction_2
      sequence(:title) do |n|
        "第#{n}章"
      end
    end
  end
end
