# == Route Map
#
#                    Prefix Verb   URI Pattern                                                                                Controller#Action
#              magic_tokens GET    (/:locale)/magic_tokens(.:format)                                                          mailing/magic_tokens#index {:locale=>/ja|en/}
#                           POST   (/:locale)/magic_tokens(.:format)                                                          mailing/magic_tokens#create {:locale=>/ja|en/}
#           new_magic_token GET    (/:locale)/magic_tokens/new(.:format)                                                      mailing/magic_tokens#new {:locale=>/ja|en/}
#          edit_magic_token GET    (/:locale)/magic_tokens/:id/edit(.:format)                                                 mailing/magic_tokens#edit {:locale=>/ja|en/}
#               magic_token GET    (/:locale)/magic_tokens/:id(.:format)                                                      mailing/magic_tokens#show {:locale=>/ja|en/}
#                           PATCH  (/:locale)/magic_tokens/:id(.:format)                                                      mailing/magic_tokens#update {:locale=>/ja|en/}
#                           PUT    (/:locale)/magic_tokens/:id(.:format)                                                      mailing/magic_tokens#update {:locale=>/ja|en/}
#                           DELETE (/:locale)/magic_tokens/:id(.:format)                                                      mailing/magic_tokens#destroy {:locale=>/ja|en/}
#                   charges GET    (/:locale)/charges(.:format)                                                               mailing/charges#index {:locale=>/ja|en/}
#                           POST   (/:locale)/charges(.:format)                                                               mailing/charges#create {:locale=>/ja|en/}
#                new_charge GET    (/:locale)/charges/new(.:format)                                                           mailing/charges#new {:locale=>/ja|en/}
#               edit_charge GET    (/:locale)/charges/:id/edit(.:format)                                                      mailing/charges#edit {:locale=>/ja|en/}
#                    charge GET    (/:locale)/charges/:id(.:format)                                                           mailing/charges#show {:locale=>/ja|en/}
#                           PATCH  (/:locale)/charges/:id(.:format)                                                           mailing/charges#update {:locale=>/ja|en/}
#                           PUT    (/:locale)/charges/:id(.:format)                                                           mailing/charges#update {:locale=>/ja|en/}
#                           DELETE (/:locale)/charges/:id(.:format)                                                           mailing/charges#destroy {:locale=>/ja|en/}
#                books_list GET    (/:locale)/lists/:id/books(.:format)                                                       mailing/lists#books {:locale=>/ja|en/}
#                     lists GET    (/:locale)/lists(.:format)                                                                 mailing/lists#index {:locale=>/ja|en/}
#                           POST   (/:locale)/lists(.:format)                                                                 mailing/lists#create {:locale=>/ja|en/}
#                  new_list GET    (/:locale)/lists/new(.:format)                                                             mailing/lists#new {:locale=>/ja|en/}
#                 edit_list GET    (/:locale)/lists/:id/edit(.:format)                                                        mailing/lists#edit {:locale=>/ja|en/}
#                      list GET    (/:locale)/lists/:id(.:format)                                                             mailing/lists#show {:locale=>/ja|en/}
#                           PATCH  (/:locale)/lists/:id(.:format)                                                             mailing/lists#update {:locale=>/ja|en/}
#                           PUT    (/:locale)/lists/:id(.:format)                                                             mailing/lists#update {:locale=>/ja|en/}
#                           DELETE (/:locale)/lists/:id(.:format)                                                             mailing/lists#destroy {:locale=>/ja|en/}
#             activate_user GET    (/:locale)/users/:id/activate(.:format)                                                    mailing/users#activate {:locale=>/ja|en/}
#      start_trial_now_user POST   (/:locale)/users/:id/start_trial_now(.:format)                                             mailing/users#start_trial_now {:locale=>/ja|en/}
#   pause_subscription_user POST   (/:locale)/users/:id/pause_subscription(.:format)                                          mailing/users#pause_subscription {:locale=>/ja|en/}
#                     users GET    (/:locale)/users(.:format)                                                                 mailing/users#index {:locale=>/ja|en/}
#                           POST   (/:locale)/users(.:format)                                                                 mailing/users#create {:locale=>/ja|en/}
#                  new_user GET    (/:locale)/users/new(.:format)                                                             mailing/users#new {:locale=>/ja|en/}
#                 edit_user GET    (/:locale)/users/:id/edit(.:format)                                                        mailing/users#edit {:locale=>/ja|en/}
#                      user GET    (/:locale)/users/:id(.:format)                                                             mailing/users#show {:locale=>/ja|en/}
#                           PATCH  (/:locale)/users/:id(.:format)                                                             mailing/users#update {:locale=>/ja|en/}
#                           PUT    (/:locale)/users/:id(.:format)                                                             mailing/users#update {:locale=>/ja|en/}
#                           DELETE (/:locale)/users/:id(.:format)                                                             mailing/users#destroy {:locale=>/ja|en/}
#                    signup GET    (/:locale)/signup(.:format)                                                                mailing/users#new {:locale=>/ja|en/}
#                     login GET    (/:locale)/login(.:format)                                                                 mailing/magic_tokens#new {:locale=>/ja|en/}
#                    logout POST   (/:locale)/logout(.:format)                                                                mailing/magic_tokens#destroy {:locale=>/ja|en/}
#                      auth GET    (/:locale)/auth(.:format)                                                                  mailing/magic_tokens#auth {:locale=>/ja|en/}
#      campaigns_dogramagra GET    (/:locale)/campaigns/dogramagra(.:format)                                                  mailing/pages#dogramagra {:locale=>/ja|en/}
#                           GET    (/:locale)/:locale(.:format)                                                               mailing/pages#lp {:locale=>/ja|en/}
#                      page GET    (/:locale)/:page(.:format)                                                                 mailing/pages#show {:locale=>/ja|en/}
#                      root GET    /(:locale)(.:format)                                                                       mailing/pages#lp {:locale=>/ja|en/}
#                           GET    /                                                                                          mailing/pages#lp
#     author_category_books GET    (/:locale)(/:juvenile)/authors/:author_id/categories/:category_id/books(.:format)          search/books#index {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           POST   (/:locale)(/:juvenile)/authors/:author_id/categories/:category_id/books(.:format)          search/books#create {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#  new_author_category_book GET    (/:locale)(/:juvenile)/authors/:author_id/categories/:category_id/books/new(.:format)      search/books#new {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
# edit_author_category_book GET    (/:locale)(/:juvenile)/authors/:author_id/categories/:category_id/books/:id/edit(.:format) search/books#edit {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#      author_category_book GET    (/:locale)(/:juvenile)/authors/:author_id/categories/:category_id/books/:id(.:format)      search/books#show {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           PATCH  (/:locale)(/:juvenile)/authors/:author_id/categories/:category_id/books/:id(.:format)      search/books#update {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           PUT    (/:locale)(/:juvenile)/authors/:author_id/categories/:category_id/books/:id(.:format)      search/books#update {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           DELETE (/:locale)(/:juvenile)/authors/:author_id/categories/:category_id/books/:id(.:format)      search/books#destroy {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#         author_categories GET    (/:locale)(/:juvenile)/authors/:author_id/categories(.:format)                             search/categories#index {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           POST   (/:locale)(/:juvenile)/authors/:author_id/categories(.:format)                             search/categories#create {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#       new_author_category GET    (/:locale)(/:juvenile)/authors/:author_id/categories/new(.:format)                         search/categories#new {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#      edit_author_category GET    (/:locale)(/:juvenile)/authors/:author_id/categories/:id/edit(.:format)                    search/categories#edit {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#           author_category GET    (/:locale)(/:juvenile)/authors/:author_id/categories/:id(.:format)                         search/categories#show {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           PATCH  (/:locale)(/:juvenile)/authors/:author_id/categories/:id(.:format)                         search/categories#update {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           PUT    (/:locale)(/:juvenile)/authors/:author_id/categories/:id(.:format)                         search/categories#update {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           DELETE (/:locale)(/:juvenile)/authors/:author_id/categories/:id(.:format)                         search/categories#destroy {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                   authors GET    (/:locale)(/:juvenile)/authors(.:format)                                                   search/authors#index {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           POST   (/:locale)(/:juvenile)/authors(.:format)                                                   search/authors#create {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                new_author GET    (/:locale)(/:juvenile)/authors/new(.:format)                                               search/authors#new {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#               edit_author GET    (/:locale)(/:juvenile)/authors/:id/edit(.:format)                                          search/authors#edit {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                    author GET    (/:locale)(/:juvenile)/authors/:id(.:format)                                               search/authors#show {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           PATCH  (/:locale)(/:juvenile)/authors/:id(.:format)                                               search/authors#update {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           PUT    (/:locale)(/:juvenile)/authors/:id(.:format)                                               search/authors#update {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           DELETE (/:locale)(/:juvenile)/authors/:id(.:format)                                               search/authors#destroy {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                about_page GET    (/:locale)(/:juvenile)/about(.:format)                                                     search/pages#about {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           GET    (/:locale)(/:juvenile)/:locale(.:format)                                                   search/books#index {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           GET    (/:locale)(/:juvenile)/:juvenile(.:format)                                                 search/books#index {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           GET    (/:locale)(/:juvenile)/:locale/:juvenile(.:format)                                         search/books#index {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#               search_root GET    /(/:locale)(/:juvenile)(.:format)                                                          search/books#index {:subdomain=>"search", :locale=>/ja|en/, :juvenile=>/juvenile/}
#                           GET    /:locale(.:format)                                                                         search/books#index {:subdomain=>"search"}
#             juvenile_root GET    /:juvenile(.:format)                                                                       search/books#index {:subdomain=>"search"}
#        rails_service_blob GET    /rails/active_storage/blobs/:signed_id/*filename(.:format)                                 active_storage/blobs#show
# rails_blob_representation GET    /rails/active_storage/representations/:signed_blob_id/:variation_key/*filename(.:format)   active_storage/representations#show
#        rails_disk_service GET    /rails/active_storage/disk/:encoded_key/*filename(.:format)                                active_storage/disk#show
# update_rails_disk_service PUT    /rails/active_storage/disk/:encoded_token(.:format)                                        active_storage/disk#update
#      rails_direct_uploads POST   /rails/active_storage/direct_uploads(.:format)                                             active_storage/direct_uploads#create

