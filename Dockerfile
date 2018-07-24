FROM php:7.2.3-apache
MAINTAINER Matt Lang "<matt@mediasuite.co.nz>"
ENV DEBIAN_FRONTEND=noninteractive

# Install components
RUN apt-get update -y
RUN apt-get install -y \
        curl \
        git-core \
        gzip \
        libcurl4-openssl-dev \
        libgd-dev \
        libldap2-dev \
        libmcrypt-dev \
        libtidy-dev \
        libxslt-dev \
        zlib1g-dev \
        libicu-dev \
        g++ \
        openssh-client \
        libmagickwand-dev \
        unzip \
    --no-install-recommends
RUN curl -sS https://silverstripe.github.io/sspak/install | php -- /usr/local/bin
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer
RUN pecl install xdebug
RUN pecl install imagick-3.4.3
RUN pecl install mcrypt-1.0.1
RUN rm -r /var/lib/apt/lists/*

# Install PHP Extensions
RUN docker-php-ext-configure intl
RUN docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/
RUN docker-php-ext-configure gd --with-jpeg-dir=/usr/include/
RUN docker-php-ext-enable xdebug
RUN docker-php-ext-enable imagick
RUN docker-php-ext-enable mcrypt
RUN sed -i '1 a xdebug.remote_autostart=true' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN sed -i '1 a xdebug.remote_mode=req' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN sed -i '1 a xdebug.remote_handler=dbgp' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN sed -i '1 a xdebug.remote_connect_back=1 ' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN sed -i '1 a xdebug.remote_port=9000' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN sed -i '1 a xdebug.remote_host=127.0.0.1' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN sed -i '1 a xdebug.remote_enable=1' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
RUN docker-php-ext-install -j$(nproc) \
        intl \
        gd \
        ldap \
        pdo \
        pdo_mysql \
        soap \
        tidy \
        xsl \
        opcache

# Apache + xdebug configuration
RUN { \
        echo "<VirtualHost *:80>"; \
        echo "  DocumentRoot /var/www/public"; \
        echo "  LogLevel warn"; \
        echo "  ErrorLog /var/log/apache2/error.log"; \
        echo "  CustomLog /var/log/apache2/access.log combined"; \
        echo "  ServerSignature Off"; \
        echo "  <Directory /var/www/public>"; \
        echo "    Options +FollowSymLinks"; \
        echo "    Options -ExecCGI -Includes -Indexes"; \
        echo "    AllowOverride all"; \
        echo; \
        echo "    Require all granted"; \
        echo "  </Directory>"; \
        echo "  <LocationMatch assets/>"; \
        echo "    php_flag engine off"; \
        echo "  </LocationMatch>"; \
        echo; \
        echo "  IncludeOptional sites-available/000-default.local*"; \
        echo "</VirtualHost>"; \
    } | tee /etc/apache2/sites-available/000-default.conf

RUN echo "ServerName localhost" > /etc/apache2/conf-available/fqdn.conf
RUN echo "date.timezone = Pacific/Auckland" > /usr/local/etc/php/conf.d/timezone.ini
RUN a2enmod rewrite expires remoteip cgid
RUN usermod -u 1000 www-data
RUN usermod -G staff www-data

EXPOSE 80
CMD ["apache2-foreground"]
