Factory.define :user do |u|
  u.sequence(:login)    { |n| "login#{n}"}
  u.sequence(:uid)      { |n| 5000 + n }
  u.full_name           'Factory User'
  u.after_build do |user|
    user.ssh_keys.build(Factory.attributes_for(:ssh_key).slice(:public_key))
  end
end

Factory.define :ssh_key do |s|
  s.sequence(:public_key) { |n| "ssh-dss #{n}AAAAB3NzaC1kc3MAAACBAIcq==" }
end

Factory.define :project do |p|
  p.sequence(:name)     { |n| "Factory Project #{n}" }
end

Factory.define :membership do |m|
  m.association         :project
  m.association         :user
end
