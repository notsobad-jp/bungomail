source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.0'

gem 'rails', '~> 6.0'
gem 'pg', '>= 0.18', '< 2.0'
gem "puma", ">= 3.12.2"
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem "haml-rails", "~> 2.0"
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'sorcery'
gem 'dotenv-rails'
gem 'delayed_job_active_record'
gem 'pundit'
gem 'rack', '>= 2.0.6'
gem 'loofah', '>= 2.2.3'
gem 'activerecord-import'
gem 'kaminari'
gem 'rails-i18n'
gem 'stripe'
gem 'pragmatic_tokenizer'
gem 'pragmatic_segmenter'
gem 'lemmatizer'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails'
  gem 'spring-commands-rspec'
  gem 'factory_bot_rails'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'annotate'
  gem 'letter_opener'
  gem 'rack-mini-profiler', require: false
  gem 'rubocop', require: false
  gem "rack-dev-mark"
  gem 'sitemap_generator'

  # 新しいバージョンは複数workerをkillできないバグがあるので古いので固定
  ## https://github.com/collectiveidea/delayed_job/issues/798
  gem 'daemons', '1.1.9'  
end

group :test do
  gem 'vcr'
  gem 'webmock'
  gem 'database_cleaner'
end

group :production do
  gem 'scout_apm'
  gem 'redis'
end
