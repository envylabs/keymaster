require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  
  context 'The UsersController' do
    
    context 'using GET to index' do
      
      setup do
        @project = Factory(:project)
        Factory(:membership, :project => @project)
        Factory(:membership, :project => @project)
        get :index, :project_id => @project.to_param
      end
      
      should_respond_with               :success
      should_respond_with_content_type  :yaml
      should_assign_to(:users)          { @project.users }
      
    end
    
    context 'using GET to show' do
      
      context 'directly' do
        
        setup do
          @user       = Factory(:user)
          get :show, :id => @user.to_param
        end

        should_respond_with               :success
        should_respond_with_content_type  :yaml
        should_assign_to(:user)           { @user }
        
      end
      
      context 'for a project' do
        
        context 'for a user of the project' do
          
          setup do
            @project    = Factory(:project)
            @user       = Factory(:user)
            @membership = Factory(:membership, :project => @project, :user => @user)
            get :show, :project_id => @project.to_param, :id => @user.to_param
          end

          should_respond_with               :success
          should_respond_with_content_type  :yaml
          should_assign_to(:user)           { @user }
          
        end
        
        context 'for a user not in the project' do
          
          setup do
            @request.remote_addr = '1.2.3.4'
            @project    = Factory(:project)
            @user       = Factory(:user)
            @membership = Factory(:membership, :project => @project)
            get :show, :project_id => @project.to_param, :id => @user.to_param
          end

          should_respond_with               :not_found
          
        end
        
      end
      
    end
    
  end
  
end
