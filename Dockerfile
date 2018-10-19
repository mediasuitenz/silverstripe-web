FROM php:7.2.3-apache
MAINTAINER Matt Lang "<matt@mediasuite.co.nz>"
ENV DEBIAN_FRONTEND=noninteractive

# Install components
RUN apt-get update -y && \
    apt-get install -y \
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
        zip \
        mysql-client \
        --no-install-recommends && \
    curl -sS https://silverstripe.github.io/sspak/install | php -- /usr/local/bin && \
    curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer && \
    pecl install xdebug && \
    pecl install imagick-3.4.3 && \
    pecl install mcrypt-1.0.1 && \
    apt-get autoremove -y && \
    rm -r /var/lib/apt/lists/*

# Install PHP Extensions
RUN docker-php-ext-configure intl && \
    docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
    docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-enable xdebug imagick mcrypt && \
    sed -i '1 a xdebug.remote_autostart=true' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    sed -i '1 a xdebug.remote_mode=req' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    sed -i '1 a xdebug.remote_handler=dbgp' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    sed -i '1 a xdebug.remote_connect_back=1 ' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    sed -i '1 a xdebug.remote_port=9000' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    sed -i '1 a xdebug.remote_host=127.0.0.1' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    sed -i '1 a xdebug.remote_enable=1' /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini && \
    docker-php-ext-install -j$(nproc) \
        intl \
        gd \
        ldap \
        pdo \
        pdo_mysql \
        soap \
        tidy \
        xsl \
        zip \
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

RUN echo "ServerName localhost" > /etc/apache2/conf-available/fqdn.conf && \
    echo "date.timezone = Pacific/Auckland" > /usr/local/etc/php/conf.d/timezone.ini && \
    a2enmod rewrite expires remoteip cgid && \
    usermod -u 1000 www-data && \
    usermod -G staff www-data

EXPOSE 80
CMD ["apache2-foreground"]
