# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :subscription do
    fiction
    user
    active true
    initialize_with { Subscription.find_or_create_by_fiction_id_and_user_id(fiction, user) }

    factory :subscription_2 do
      association :fiction, factory: :fiction_2
    end

    after(:build) do |sub, evaluator|
      create_list(:chapter, 4)
    end
  end
end
