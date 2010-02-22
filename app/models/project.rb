class Project < ActiveRecord::Base
  
  has_many                :memberships,
                          :dependent  => :destroy
  has_many                :users,
                          :through    => :memberships
  
  validates_presence_of   :name
  validates_uniqueness_of :name
  
  has_friendly_id         :name, :use_slug => true
  
end
