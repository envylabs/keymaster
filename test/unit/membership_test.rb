require 'test_helper'

class MembershipTest < ActiveSupport::TestCase
  
  context 'A Membership' do
    
    setup do
      @membership = Factory(:membership)
    end
    
    subject { @membership }
    
    should_belong_to            :user
    should_belong_to            :project
    
    should_validate_presence_of :user_id,
                                :project_id
    
    should_validate_uniqueness_of :user_id,
                                  :scoped_to      => :project_id,
                                  :case_sensitive => false
    
  end
  
end
