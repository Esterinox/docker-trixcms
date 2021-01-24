FROM alpine:latest
ENV TRIX_PHP_VERSION=7.4
ENV TRIX_DOWNLOAD_LINK=https://miroir.gnumeria.fr/downloads/trixcms.zip

# Installation of dependencies
RUN \
    apk update && \
    apk add apache2 \
    php-apache2 \
    curl \
    wget \
    php-common \
    php-session \
    php-ctype \
    php-bcmath \
    php7-imagick \
    php-pdo \
    php-opcache \
    php-zip \
    php-phar \
    php-iconv \
    php-cli \
    php-curl \
    php-openssl \
    php-mbstring \
    php-tokenizer \
    php-fileinfo \
    php-json \
    php-xml \
    php-xmlwriter \
    php-simplexml \
    php-dom \
    php-pdo_mysql \
    php-pdo_sqlite \
    php-tokenizer \
    composer \
    mysql-client

# Download modules and trixcms
ADD ${TRIX_DOWNLOAD_LINK} /var/www/html/trixcms.zip

RUN sed -i '/LoadModule rewrite_module/s/^#//g' /etc/apache2/httpd.conf && \
    sed -i 's|AllowOverride None|AllowOverride All|g' /etc/apache2/httpd.conf && \
    sed -i 's|/var/www/localhost/htdocs|/var/www/html|g' /etc/apache2/httpd.conf

# Ioncube configuration for docker-php before activation
RUN \
    ARCH_TYPE=$(uname -m) && \
    if [ $ARCH_TYPE -eq armv7l ]; then wget "https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_armv7l.tar.gz" && \
    tar -xvzf ioncube_loaders_lin_armv7l.tar.gz && \
    mv ioncube/ioncube_loader_lin_${TRIX_PHP_VERSION}.so /usr/lib/php7/modules && \
    rm -rf ioncube_loaders_lin_armv7l.tar.gz && \
    rm -rf ioncube && \
    echo 'zend_extension = /usr/lib/php7/modules/ioncube_loader_lin_${TRIX_PHP_VERSION}.so' >  /etc/php7/conf.d/00-ioncube.ini ; \
    else wget "https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz" && \
    tar -xvzf ioncube_loaders_lin_x86-64.tar.gz && \
    mv ioncube/ioncube_loader_lin_${TRIX_PHP_VERSION}.so /usr/lib/php7/modules && \
    echo 'zend_extension = /usr/lib/php7/modules/ioncube_loader_lin_${TRIX_PHP_VERSION}.so' >  /etc/php7/conf.d/00-ioncube.ini && \
    rm -rf ioncube_loaders_lin_x86-64.tar.gz && \
    rm -rf ioncube ; \
    fi

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
    sed -i -e 's/"step2()"/"step3()"/g' /var/www/html/resources/views/Install/home.blade.php && \
    sed -i -e 's/step_3_header: "Etape 3 :/step_3_header: "Etape 2 :/g' /var/www/html/resources/views/Install/home.blade.php && \
    sed -i -e 's/step_4_header: "Etape 4 :/step_4_header: "Etape 3 :/g' /var/www/html/resources/views/Install/home.blade.php && \
    sed -i -e 's/step_3_header: "Step 3 :/step_3_header: "Step 2 :/g' /var/www/html/resources/views/Install/home.blade.php && \
    sed -i -e 's/step_4_header: "Step 4 :/step_4_header: "Step 3 :/g' /var/www/html/resources/views/Install/home.blade.php && \
    sed -i -e 's|<li class="step-bar__item"><a href="#" class="step_bdd"></a></li>||' /var/www/html/resources/views/Install/home.blade.php && \
    sed -i -e 's|<li class="step-bar__item step-bar__item_active"><a href="#" class="step_bdd"></a></li>||' /var/www/html/resources/views/Install/home.blade.php

# Cleaning
RUN \
    unset TRIX_PHP_VERSION && \
    unset TRIX_DOWNLOAD_LINK && \
    unset TRIX_DOWNLOAD_IONCUBE && \
    rm -rf /var/cache/apk/* && \
    rm -rf /var/www/html/trixcms.zip && \
    rm -rf /tmp/* /var/tmp/*

# End
EXPOSE 80
COPY ./docker-entrypoint.sh /
COPY ./testdb.sh /
WORKDIR /var/www/html/
ENTRYPOINT ["/docker-entrypoint.sh"]

