FROM php:8.3-cli

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Install apt packages
RUN set -x \
  && apt-get update \
  && apt-get install --no-install-recommends -y \
    wget \
    gnupg \
    gosu \
    git \
    unzip \
    libssl-dev \
    libpq-dev \
    libicu-dev \
    libxml2-dev \
    libonig-dev \
    libcurl4-openssl-dev \
    libfreetype6-dev \
    zlib1g-dev \
    libevent-dev \
    libicu-dev \
    libidn11-dev \
    libidn2-0-dev \
  ;

# Install PHP extensions
RUN docker-php-ext-install \
    intl \
    pdo_pgsql \
    opcache \
    simplexml \
    xml \
    mbstring \
  ;
RUN pecl install xdebug \
    && pecl install ast raphf && docker-php-ext-enable ast raphf \
    && pecl install pecl_http && docker-php-ext-enable http

# Remove unrequired packages
RUN apt-get remove -y wget \
    && apt-get autoremove -y \
    && rm -rf /root/.gnupg \
    && apt-get upgrade -y \
  ;

RUN chmod +x /usr/local/bin/entrypoint.sh \
    && echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20230831/xdebug.so" >> /usr/local/etc/php/php.ini \
    && echo "xdebug.mode=coverage" >> /usr/local/etc/php/php.ini \
  ;

WORKDIR /app
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
