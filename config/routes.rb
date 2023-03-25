Rails.application.routes.draw do
  resources :books, only: [:show]
  resources :book_assignments do
    get :cancel, on: :member
  end
  resources :magic_tokens
  resource :user

  get 'signup' => 'users#new'
  get 'campaigns/dogramagra' => "pages#dogramagra"
  get 'login' => 'magic_tokens#new'
  delete 'logout' => 'magic_tokens#destroy'
  get 'auth' => 'magic_tokens#auth'

  # TODO: 新システム移行後は不要
  resources :lists do
    get 'books', on: :member
  end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  get ':page' => "pages#show", as: :page
  root to: 'pages#lp'
end
