class User < ActiveRecord::Base
  
  has_many                :memberships,
                          :dependent  => :destroy
  has_many                :projects,
                          :through    => :memberships
  has_many                :ssh_keys,
                          :dependent  => :destroy
  
  validates_presence_of   :login,
                          :full_name,
                          :uid
  
  validates_uniqueness_of :login,
                          :uid
  
  validates_length_of     :login, :within => 3..50
  
  validates_format_of     :login, :with => %r{^[a-z][a-z0-9]*$}i, :allow_blank => true
  
  validates_numericality_of :uid, :greater_than_or_equal_to => 5000
  
  attr_readonly           :login,
                          :uid
  
  def to_param #:nodoc:
    login.parameterize
  end
  
  def keymaster_data
    {
      :uid => uid,
      :login => login,
      :full_name => full_name,
      :public_ssh_key => ssh_keys.collect { |k| k.public_key }.join("\n")
    }
  end

end
