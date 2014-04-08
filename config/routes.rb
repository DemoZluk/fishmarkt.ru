Fishmarkt::Application.routes.draw do

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
  get '/search' => 'products#search'

  resources :line_items do
    member do
      post 'decrement'
      post 'increment'
    end
  end

  get 'cart' => "carts#show"
  delete 'cart' => "carts#destroy"
  get 'cart/:cid/edit' => "carts#edit", as: :edit_cart
  resources :carts

  resources :orders do
    get 'cancel', on: :member
  end

  get 'profile' => 'users#show', as: 'user_root'
  devise_for :users, controllers: { sessions: 'users/sessions', registrations: 'users/registrations' }

  devise_scope :user do
    post '/profile/add_data' => 'users#add_data', as: :add_data
    get 'login' => "users/sessions#new"
    post 'login' => "users/sessions#create"
    delete 'logout' => "users/sessions#destroy"
    get 'sign_up' => "users/registrations#new"
    get 'profile/edit' => "devise/registrations#edit"
    get 'users' => "users#index"
    get 'user/:id' => "users#show", as: :user
  end

  get 'user_prefs' => 'store#change_user_prefs'

  get 'merge_yes' => 'carts#merge_yes'
  get 'merge_no' => 'carts#merge_no'

  get 'admin' => 'admin#index'

  resources :articles do
  end
  get '/:id' => 'articles#show'

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
