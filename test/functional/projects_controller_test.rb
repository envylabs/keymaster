require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  
  context 'The ProjectsController' do
    
    context 'using GET to show' do
      
      setup do
        @project = Factory(:project)
        get :show, :id => @project.to_param
      end
      
      should_respond_with               :success
      should_respond_with_content_type  :yaml
      should_assign_to(:project)        { @project }
      
    end
    
  end
  
end
