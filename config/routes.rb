# == Route Map
#
#                       Prefix Verb   URI Pattern                                                                              Controller#Action
#                 magic_tokens GET    /magic_tokens(.:format)                                                                  magic_tokens#index {:subdomain=>""}
#                              POST   /magic_tokens(.:format)                                                                  magic_tokens#create {:subdomain=>""}
#              new_magic_token GET    /magic_tokens/new(.:format)                                                              magic_tokens#new {:subdomain=>""}
#             edit_magic_token GET    /magic_tokens/:id/edit(.:format)                                                         magic_tokens#edit {:subdomain=>""}
#                  magic_token GET    /magic_tokens/:id(.:format)                                                              magic_tokens#show {:subdomain=>""}
#                              PATCH  /magic_tokens/:id(.:format)                                                              magic_tokens#update {:subdomain=>""}
#                              PUT    /magic_tokens/:id(.:format)                                                              magic_tokens#update {:subdomain=>""}
#                              DELETE /magic_tokens/:id(.:format)                                                              magic_tokens#destroy {:subdomain=>""}
#              activate_charge POST   /charges/:id/activate(.:format)                                                          charges#activate {:subdomain=>""}
#                      charges GET    /charges(.:format)                                                                       charges#index {:subdomain=>""}
#                              POST   /charges(.:format)                                                                       charges#create {:subdomain=>""}
#                   new_charge GET    /charges/new(.:format)                                                                   charges#new {:subdomain=>""}
#                  edit_charge GET    /charges/:id/edit(.:format)                                                              charges#edit {:subdomain=>""}
#                       charge GET    /charges/:id(.:format)                                                                   charges#show {:subdomain=>""}
#                              PATCH  /charges/:id(.:format)                                                                   charges#update {:subdomain=>""}
#                              PUT    /charges/:id(.:format)                                                                   charges#update {:subdomain=>""}
#                              DELETE /charges/:id(.:format)                                                                   charges#destroy {:subdomain=>""}
#               update_payment GET    /update_payment(.:format)                                                                charges#update_payment {:subdomain=>""}
# webhooks_update_subscription POST   /webhooks/update_subscription(.:format)                                                  webhooks#update_subscription {:subdomain=>""}
#                        login GET    /login(.:format)                                                                         magic_tokens#new {:subdomain=>""}
#                         auth GET    /auth(.:format)                                                                          magic_tokens#auth {:subdomain=>""}
#                       logout POST   /logout(.:format)                                                                        magic_tokens#destroy {:subdomain=>""}
#                      en_root GET    /en(.:format)                                                                            pages#lp_en {:subdomain=>""}
#         campaigns_dogramagra GET    /campaigns/dogramagra(.:format)                                                          pages#dogramagra {:subdomain=>""}
#                         page GET    /:page(.:format)                                                                         pages#show {:subdomain=>""}
#                         root GET    /                                                                                        pages#lp {:subdomain=>""}
#        author_category_books GET    /authors/:author_id/categories/:category_id/books(.:format)                              search/books#index {:subdomain=>"search"}
#                              POST   /authors/:author_id/categories/:category_id/books(.:format)                              search/books#create {:subdomain=>"search"}
#     new_author_category_book GET    /authors/:author_id/categories/:category_id/books/new(.:format)                          search/books#new {:subdomain=>"search"}
#    edit_author_category_book GET    /authors/:author_id/categories/:category_id/books/:id/edit(.:format)                     search/books#edit {:subdomain=>"search"}
#         author_category_book GET    /authors/:author_id/categories/:category_id/books/:id(.:format)                          search/books#show {:subdomain=>"search"}
#                              PATCH  /authors/:author_id/categories/:category_id/books/:id(.:format)                          search/books#update {:subdomain=>"search"}
#                              PUT    /authors/:author_id/categories/:category_id/books/:id(.:format)                          search/books#update {:subdomain=>"search"}
#                              DELETE /authors/:author_id/categories/:category_id/books/:id(.:format)                          search/books#destroy {:subdomain=>"search"}
#            author_categories GET    /authors/:author_id/categories(.:format)                                                 search/categories#index {:subdomain=>"search"}
#                              POST   /authors/:author_id/categories(.:format)                                                 search/categories#create {:subdomain=>"search"}
#          new_author_category GET    /authors/:author_id/categories/new(.:format)                                             search/categories#new {:subdomain=>"search"}
#         edit_author_category GET    /authors/:author_id/categories/:id/edit(.:format)                                        search/categories#edit {:subdomain=>"search"}
#              author_category GET    /authors/:author_id/categories/:id(.:format)                                             search/categories#show {:subdomain=>"search"}
#                              PATCH  /authors/:author_id/categories/:id(.:format)                                             search/categories#update {:subdomain=>"search"}
#                              PUT    /authors/:author_id/categories/:id(.:format)                                             search/categories#update {:subdomain=>"search"}
#                              DELETE /authors/:author_id/categories/:id(.:format)                                             search/categories#destroy {:subdomain=>"search"}
#                      authors GET    /authors(.:format)                                                                       search/authors#index {:subdomain=>"search"}
#                              POST   /authors(.:format)                                                                       search/authors#create {:subdomain=>"search"}
#                   new_author GET    /authors/new(.:format)                                                                   search/authors#new {:subdomain=>"search"}
#                  edit_author GET    /authors/:id/edit(.:format)                                                              search/authors#edit {:subdomain=>"search"}
#                       author GET    /authors/:id(.:format)                                                                   search/authors#show {:subdomain=>"search"}
#                              PATCH  /authors/:id(.:format)                                                                   search/authors#update {:subdomain=>"search"}
#                              PUT    /authors/:id(.:format)                                                                   search/authors#update {:subdomain=>"search"}
#                              DELETE /authors/:id(.:format)                                                                   search/authors#destroy {:subdomain=>"search"}
#                              GET    /:page(.:format)                                                                         search/pages#show {:subdomain=>"search"}
#                              GET    /.amp(.:format)                                                                          search/books#index {:subdomain=>"search"}
#                              GET    /                                                                                        search/books#index {:subdomain=>"search"}
#           rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                               active_storage/blobs#show
#    rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format) active_storage/representations#show
#           rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                              active_storage/disk#show
#    update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                      active_storage/disk#update
#         rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                           active_storage/direct_uploads#create

