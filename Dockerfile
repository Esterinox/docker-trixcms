FROM php:7.4-apache-buster
ENV TRIX_PHP_VERSION=7.4
ENV TRIX_DOWNLOAD_LINK=https://miroir.gnumeria.fr/downloads/trixcms.zip
ENV TRIX_DOWNLOAD_IONCUBE=https://downloads.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz

# Installation of dependencies
RUN \
    apt-get update --no-install-recommends -yqq && \
    apt-get install --no-install-recommends -yqq \
    cron \
    libbz2-dev \
    libzip-dev \
    libxml2-dev \
    libicu-dev \
    libonig5 \
    libonig-dev \
    libpng-dev \
    libmagickwand-dev \
    zlib1g-dev \
    default-mysql-client \
    unzip

# Download modules and trixcms
ADD ${TRIX_DOWNLOAD_LINK} /var/www/html/trixcms.zip
ADD ${TRIX_DOWNLOAD_IONCUBE} .

# Ioncube configuration for docker-php before activation
RUN \
    tar -xvzf ioncube_loaders_lin_x86-64.tar.gz && \
    mv ioncube/ioncube_loader_lin_${TRIX_PHP_VERSION}.so `php-config --extension-dir` && \
    rm -rf ioncube_loaders_lin_x86-64.tar.gz && \
    rm -rf ioncube

# Placement of trixcms and its rights
RUN \
    unzip /var/www/html/trixcms.zip -d /var/www/html/ && \
    chown -R www-data:www-data /var/www/html && \
    a2enmod rewrite

################################################### PATCH INSTALLER ###################################################
ADD https://cdn.discordapp.com/attachments/655416344660934686/802564066132230165/grp.zip /var/www/html/public/installation
RUN \
    rm /var/www/html/public/installation/ajax_install_dep.php && \
    rm /var/www/html/public/installation/func.php && \
    rm /var/www/html/public/installation/install.php && \
    unzip /var/www/html/public/installation/grp.zip -d /var/www/html/public/installation && \
    chown -R www-data:www-data /var/www/html/public/installation
#######################################################################################################################

# Installer modification for database support
RUN \
    sed -i -e 's/"step2()"/"step3()"/g' /var/www/html/resources/views/Install/home.blade.php && \
    sed -i -e 's/step_3_header: "Etape 3 :/step_3_header: "Etape 2 :/g' /var/www/html/resources/views/Install/home.blade.php && \
    sed -i -e 's/step_4_header: "Etape 4 :/step_4_header: "Etape 3 :/g' /var/www/html/resources/views/Install/home.blade.php && \
    sed -i -e 's/step_3_header: "Step 3 :/step_3_header: "Step 2 :/g' /var/www/html/resources/views/Install/home.blade.php && \
    sed -i -e 's/step_4_header: "Step 4 :/step_4_header: "Step 3 :/g' /var/www/html/resources/views/Install/home.blade.php && \
    sed -i -e 's|<li class="step-bar__item"><a href="#" class="step_bdd"></a></li>||' /var/www/html/resources/views/Install/home.blade.php && \
    sed -i -e 's|<li class="step-bar__item step-bar__item_active"><a href="#" class="step_bdd"></a></li>||' /var/www/html/resources/views/Install/home.blade.php

# Installation of the required php modules
RUN \
    pecl install imagick && \
    docker-php-ext-enable imagick && \
    docker-php-ext-enable ioncube_loader_lin_${TRIX_PHP_VERSION} && \
    docker-php-ext-configure mysqli && docker-php-ext-install mysqli && \
    docker-php-ext-configure pdo_mysql && docker-php-ext-install pdo_mysql && \
    docker-php-ext-configure intl && docker-php-ext-install intl && \
    docker-php-ext-configure bcmath && docker-php-ext-install bcmath && \
    docker-php-ext-configure zip && docker-php-ext-install zip && \
    docker-php-ext-configure bz2 && docker-php-ext-install bz2

# Cleaning
RUN \
    apt-get clean && \
    unset TRIX_PHP_VERSION && \
    unset TRIX_DOWNLOAD_LINK && \
    unset TRIX_DOWNLOAD_IONCUBE && \
    rm -rf /var/www/html/trixcms.zip && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# End
EXPOSE 80
COPY ./docker-entrypoint.sh /
COPY ./testdb.sh /
WORKDIR /var/www/html
ENTRYPOINT ["/docker-entrypoint.sh"]

