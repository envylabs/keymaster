class Membership < ActiveRecord::Base

  belongs_to              :user
  belongs_to              :project

  validates_presence_of   :user_id,
                          :project_id

  validates_uniqueness_of :user_id,
                          :scope          => :project_id,
                          :case_sensitive => false

end
