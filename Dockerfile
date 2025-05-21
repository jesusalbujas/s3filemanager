# how to build?
# docker login
## .....input your docker id and password
#docker build . -t tinyfilemanager/tinyfilemanager:master
#docker push tinyfilemanager/tinyfilemanager:master

# how to use?
# docker run -d -v /absolute/path:/var/www/html/data -p 80:80 --restart=always --name tinyfilemanager tinyfilemanager/tinyfilemanager:master

FROM php:7.4-cli-alpine

# if run in China
# RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories

WORKDIR /var/www/html

RUN apk add --no-cache \
    libzip-dev \
    oniguruma-dev \
    curl \
    bash \
    unzip \
    python3 \
    py3-pip && \
    pip3 install --no-cache-dir s3cmd

RUN docker-php-ext-install \
    zip 

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader

# Create directory of files
RUN mkdir -p /opt/files

# Required resources
COPY resources ./resources
COPY translation.json ./
COPY auth_users.json ./

COPY s3filemanager.php index.php

CMD ["sh", "-c", "php -S 0.0.0.0:80"]
