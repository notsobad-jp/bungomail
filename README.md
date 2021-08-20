# README
## Setup
> bundle install
> bundle exec rails db:create
> bundle exec rails db:migrate
> yarn install
> yarn dev-build

## PostCSS
やってること

- tailwindを読み込み
- purgecssで不要なcssを削除(tailwind.config)
- cssnanoでminify
- postcss-hashでダイジェスト付与、csv_versionでファイル名保存


## Development
devはpurgeしないので、最初に1回buildしたらその後は不要

> yarn dev-build

-> `public/assets/stylesheets/application.css` を出力


## Production
deployしたら、本番用コマンドを自動実行

> yarn build

-> `public/assets/stylesheets/application.xxxx.css` を出力
-> `tmp/csv_version.csv`を出力
