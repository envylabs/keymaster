Factory.define :ssh_key do |s|
  s.sequence(:public_key) { |n| "ssh-dss #{n}AAAAB3NzaC1kc3MAAACBAIcq==" }
end
