FROM php:8.4-cli

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
    libgmp-dev \
  ;

# Install PHP extensions
RUN docker-php-ext-install \
    bcmath \
    intl \
    pdo_pgsql \
    opcache \
    simplexml \
    xml \
    mbstring \
    sockets \
    gmp \
    pcntl \
  ;
RUN pecl install xdebug event \
    && pecl install ast && docker-php-ext-enable ast \
    && pecl install raphf && docker-php-ext-enable raphf \
    && docker-php-ext-enable xdebug \
    && docker-php-ext-enable event --ini-name zz-event.ini \
    ;

# Remove unrequired packages
RUN apt-get remove -y wget \
    && apt-get autoremove -y \
    && rm -rf /root/.gnupg \
    && apt-get upgrade -y \
  ;

RUN chmod +x /usr/local/bin/entrypoint.sh \
    && echo "xdebug.mode=coverage" >> /usr/local/etc/php/php.ini \
  ;

WORKDIR /app
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
