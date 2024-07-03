FROM php:8.3-fpm as production
COPY ./conf/php.ini /usr/local/etc/php/

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
  && docker-php-source delete

COPY --from=composer:2.6.5 /usr/bin/composer /usr/local/bin/composer

RUN rm /etc/localtime \
  && cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

#cron Cronを動かしたいならば、コメントアウトを外す/ If you want to run Cron, uncomment it
#RUN apt-get update && apt-get install -y cron && apt-get clean && rm -rf /var/lib/apt/lists/*
# ADD ./conf/crontabs /var/spool/cron/crontabs/
# RUN chmod 600 /var/spool/cron/crontabs/*
#COPY ./conf/supervisord.d/cron._conf /etc/supervisord.d/cron.conf

# Set Supervisor Configs
COPY ./conf/supervisord.conf /etc/supervisord.conf
COPY ./conf/supervisord.d /etc/supervisord.d

WORKDIR /var/www

CMD sh -c 'supervisord -c /etc/supervisord.conf'


FROM production as local

# xdebug
RUN pecl install xdebug && docker-php-ext-enable xdebug
COPY ./conf/xdebug.ini /usr/local/etc/php/conf.d/xdebug.ini

# vim
RUN apt-get update && apt-get install -y vim procps \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

# alias
RUN echo "alias ll='ls -alF'\nalias la='ls -A'\nalias l='ls -CF'" >> /root/.bashrc
