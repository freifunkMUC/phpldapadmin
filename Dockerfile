FROM alpine:3.21

# Argument for the app version
ARG APP_VERSION

# Install required packages
RUN set -ex; \
    apk add --no-cache \
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
        php81-pecl-apcu; \
    \
    rm -f /etc/apache2/conf.d/info.conf /etc/apache2/conf.d/userdir.conf; \
    ln -sf /usr/bin/php81 /usr/bin/php; \
    sed -i -e 's|^#\(LoadModule remoteip_module.*\)|\1|' /etc/apache2/httpd.conf

# Copy configuration files
COPY php.conf.d/ /etc/php81/conf.d/
COPY apache2.conf.d/ /etc/apache2/conf.d/

# Download, extract, and install phpLDAPadmin
RUN set -ex; \
    curl -fsSL -o "phpLDAPadmin-${APP_VERSION}.tar.gz" \
        "https://github.com/leenooks/phpLDAPadmin/archive/${APP_VERSION}.tar.gz"; \
    mkdir -p /var/www/phpldapadmin; \
    tar -xzf "phpLDAPadmin-${APP_VERSION}.tar.gz" --strip-components=1 -C /var/www/phpldapadmin; \
    rm "phpLDAPadmin-${APP_VERSION}.tar.gz"

# Copy entrypoint script
COPY entrypoint.sh /

# Set execute permission on entrypoint.sh
RUN chmod +x /entrypoint.sh

# Signal for proper container stop handling
STOPSIGNAL SIGWINCH

# Set entrypoint and start Apache
ENTRYPOINT ["/entrypoint.sh"]
CMD ["httpd", "-DFOREGROUND"]
