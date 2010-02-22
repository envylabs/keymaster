class User < ActiveRecord::Base
  
  has_many                :memberships,
                          :dependent => :destroy
  
  validates_presence_of   :login,
                          :full_name,
                          :public_ssh_key,
                          :uid
  
  validates_uniqueness_of :login,
                          :public_ssh_key,
                          :uid
  
  validates_length_of     :login, :within => 3..50
  
  validates_format_of     :public_ssh_key, :with => %r{^ssh-(rsa|dss)\b}
  validates_format_of     :login, :with => %r{^[a-z][a-z0-9]*$}i, :allow_blank => true
  
  validates_numericality_of :uid, :greater_than_or_equal_to => 5000
  
  attr_readonly           :login,
                          :uid
  
  def to_param #:nodoc:
    login.parameterize
  end
  
end
