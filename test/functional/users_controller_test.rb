require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  context 'The UsersController' do

    context 'using GET to index with YAML' do

      setup do
        @project = FactoryGirl.create(:project)
        FactoryGirl.create(:membership, :project => @project)
        FactoryGirl.create(:membership, :project => @project)
        get :index, :project_id => @project.to_param, :format => 'yaml'
      end

      should respond_with(:success)

      should "respond with YAML" do
        assert_equal(response.content_type, Mime::YAML)
      end

    end

    context 'using GET to show with YAML' do

      context 'directly' do

        setup do
          @user       = FactoryGirl.create(:user)
          get :show, :id => @user.to_param, :format => 'yaml'
        end

        should respond_with(:success)

        should "respond with YAML" do
          assert_equal(response.content_type, Mime::YAML)
        end

      end

      context 'for a project' do

        context 'for a user of the project' do

          setup do
            @project    = FactoryGirl.create(:project)
            @user       = FactoryGirl.create(:user)
            @membership = FactoryGirl.create(:membership, :project => @project, :user => @user)
            get :show, :project_id => @project.to_param, :id => @user.to_param, :format => 'yaml'
          end

          should respond_with(:success)

          should "respond with YAML" do
            assert_equal(response.content_type, Mime::YAML)
          end

        end

        context 'for a user not in the project' do

          setup do
            @project    = FactoryGirl.create(:project)
            @user       = FactoryGirl.create(:user)
            @membership = FactoryGirl.create(:membership, :project => @project)
          end

          should 'raise RecordNotFound' do
            assert_raise(ActiveRecord::RecordNotFound) do
              get :show, :project_id => @project.to_param, :id => @user.to_param, :format => 'yaml'
            end
          end

        end

      end

    end

  end

end