Rails.application.routes.draw do
  constraints subdomain: '' do
    resources :users
    resources :charges do
      post 'activate', on: :member
    end
    get 'update_payment' => 'charges#update_payment'
    post 'webhooks/update_subscription'

    get 'login' => 'magic_tokens#new', as: :login
    get 'auth' => 'magic_tokens#auth', as: :auth
    post 'logout' => 'magic_tokens#destroy', as: :logout

    #TMP: 海外版旧URL（サブディレクトリ）から新URL（サブドメイン）にリダイレクト
    get  "/en" => redirect(subdomain: :en, path: '/')

    get '/campaigns/dogramagra' => "pages#dogramagra"
    get '/:page' => "pages#show", as: :page

    root to: 'pages#lp'
  end


  # English ver.
  constraints subdomain: 'en' do
    scope module: :en do
      resources :users

      get 'login' => 'magic_tokens#new'
      get 'auth' => 'magic_tokens#auth'
      post 'logout' => 'magic_tokens#destroy'
      get 'mypage' => "users#mypage", as: :mypage

      root to: 'pages#lp'
    end
  end


  # ZORA SEARCH
  constraints subdomain: 'search' do
    scope module: :search do
      resources :authors do
        resources :categories do
          resources :books
        end
      end
      get '/:page' => "pages#show"
      get '/.amp' => 'books#index'
      root to: 'books#index'
    end
  end
end
