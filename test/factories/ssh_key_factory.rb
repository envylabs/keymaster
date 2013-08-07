FactoryGirl.define do
  factory :ssh_key do
    sequence(:public_key) { |n| "ssh-dss #{n}AAAAB3NzaC1kc3MAAACBAIcq==" }
  end
end
