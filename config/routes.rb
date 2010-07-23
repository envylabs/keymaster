KeymasterNew::Application.routes.draw do |map|
  resources :projects, :only => [:show] do
    resources :users, :only => [:index, :show]
  end

  resources :users, :only => :show

  get '/gatekeeper(.:format)', :to => 'gate_keeyer#index', :as => :gatekeeper
end
