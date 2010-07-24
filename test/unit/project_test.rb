require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  
  context 'A Project' do
    
    setup do
      @project = Factory(:project)
    end
    
    subject { @project }
    
    should have_many(:memberships).dependent(:destroy)
    should have_many(:users)
    
    should validate_presence_of(:name)
    
    should validate_uniqueness_of(:name)
    
    should 'use the name for the slug' do
      assert_equal('this-is-a-test', Factory(:project, :name => 'This is a Test').to_param)
    end
    
  end
  
end
