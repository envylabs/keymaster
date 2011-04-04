module FindFirstBang
  def first!(*args)
    first || raise(ActiveRecord::RecordNotFound, "There are no #{name} instances to return")
  end
end

unless ActiveRecord::Base.methods.include?(:first!)
  ActiveRecord::Base.extend FindFirstBang
end
