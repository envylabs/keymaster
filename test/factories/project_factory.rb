FactoryGirl.define do
  factory :project do
    sequence(:name)     { |n| "Factory Project #{n}" }
  end
end
