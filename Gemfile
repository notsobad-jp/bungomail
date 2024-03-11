source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.4'
gem 'rails', '7.0.8.1'

gem 'bootsnap', require: false
gem 'dotenv-rails'
gem 'delayed_job_active_record'
gem 'google-api-client'
gem 'haml-rails'
gem 'importmap-rails'
gem 'jbuilder'
gem 'kaminari'
gem 'lemmatizer'
gem 'pg'
gem 'pragmatic_segmenter'
gem 'pragmatic_tokenizer'
gem 'propshaft'
gem 'puma'
gem 'pundit'
gem 'rails-i18n'
gem 'sorcery'
gem 'stimulus-rails'
gem 'stripe'
gem "tailwindcss-rails"
gem 'trigram' # 文字列の類似度チェック
gem 'uglifier'
gem 'turbo-rails'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'letter_opener'
  gem 'letter_opener_web'
  gem 'listen'
  gem "rack-dev-mark"
  gem 'sitemap_generator'
  gem 'web-console'
end

group :test do
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'rspec-rails'
  gem 'vcr'
  gem 'webmock'
end

group :production do
  gem 'scout_apm'
end
