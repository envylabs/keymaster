require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  context 'A User' do
    
    setup do
      @user = Factory(:user)
    end
    
    subject { @user }
    
    should_have_many              :memberships, :dependent => :destroy
    should_have_many              :projects
    should_have_many              :ssh_keys
    
    should_validate_presence_of   :login,
                                  :full_name,
                                  :uid
    
    should_validate_uniqueness_of :uid,
                                  :login
    
    should_have_readonly_attributes :login,
                                    :uid
    
    should_ensure_length_in_range   :login, (3..50)
    
    should_allow_values_for       :uid, 5000, 6000, 10000
    should_not_allow_values_for   :uid, 0, 1, -100, 4999
    
    should_allow_values_for       :login, 'thomas', 'foo', 'baz123', 'HappyBunnies'
    should_not_allow_values_for   :login, 'Happy Bunnies', 'Thomas Meeks', '1bunny', 'foo@bar.com', 'foo-bar', 'foo.bar', '.foo'
    
    should 'use the login for the slug' do
      assert_equal('fubar', Factory.build(:user, :login => 'fubar').to_param)
    end

    context 'keymaster_data' do
      setup { @result = @user.keymaster_data }
      should("be a hash") { assert @result.kind_of?(Hash) }
      [:login, :uid, :full_name].each do |key|
        should "include the User's #{key}" do
          assert @result.has_key?(key), "Missing #{key}"
          assert_equal @user.send(key), @result[key]
        end
      end
      should 'include the public_ssh_key' do
        assert @result.has_key?(:public_ssh_key)
      end

      context 'with multiple ssh keys' do
        should "concatenate them in public_ssh_key" do
          @user.ssh_keys.create!(Factory.attributes_for(:ssh_key).slice(:public_key))
          assert_equal 2, @user.ssh_keys.count
          @result = @user.keymaster_data
          @user.ssh_keys.each do |key|
            assert @result[:public_ssh_key].include?(key.public_key), "#{key.public_key} not found in #{@result[:public_ssh_key].inspect}"
          end
        end
      end
    end
    
  end
  
end
