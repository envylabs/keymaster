require 'test_helper'

class GateKeeperControllerTest < ActionController::TestCase

  context 'The GateKeeperController' do

    context 'using GET to index' do

      setup do
        get :index, :format => 'rb'
      end

      should respond_with(:success)

      should "respond with Ruby" do
        assert_equal(response.content_type, Mime::RB)
      end

    end

  end

end
