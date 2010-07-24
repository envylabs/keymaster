require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  
  context 'The ProjectsController' do
    
    context 'using GET to show with YAML' do
      
      setup do
        @project = Factory(:project)
        get :show, :id => @project.to_param, :format => 'yaml'
      end

      should respond_with(:success)
      should respond_with_content_type(:yaml)
      should assign_to(:project) { @project }
      
    end
    
  end
  
end
