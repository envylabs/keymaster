Factory.define :membership do |m|
  m.association         :project
  m.association         :user
end
