FactoryGirl.define do
  factory :user do
    sequence(:login)    { |n| "login#{n}"}
    sequence(:uid)      { |n| 5000 + n }
    full_name           'Factory User'

    after(:build) do |user|
      FactoryGirl.build(:ssh_key, :user => user)
    end
  end
end
