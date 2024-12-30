Rails.application.routes.draw do
  get 'campaigns/dogramagra' => "pages#dogramagra"

  resources :books, only: [:index, :show]
  resources :campaigns, shallow: true do
    resources :feeds
  end
  resources :magic_tokens
  resources :subscriptions
  resource :user do
    post :webpush_test, on: :member
  end

  get 'auth' => 'magic_tokens#auth'
  get 'login' => 'magic_tokens#new'
  delete 'logout' => 'magic_tokens#destroy'
  get 'mypage' => 'users#show'
  get 'signup' => 'users#new'

  get 'past_campaigns' => "pages#past_campaigns"

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  get ':page' => "pages#show", as: :page
  root to: 'pages#lp'
end
