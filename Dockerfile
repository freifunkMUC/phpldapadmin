FROM alpine:3.19.7

ARG APP_VERSION

# Install required packages
RUN apk add --no-cache \
        apache2 \
        curl \
        shadow \
        util-linux \
        php81 \
        php81-apache2 \
        php81-ldap \
        php81-gettext \
        php81-mbstring \
        php81-opcache \
        php81-openssl \
        php81-session \
        php81-xml \
        php81-pecl-apcu && \
    # Remove unnecessary Apache default configs
    rm -f /etc/apache2/conf.d/info.conf /etc/apache2/conf.d/userdir.conf && \
    # Symlink PHP binary for convenience
    ln -sf /usr/bin/php81 /usr/bin/php && \
    # Enable remoteip_module
    sed -i 's|^#\(LoadModule remoteip_module.*\)|\1|' /etc/apache2/httpd.conf

# Copy configuration files
COPY php.conf.d/ /etc/php81/conf.d/
COPY apache2.conf.d/ /etc/apache2/conf.d/

# Download and extract phpLDAPadmin
RUN curl -fsSL -o "/tmp/phpldapadmin.tar.gz" \
        "https://github.com/leenooks/phpLDAPadmin/archive/${APP_VERSION}.tar.gz" && \
    mkdir -p /var/www/phpldapadmin && \
    tar -xzf /tmp/phpldapadmin.tar.gz --strip-components=1 -C /var/www/phpldapadmin && \
    rm /tmp/phpldapadmin.tar.gz

# Copy and prepare entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

STOPSIGNAL SIGWINCH

ENTRYPOINT ["/entrypoint.sh"]
CMD ["httpd", "-DFOREGROUND"]
