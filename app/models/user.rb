class User < ActiveRecord::Base
  
  validates_presence_of   :login,
                          :full_name,
                          :public_ssh_key,
                          :uid
  
  validates_uniqueness_of :login,
                          :public_ssh_key,
                          :uid
  
end
