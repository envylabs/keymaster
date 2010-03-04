require 'test_helper'

class GateKeeperControllerTest < ActionController::TestCase
  
  context 'The GateKeeperController' do
    
    context 'using GET to index' do
      
      setup do
        get :index, :format => 'rb'
      end
      
      should_respond_with               :success
      should_respond_with_content_type  :rb
      
    end
    
  end
  
end
