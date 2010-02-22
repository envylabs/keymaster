require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  context 'A User' do
    
    setup do
      @user = Factory(:user)
    end
    
    subject { @user }
    
    should_have_many              :memberships, :dependent => :destroy
    
    should_validate_presence_of   :login,
                                  :full_name,
                                  :public_ssh_key,
                                  :uid
    
    should_validate_uniqueness_of :uid,
                                  :login,
                                  :public_ssh_key
    
    should_have_readonly_attributes :login,
                                    :uid
    
    should_ensure_length_in_range   :login, (3..50)
    
    should_allow_values_for       :public_ssh_key, 'ssh-dss foo', 'ssh-rsa foo'
    should_not_allow_values_for   :public_ssh_key, 'foo', '123'
    
    should_allow_values_for       :uid, 5000, 6000, 10000
    should_not_allow_values_for   :uid, 0, 1, -100, 4999
    
    should_allow_values_for       :login, 'thomas', 'foo', 'baz123', 'HappyBunnies'
    should_not_allow_values_for   :login, 'Happy Bunnies', 'Thomas Meeks', '1bunny', 'foo@bar.com', 'foo-bar', 'foo.bar', '.foo'
    
    should 'use the login for the slug' do
      assert_equal('fubar', Factory.build(:user, :login => 'fubar').to_param)
    end
    
  end
  
end
