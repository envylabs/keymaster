require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase

  context 'The ProjectsController' do

    context 'using GET to show with YAML' do

      setup do
        @project = FactoryGirl.create(:project)
        get :show, :id => @project.to_param, :format => 'yaml'
      end

      should respond_with(:success)

      should "respond with YAML" do
        assert_equal(response.content_type, Mime::YAML)
      end

    end

  end

end
