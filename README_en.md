[日本語](./README.md)

# Starting up the Development Environment

Middleware

php 8.3  
apache 2.4  
mysql 8.0

Operations for end users are performed on a Windows server within the company intranet.
Since Apache is used at the client's request, the development environment also uses Apache.

----

## Laravel 

```bash
$ cd ../environments/local/
$ docker compose up -d

# If you are using m1/m2 Apple Silicon chip, please use this command
$ docker compose -f docker-compose.m1.yml up -d
```
If you encounter issues with docker pull command, please login with docker


### Execute this if there is no Laravel installed. Only the first developer should execute.
```bash
# Only the first developer should run it. 
$ docker compose exec web composer create-project --prefer-dist laravel/laravel . "10.*"
```

### Install Laravel

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
# if there's error, execute the following within docker container.
$ chmod -R 777 ./storage/
```

### Modify .env
(Please check out from .env.example)
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

## Frontend Development
Install Node v20.11.0  
How to Install with NVM
```bash
$ nvm install v20.11.0
```

Change the version of Node
```bash
$ nvm use
```

Build
```bash
$ cd src
$ npm install
$ npm run build # OR npm run dev
```

----

### mailpit
[http://localhost:8025](http://localhost:8025)


----
