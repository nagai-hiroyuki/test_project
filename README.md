[English](./README_en.md)

# 開発環境構築方法

構成

php 8.3  
apache 2.4  
mysql 8.0

エンドユーザーの運用が社内のイントラネット内でWindowsサーバーで動作を前提としています。
先方からの要望によりApacheを使用するため、開発環境もApacheを使用します。

----

## Laravel 

```bash
$ cd ../environments/local/
$ docker compose up -d

# If you are using m1/m2 Apple Silicon chip, please use this command
$ docker compose -f docker-compose.m1.yml up -d
```
docker pullで制限に引っかかって失敗するときはdockerにログインしてやって下さい。


### プロジェクトが作られていない場合、最初の開発者のみ実行してください
```bash
# Only the first developer should run it. 
$ docker compose exec web composer create-project --prefer-dist laravel/laravel . "10.*"
```

### Laravelのインストール

```bash
# if installed
docker compose exec web composer install
$ cd ../../src
$ cp .env.example .env
$ cd ../environments/local/
$ docker compose exec web php artisan key:generate
```

### Laravel Windows

```
# if installed
docker compose exec web composer install

# if there's error 「the input device is not a TTY. If you are using mintty, try prefixing the command with 'winpty'」
# do the following
winpty docker compose exec web composer install

# first time only
cd ../../src
cp .env.example .env
cd ../environments/local/
winpty docker compose exec web php artisan key:generate
```

### Permission
```bash
# if there's error, なら実行する
$ chmod -R 777 ./storage/
```

### .envを編集する
(.env.example を参考にしてください)
```dotenv
DB_CONNECTION=mysql
DB_HOST=mysql
DB_PORT=3306
DB_DATABASE=laravel_db
DB_USERNAME=default
DB_PASSWORD=secret
```

### Migration
```bash
$ cd ../environments/local/
$ docker compose exec web bash
/var/www# php artisan migrate:fresh --seed
```

### Dummy data
```bash
# development only
$ cd ../environments/local/
$ docker compose exec web bash # Entering the Docker container
/var/www# php artisan db:seed --class=DummyDatabaseSeeder # Run inside a container
```

## フロント環境構築
Node v20.11.0 をインストールしてください。  
NVMでInstallする方法
```bash
$ nvm install v20.11.0
```

Nodeのバージョンを変更する
```bash
$ nvm use
```

構築します。
```bash
$ cd src
$ npm install
$ npm run build # OR npm run dev
```

----

### mailpit メールの受信
[http://localhost:8025](http://localhost:8025)


----
