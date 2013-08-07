class Project < ActiveRecord::Base
  extend FriendlyId

  has_many                :memberships,
                          :dependent  => :destroy
  has_many                :users,
                          :through    => :memberships

  validates_presence_of   :name
  validates_uniqueness_of :name

  friendly_id             :name,
                          :use        => :slugged,
                          :slug_column => :cached_slug

end
