Factory.define :user do |u|
  u.sequence(:login)    { |n| "login#{n}"}
  u.sequence(:uid)      { |n| 5000 + n }
  u.full_name           'Factory User'
  u.after_build do |user|
    user.ssh_keys.build(Factory.attributes_for(:ssh_key).slice(:public_key))
  end
end
