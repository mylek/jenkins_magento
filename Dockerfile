FROM php:8.1-fpm

COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN apt-get update && apt-get install -y \
  gzip \
  libbz2-dev \
  libfreetype6-dev \
  libicu-dev \
  libjpeg-dev \
  libjpeg62-turbo-dev \
  libmcrypt-dev \
  libpng-dev \
  libsodium-dev \
  libssh2-1-dev \
  libxslt1-dev \
  libzip-dev \
  libonig-dev \
  lsof \
  default-mysql-client \
  zip

#RUN docker-php-ext-configure \
#  gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
RUN docker-php-ext-configure gd --enable-gd --prefix=/usr --with-jpeg --with-freetype && \
    docker-php-ext-install gd

RUN docker-php-ext-install \
  bcmath \
  bz2 \
  calendar \
  exif \
  gettext \
  intl \
  mbstring\
  mysqli \ 
  opcache \
  pcntl \
  pdo_mysql \
  soap \
  sockets \
  sodium \
  sysvmsg \
  sysvsem \
  sysvshm \
  xsl \
  zip

RUN pecl install xdebug && docker-php-ext-enable xdebug

RUN apt-get install -y git

RUN mv "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"

RUN echo 'memory_limit = 2048M' >> /usr/local/etc/php/conf.d/docker-php-memlimit.ini;

RUN mkdir -p /var/www/html \
   && chown -R www-data:www-data /var/www

USER www-data:www-data
VOLUME /var/www
WORKDIR /var/www/html
