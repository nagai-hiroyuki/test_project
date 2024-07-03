# image
FROM php:8.1-apache as production

# composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set php.ini
COPY ./conf/php.ini /usr/local/etc/php/

# Enable mod_rewrite
RUN a2enmod rewrite

# Set apache conf
ENV APACHE_DOCUMENT_ROOT /var/www/public
# RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf


RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    libxml2-dev \
    supervisor \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev \
    libzip-dev \
    tzdata \
    libonig-dev \
    libcurl4-openssl-dev \
    imagemagick \
    libmagickwand-dev \
    libreoffice \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j$(nproc) \
    opcache \
    pdo_mysql \
    mbstring \
    xml \
    curl \
    session \
    iconv \
    gd \
    exif \
    zip \
  && pecl install imagick redis \
  && docker-php-ext-enable imagick redis \
  && docker-php-source delete \


WORKDIR /var/www

FROM production as local

# vim
RUN apt-get update && apt-get install -y vim
# alias
RUN echo "alias ll='ls -alF'\nalias la='ls -A'\nalias l='ls -CF'" >> /root/.bashrc
