# -*- encoding : utf-8 -*-
FactoryGirl.define do
  fictions = ["神印王座", "吞噬星空"]

  factory :fiction do
    name fictions[0]
    initialize_with { Fiction.find_or_create_by_name(name) }

    factory :fiction_2 do
      name fictions[1]
    end
  end
end
