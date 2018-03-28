# Docker file for Silverstripe projects

This is a Dockerfile for Silverstripe projects using a php:7.2 base, and made available at msdeploybot/silverstripe-web. It has some useful tools installed such as xdebug, sspak, composer. See below for examples on how to set up a SS 3 or SS 4 site.

# Create a Silverstripe 4 site locally

You can either use `msdeploybot/silverstripe-web`, or build the image yourself locally and give it a name to use as the "image" in the `.yml` below.
```console
$ docker build -t silverstripe-web .
```

### Create a `docker-compose.yml`

```yml
version: '3'
services:
  web:
    image: msdeploybot/silverstripe-web
    working_dir: /var/www
    volumes:
      - .:/var/www
    ports:
      - 8080:80

  database:
    image: mysql
    volumes:
      - db-data:/var/lib/mysql
    restart: always
    environment:
      - MYSQL_ALLOW_EMPTY_PASSWORD=true
      - MYSQL_DATABASE=development

volumes:
  db-data:
```

### Create a `.env`

```
# Environment dev or live
SS_ENVIRONMENT_TYPE="dev"
SS_DEFAULT_ADMIN_USERNAME="admin"
SS_DEFAULT_ADMIN_PASSWORD="password"
SS_BASE_URL="http://localhost:8080/"

# DB credentials
SS_DATABASE_CLASS="MySQLPDODatabase"
SS_DATABASE_SERVER="database"
SS_DATABASE_NAME="development"
SS_DATABASE_USERNAME="root"
SS_DATABASE_PASSWORD=""
```

```console
$ docker-compose up -d
```

## Create a Silverstripe 3 site

Use the same configuration as above except:
 - The `working_dir` and `volumes` in `docker-compose.yml` should be `/var/www/public`
 - Environment variables go into a `_ss_environment.php` file instead

## Console access

```console
$ docker-compose exec web /bin/bash
```

# Credits

 - Originally forked from Brett Tasker - [https://github.com/brettt89/silverstripe-web](https://github.com/brettt89/silverstripe-web)
