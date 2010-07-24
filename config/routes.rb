KeymasterNew::Application.routes.draw do
  resources :projects, :only => [:show] do
    resources :users, :only => [:index, :show]
  end

  resources :users, :only => :show

  get '/gatekeeper(.:format)', :to => 'gate_keeper#index', :as => :gatekeeper
end
