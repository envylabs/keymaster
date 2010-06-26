require 'test_helper'

class SshKeyTest < ActiveSupport::TestCase
  context 'An SshKey' do
    should_belong_to :user

    should_validate_presence_of :public_key

    should_allow_values_for     :public_key, 'ssh-dss foo', 'ssh-rsa foo'
    should_not_allow_values_for :public_key, 'foo', '123'

    context '' do
      setup { Factory(:user).tap { |user| Factory(:ssh_key, :user => user) } }
      should_validate_uniqueness_of :public_key
    end
  end
end
