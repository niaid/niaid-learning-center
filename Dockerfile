FROM platform-docker.artifactory.niaid.nih.gov/apache2-php7-alpine3-latest

LABEL maintainer="boris.kan@nih.gov"

USER root

ENV PHP_VER="7" \
    MNT_DIRECTORY="/mnt/data" \
    APACHE2_HTML_DIRECTORY="/var/www/html" \
    APACHE2_SITES_CONF_DIR="/etc/apache2/conf.d" \
    STARTUP_SCRIPTS_DIRECTORY="/opt/startup_scripts"

RUN apk upgrade -U -a
RUN apk update
RUN apk add --upgrade unzip
RUN apk add --update --no-cache \
    aspell \
    bash \
    clamav \
    curl \
    ghostscript \
    git \
    graphviz \
    mysql-client \
    openssl \
    python3 \
    py3-pip \
    unzip \
    zip \
    php${PHP_VER}-ctype \
    php${PHP_VER}-curl \
    php${PHP_VER}-dom \
    php${PHP_VER}-fileinfo \
    php${PHP_VER}-gd \
    php${PHP_VER}-iconv \
    php${PHP_VER}-intl \
    php${PHP_VER}-json \
    php${PHP_VER}-ldap \
    php${PHP_VER}-mbstring \
    php${PHP_VER}-mysqli \
    php${PHP_VER}-opcache \
    php${PHP_VER}-openssl \
    php${PHP_VER}-phar \
    php${PHP_VER}-posix \
    php${PHP_VER}-pspell \
    php${PHP_VER}-session \
    php${PHP_VER}-soap \
    php${PHP_VER}-simplexml \
    php${PHP_VER}-tokenizer \
    php${PHP_VER}-xmlreader \
    php${PHP_VER}-xmlwriter \
    php${PHP_VER}-xmlrpc \
    php${PHP_VER}-zip \
### DEBUGGING
    vim
RUN addgroup default apache
###

## Install AWS CLI
RUN pip3 install awscli --upgrade

## Install Moodle
WORKDIR ${APACHE2_HTML_DIRECTORY}
RUN chown -R apache:apache ${APACHE2_HTML_DIRECTORY}
COPY --chown=apache:apache moodle3.9.17 ${APACHE2_HTML_DIRECTORY}/moodle
# COPY --chown=apache:apache configs/moodle/config.php ${APACHE2_HTML_DIRECTORY}/moodle/config.php
# copy over custom files
# COPY --chown=apache:apache custom/admin/user.php ${APACHE2_HTML_DIRECTORY}/moodle/admin/user.php
# COPY --chown=apache:apache ["custom/images.tar.gz", "custom/docs.tar.gz", "${APACHE2_HTML_DIRECTORY}/moodle/custom/"]
# unpack custom files
WORKDIR ${APACHE2_HTML_DIRECTORY}
# COPY --chown=apache:apache custom/theme/adaptable2/layout/columns3.php ${APACHE2_HTML_DIRECTORY}/moodle/custom/theme/columns3.php
# COPY --chown=apache:apache custom/theme/adaptable2/classes/output/core_user/myprofile/renderer.php ${APACHE2_HTML_DIRECTORY}/moodle/custom/theme/renderer.php
# COPY --chown=apache:apache custom/lib/templates/loginformnew.mustache ${APACHE2_HTML_DIRECTORY}/moodle/custom/lib/templates/loginform.mustache
# COPY --chown=apache:apache custom/lib/moodlelib.php ${APACHE2_HTML_DIRECTORY}/moodle/lib/moodlelib.php

# RUN chown -R apache:apache /opt/certificate \
#    && chmod -R 775 /opt/certificate \
#    && chmod -R 0775 ${APACHE2_HTML_DIRECTORY}/moodle

# move startup scripts to container
WORKDIR ${STARTUP_SCRIPTS_DIRECTORY}
COPY scripts ${STARTUP_SCRIPTS_DIRECTORY}
RUN chmod -R 775 ${STARTUP_SCRIPTS_DIRECTORY}

# Copy the apache config file(s) to correct location
WORKDIR ${APACHE2_SITES_CONF_DIR}
COPY configs/apache/apache-moodle.conf .
# enable mod_rewrite
RUN sed -i '/LoadModule rewrite_module/s/^##g' /etc/apache2/httpd.conf

# copy over custom php config
# COPY configs/php/dlp-php.ini /etc/php7/php.ini
# RUN chmod 644 /etc/php7/php.ini

# DL & Install Composer - required for moosh
# WORKDIR /tmp
RUN curl -sS https://getcomposer.org/installer | php -- --version=1.10.16 && \
    mv composer.phar /usr/local/bin/composer && \
    chmod 777 /usr/local/bin/composer

# Install Moosh
WORKDIR /opt
RUN git clone https://github.com/tmuras/moosh.git \
    && cd moosh \
    # && git checkout tags/0.36 \
    && chmod 775 /opt/moosh/composer.json \
    && chmod 775 /opt/moosh/composer.lock \
    && composer install \
    && ln -s $PWD/moosh.php /usr/local/bin/moosh \
    && chmod 775 /usr/local/bin/moosh

# move custom moodle plugins & command to processing dir & zip
WORKDIR /var/www/.moosh/moodleplugins
# BORIS TODO need to copy the mod certificate folder

COPY --chown=apache:apache custom/moosh-command/ /var/www/.moosh/
RUN chmod -R 775 /var/www/.moosh/ \
    && chown -R apache:apache /var/www/.moosh

EXPOSE 8888

RUN apk del git

USER apache

# local installs & sync
CMD ["/opt/startup_scripts/entrypoint.sh"]
