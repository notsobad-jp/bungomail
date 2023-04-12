Rails.application.routes.draw do
  resources :books, only: [:show]
  resources :book_assignments, shallow: true do
    get :cancel, on: :member
    resources :feeds
  end
  resources :magic_tokens
  resource :user do
    post :webpush_test, on: :member
  end

  get 'auth' => 'magic_tokens#auth'
  get 'login' => 'magic_tokens#new'
  delete 'logout' => 'magic_tokens#destroy'
  get 'mypage' => 'users#show'
  get 'signup' => 'users#new'

  get 'campaigns/dogramagra' => "pages#dogramagra"

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  get '/service-worker.js' => "service_workers#service_worker"
  get '/manifest.json' => "service_workers#manifest"

  get ':page' => "pages#show", as: :page
  root to: 'pages#lp'
end
