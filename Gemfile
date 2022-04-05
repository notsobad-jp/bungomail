source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.7.0'

gem 'rails', '~> 6.0.3', '>= 6.0.3.4'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 4.3'
gem 'sass-rails'
gem 'uglifier'
gem 'haml-rails'
gem 'jbuilder', '~> 2.7'
gem 'bootsnap', '>= 1.4.2', require: false
gem 'sorcery'
gem 'dotenv-rails'
gem 'delayed_job_active_record'
gem 'pundit'
gem 'kaminari'
gem 'rails-i18n'
gem 'stripe'
gem 'pragmatic_tokenizer'
gem 'pragmatic_segmenter'
gem 'lemmatizer'
gem 'google-api-client'
gem 'trigram' # 文字列の類似度チェック

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'letter_opener'
  gem "rack-dev-mark"
  gem 'sitemap_generator'

  # 新しいバージョンは複数workerをkillできないバグがあるので古いので固定
  ## https://github.com/collectiveidea/delayed_job/issues/798
  gem 'daemons', '1.1.9'
end

group :test do
  gem 'rspec-rails'
  gem 'spring-commands-rspec'
  gem 'factory_bot_rails'
  gem 'database_cleaner'
  gem 'webmock'
  gem 'vcr'
end

group :production do
  gem 'scout_apm'
end
