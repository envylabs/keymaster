ActionController::Routing::Routes.draw do |map|
  
  map.resources :projects, :only => [:show] do |project|
    project.resources :users, :only => [:index, :show]
  end
  
  map.resources :users, :only => [:show]
  
  map.gatekeeper 'gatekeeper.rb', :controller => 'gate_keeper', :action => 'index', :format => 'rb'
  
end
