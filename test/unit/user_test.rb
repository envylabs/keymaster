require 'test_helper'

class UserTest < ActiveSupport::TestCase

  context 'A User' do

    setup do
      @user = FactoryGirl.create(:user)
    end

    subject { @user }

    should have_many(:memberships).dependent(:destroy)
    should have_many(:projects)
    should have_many(:ssh_keys)

    should validate_presence_of(:login)
    should validate_presence_of(:full_name)
    should validate_presence_of(:uid)

    should validate_uniqueness_of(:uid)
    should validate_uniqueness_of(:login)

    should have_readonly_attribute(:login)
    should have_readonly_attribute(:uid)

    should('ensure length of login') { ensure_length_of(:login).is_at_least(3).is_at_most(50) }

    should allow_value(5000).for(:uid)
    should allow_value(6000).for(:uid)
    should allow_value(10000).for(:uid)

    should_not allow_value(0).for(:uid)
    should_not allow_value(1).for(:uid)
    should_not allow_value(-100).for(:uid)
    should_not allow_value(4999).for(:uid)

    should allow_value('thomas').for(:login)
    should allow_value('foo').for(:login)
    should allow_value('baz123').for(:login)
    should allow_value('HappyBunnies').for(:login)

    should_not allow_value('Happy Bunnies').for(:login)
    should_not allow_value('Thomas Meeks').for(:login)
    should_not allow_value('1bunny').for(:login)
    should_not allow_value('foo@bar.com').for(:login)
    should_not allow_value('foo-bar').for(:login)
    should_not allow_value('foo.bar').for(:login)
    should_not allow_value('.foo').for(:login)

    should 'use the login for the slug' do
      assert_equal('fubar', FactoryGirl.build(:user, :login => 'fubar').to_param)
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
          FactoryGirl.create_list(:ssh_key, 2, :user => @user)
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