Rails.application.routes.draw do
  # Bungo Mail
  constraints subdomain: ['', 'bungomail-staging'] do
    scope module: :mailing do
      scope "(:locale)", locale: /ja|en/ do
        resources :magic_tokens
        resources :charges
        resources :lists do
          get 'books', on: :member
        end
        resources :users do
          get 'activate', on: :member
          post 'start_trial_now', on: :member
          post 'pause_subscription', on: :member
        end

        get 'signup' => 'users#new'
        get 'login' => 'magic_tokens#new'
        post 'logout' => 'magic_tokens#destroy'
        get 'auth' => 'magic_tokens#auth'

        get '/campaigns/dogramagra' => "pages#dogramagra"
        get '/:locale' => 'pages#lp'
        get 'new_lp' => "pages#new_lp"
        get ':page' => "pages#show", as: :page

        root to: 'pages#lp'
      end
      get '/' => 'pages#lp'
    end
  end

  # Bungo Search
  constraints subdomain: 'search' do
    scope module: :search do
      scope "(:locale)", locale: /ja|en/ do
        scope "(:juvenile)", juvenile: /juvenile/ do
          resources :authors do
            resources :categories do
              resources :books
            end
          end
          get '/about' => "pages#about", as: :about_page
          get '/ranking/:year' => "pages#ranking", as: :ranking
          get '/:locale' => 'books#index'
          get '/:juvenile' => 'books#index'
          get '/:locale/:juvenile' => 'books#index'
          root :to => 'books#index', as: :search_root
        end
      end
      get '/:locale' => 'books#index'
      get '/:juvenile' => 'books#index', as: :juvenile_root
    end
  end
end
