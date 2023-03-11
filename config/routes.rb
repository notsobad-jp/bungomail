Rails.application.routes.draw do
  namespace :memberships do
    get 'new'
    get 'create'
    get 'completed'
    get 'edit'
    post 'update'
  end

  resources :subscriptions
  resources :books, only: [:show]
  resources :users
  resources :book_assignments do
    get :cancel, on: :member
  end
  resources :channels do
    get :feed, on: :member, defaults: { format: :rss }
  end

  get '/campaigns/dogramagra' => "pages#dogramagra"

  # TODO: 新システム移行後は不要
  resources :lists do
    get 'books', on: :member
  end

  get 'lp_new' => "pages#lp_new"
  get ':page' => "pages#show", as: :page
  root to: 'pages#lp'
end
