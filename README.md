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
