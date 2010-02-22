Factory.define :user do |u|
  u.sequence(:login)    { |n| "login#{n}"}
  u.sequence(:uid)      { |n| n }
  u.sequence(:public_ssh_key) { |n| "ssh-dss #{n}AAAAB3NzaC1kc3MAAACBAIcq==" }
  u.full_name           'Factory User'
end