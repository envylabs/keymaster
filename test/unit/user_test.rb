require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  context 'A User' do
    
    setup do
      @user = Factory(:user)
    end
    
    subject { @user }
    
    should_validate_presence_of   :login,
                                  :full_name,
                                  :public_ssh_key,
                                  :uid
    
    should_validate_uniqueness_of :uid,
                                  :login,
                                  :public_ssh_key
    
  end
  
end
