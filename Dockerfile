FROM alpine:latest
ENV TRIX_PHP_VERSION=7.4
ENV TRIX_DOWNLOAD_LINK=https://miroir.gnumeria.fr/downloads/trixcms.zip

# Installation of dependencies
RUN \ 
    apk update && \
    apk add \
    curl \
    wget \
    composer \
    mysql-client \
    apache2 \
    php$(echo ${TRIX_PHP_VERSION} | cut -c1)-apache2 \
    php$(echo ${TRIX_PHP_VERSION} | cut -c1)-common \
    php$(echo ${TRIX_PHP_VERSION} | cut -c1)-session \
    php$(echo ${TRIX_PHP_VERSION} | cut -c1)-ctype \
    php$(echo ${TRIX_PHP_VERSION} | cut -c1)-bcmath \
    php$(echo ${TRIX_PHP_VERSION} | cut -c1)-imagick \
    php$(echo ${TRIX_PHP_VERSION} | cut -c1)-pdo \
    php$(echo ${TRIX_PHP_VERSION} | cut -c1)-opcache \
    php$(echo ${TRIX_PHP_VERSION} | cut -c1)-zip \
    php$(echo ${TRIX_PHP_VERSION} | cut -c1)-phar \
    php$(echo ${TRIX_PHP_VERSION} | cut -c1)-iconv \
    php$(echo ${TRIX_PHP_VERSION} | cut -c1)-cli \
    php$(echo ${TRIX_PHP_VERSION} | cut -c1)-curl \
    php$(echo ${TRIX_PHP_VERSION} | cut -c1)-openssl \
    php$(echo ${TRIX_PHP_VERSION} | cut -c1)-mbstring \
    php$(echo ${TRIX_PHP_VERSION} | cut -c1)-tokenizer \
    php$(echo ${TRIX_PHP_VERSION} | cut -c1)-fileinfo \
    php$(echo ${TRIX_PHP_VERSION} | cut -c1)-json \
    php$(echo ${TRIX_PHP_VERSION} | cut -c1)-xml \
    php$(echo ${TRIX_PHP_VERSION} | cut -c1)-xmlwriter \
    php$(echo ${TRIX_PHP_VERSION} | cut -c1)-simplexml \
    php$(echo ${TRIX_PHP_VERSION} | cut -c1)-dom \
    php$(echo ${TRIX_PHP_VERSION} | cut -c1)-pdo_mysql \
    php$(echo ${TRIX_PHP_VERSION} | cut -c1)-pdo_sqlite \
    php$(echo ${TRIX_PHP_VERSION} | cut -c1)-tokenizer

# Download modules and trixcms
ADD ${TRIX_DOWNLOAD_LINK} /var/www/html/trixcms.zip

RUN sed -i '/LoadModule rewrite_module/s/^#//g' /etc/apache2/httpd.conf && \
    sed -i 's|AllowOverride None|AllowOverride All|g' /etc/apache2/httpd.conf && \
    sed -i 's|/var/www/localhost/htdocs|/var/www/html|g' /etc/apache2/httpd.conf

# Ioncube configuration for docker-php before activation
ADD https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz .
RUN \
    tar -xvzf ioncube_loaders_lin_x86-64.tar.gz && \
    cp ioncube/ioncube_loader_lin_${TRIX_PHP_VERSION}.so /usr/lib/php$(echo ${TRIX_PHP_VERSION} | cut -c1)/modules && \
    rm -rf ioncube_loaders_lin_x86-64.tar.gz && \
    rm -rf ioncube && \
    echo "zend_extension = /usr/lib/php$(echo ${TRIX_PHP_VERSION} | cut -c1)/modules/ioncube_loader_lin_${TRIX_PHP_VERSION}.so" >  /etc/php$(echo ${TRIX_PHP_VERSION} | cut -c1)/conf.d/00-ioncube.ini

# Placement of trixcms and its rights
RUN \
    unzip /var/www/html/trixcms.zip -d /var/www/html/ && \
    chown -R apache:apache /var/www/html/

ADD https://cdn.discordapp.com/attachments/655416344660934686/802564066132230165/grp.zip /var/www/html/public/installation
RUN \
    rm /var/www/html/public/installation/ajax_install_dep.php /var/www/html/public/installation/func.php /var/www/html/public/installation/install.php && \
    unzip /var/www/html/public/installation/grp.zip -d /var/www/html/public/installation && \
    chown apache:apache /var/www/html/public/installation/*

# Installer modification for database support
RUN \
    sed -i -e 's|"step2()"|"step3()"|g' /var/www/html/resources/views/Install/home.blade.php && \
    sed -i -e 's|step_3_header: "Etape 3 :|step_3_header: "Etape 2 :|g' /var/www/html/resources/views/Install/home.blade.php && \
    sed -i -e 's|step_4_header: "Etape 4 :|step_4_header: "Etape 3 :|g' /var/www/html/resources/views/Install/home.blade.php && \
    sed -i -e 's|step_3_header: "Step 3 :|step_3_header: "Step 2 :|g' /var/www/html/resources/views/Install/home.blade.php && \
    sed -i -e 's|step_4_header: "Step 4 :|step_4_header: "Step 3 :|g' /var/www/html/resources/views/Install/home.blade.php && \
    sed -i -e 's|<li class="step-bar__item"><a href="#" class="step_bdd"></a></li>||' /var/www/html/resources/views/Install/home.blade.php && \
    sed -i -e 's|<li class="step-bar__item step-bar__item_active"><a href="#" class="step_bdd"></a></li>||' /var/www/html/resources/views/Install/home.blade.php

# Cleaning
RUN \
    unset TRIX_PHP_VERSION && \
    unset TRIX_DOWNLOAD_LINK && \
    rm -rf /var/cache/apk/* && \
    rm -rf /var/www/html/trixcms.zip && \
    rm -rf /tmp/* /var/tmp/*

# End
EXPOSE 80
COPY ./docker-entrypoint.sh /
COPY ./testdb.sh /
WORKDIR /var/www/html/
ENTRYPOINT ["/docker-entrypoint.sh"]

