# Docker file for Silverstripe projects

This is a Dockerfile for Silverstripe projects using a php:5.6 base, and made available at msdeploybot/silverstripe-web:php5.6. It has some useful tools installed such as xdebug, sspak, composer. See below for examples on how to set up a SS 3 site, or see the master branch for how to set up SS 4 / PHP7 site.

# Create a Silverstripe 3 site locally

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
    working_dir: /var/www/html
    volumes:
      - .:/var/www/html
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

### Create a file at root called `_ss_environment.php`

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

## Create a SilverStripe 4 site

You should be able to use this php5.6 environment for a SS 4 site, but you'll need a .htaccess at the root like below. This is because SS4 expects the apache webroot to be the `public` folder.

```
RewriteEngine On
RewriteRule ^(.*)$ public/$1
```

## Console access

```console
$ docker-compose exec web bash
```

# Credits

 - Originally forked from Brett Tasker - [https://github.com/brettt89/silverstripe-web](https://github.com/brettt89/silverstripe-web)
