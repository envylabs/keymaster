class Project < ActiveRecord::Base
  
  has_many                :memberships,
                          :dependent => :destroy
  
  validates_presence_of   :name
  validates_uniqueness_of :name
  
end
