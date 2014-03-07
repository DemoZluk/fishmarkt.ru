Fishmarkt::Application.routes.draw do

  resources :articles

  root 'store#index', as: 'store'

  resources :catalog,  controller: 'groups', as: 'group' do
    # get ':id/page=:page', action: :show, on: :collection
  end
  post '/catalog/:id' => 'groups#show'

  get 'catalog', to: 'store#index'

  resources :products do
    get :who_bought, on: :member
    get :vote, on: :member
  end

  resources :line_items do
    member do
      post 'decrement'
    end
  end

  get 'cart' => "carts#show"
  resources :carts do
  end

  resources :orders

  get 'profile' => 'users#show', as: 'user_root'
  devise_for :users, controllers: { sessions: 'users/sessions' }

  devise_scope :user do
    get 'login' => "users/sessions#new"
    post 'login' => "users/sessions#create"
    delete 'logout' => "users/sessions#destroy"
    get 'sign_up' => "devise/registrations#new"
    get 'profile/edit' => "devise/registrations#edit"
    get 'users' => "users#index"
    get '/users/:id' => "users#show"
  end

  get 'user_prefs' => 'store#change_user_prefs'

  get 'merge_yes' => 'carts#merge_yes'
  get 'merge_no' => 'carts#merge_no'

  get 'admin' => 'admin#index'

  # resources :users

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
