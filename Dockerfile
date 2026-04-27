FROM debian:12.7

# Evita preguntas interactivas durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Actualización del sistema e instalación de dependencias
RUN apt-get update -y && \
    apt-get upgrade -y && \
    apt-get install -y \
        wget \
        build-essential \
        pkg-config \
        libxml2-dev \
        libsqlite3-dev \
        libzip-dev \
        libssl-dev \
        libcurl4-openssl-dev \
        libonig-dev \
        dialog \
        apt-utils \
        php8.2-mysql \
        libgmp-dev \
        libicu-dev \
        zip && \
    rm -rf /var/lib/apt/lists/*

# Descargar, compilar e instalar PHP 8.1.28
RUN wget https://www.php.net/distributions/php-8.1.28.tar.gz && \
    tar -xzvf php-8.1.28.tar.gz && \
    cd php-8.1.28 && \
    ./configure \
        --with-curl \
        --with-pdo-mysql \
        --with-pdo-mysql=mysqlnd \
        --with-openssl \
        --enable-mbstring && \
        --with-gmp && \
        --enable-ftp && \
        --enable-intl && \
        --with-zip && \
    make && \
    make install && \
    cp php.ini-production /usr/local/lib/php.ini && \
    cd .. && \
    rm -rf php-8.1.28 php-8.1.28.tar.gz

# Instalar Composer 2.5.8
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('sha384', 'composer-setup.php') === 'dac665fdc30fdd8ec78b38b9800061b4150413ff2e3b6f88543c636f7cd84f6db9189d43a81e5503cda447da73c7e5b6') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --version=2.5.8 && \
    rm composer-setup.php && \
    mv composer.phar /usr/local/bin/composer

# Permitir Composer como root (solo en build)
ENV COMPOSER_ALLOW_SUPERUSER=1

# Verificaciones útiles
RUN php -v && composer -v

EXPOSE 80

CMD ["/bin/bash"]
