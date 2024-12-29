# README
## Docker Setup
```bash
$ docker-compose build
$ docker-compose run web rails db:create
$ docker-compose run web rails db:migrate
$ heroku pg:backups:download -a bungomail # 本番DBをlatest.dumpにダウンロード
$ docker-compose exec web bash # webコンテナに入る
$ pg_restore --verbose --clean --no-acl --no-owner -h db -U postgres -d bungomail_development latest.dump # dbコンテナにリストア
```

## 各種キー等の設定
- config
  - master.key
  - credentials
    - development.key
    - production.key
- functions
  - serviceAccountKey.json


## npmインストール
FCMでプッシュ通知を使うために、`/functions`配下にfirebase用の実装を置いてる。

```bash
cd functions
npm install
```