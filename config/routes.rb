Rails.application.routes.draw do
  resources :books, only: [:show]
  resources :book_assignments do
    get :cancel, on: :member
  end
  resources :magic_tokens
  resource :user

  get 'auth' => 'magic_tokens#auth'
  get 'login' => 'magic_tokens#new'
  delete 'logout' => 'magic_tokens#destroy'
  get 'mypage' => 'users#show'
  get 'signup' => 'users#new'

  get 'campaigns/dogramagra' => "pages#dogramagra"

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  get ':page' => "pages#show", as: :page
  root to: 'pages#lp'
end
