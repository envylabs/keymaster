Factory.define :project do |p|
  p.sequence(:name)     { |n| "Factory Project #{n}" }
end
