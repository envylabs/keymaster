require 'test_helper'

class SshKeyTest < ActiveSupport::TestCase
  context 'An SshKey' do
    should belong_to(:user)

    should validate_presence_of(:public_key)

    should allow_value('ssh-dss foo').for(:public_key)
    should allow_value('ssh-rsa foo').for(:public_key)

    should_not allow_value('foo').for(:public_key)
    should_not allow_value('123').for(:public_key)

    context '' do
      setup { Factory(:user).tap { |user| Factory(:ssh_key, :user => user) } }
      should validate_uniqueness_of(:public_key)
    end
  end
end
