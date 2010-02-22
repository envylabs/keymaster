require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  
  context 'A Project' do
    
    setup do
      @project = Factory(:project)
    end
    
    subject { @project }
    
    should_have_many              :memberships, :dependent => :destroy
    
    should_validate_presence_of   :name
    
    should_validate_uniqueness_of :name
    
  end
  
end
