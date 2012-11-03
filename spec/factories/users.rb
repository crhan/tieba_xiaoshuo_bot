# -*- encoding : utf-8 -*-
FactoryGirl.define do
  factory :user do
    account "crhan123@gmail.com"
    active true
    send_count 0

    factory :user_2 do
      account "crhan223@gmail.com"
    end
  end
end
