require 'test_helper'

class MembershipTest < ActiveSupport::TestCase

  context 'A Membership' do

    setup do
      @membership = FactoryGirl.create(:membership)
    end

    subject { @membership }

    should belong_to(:user)
    should belong_to(:project)

    should validate_presence_of(:user_id)
    should validate_presence_of(:project_id)

    should validate_uniqueness_of(:user_id).scoped_to(:project_id).case_insensitive

  end

end
