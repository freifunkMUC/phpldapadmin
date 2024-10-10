FROM alpine:3.19

# Argument for the app version
ARG APP_VERSION

# Install all required packages and configure Apache and PHP
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
    # Remove unnecessary Apache configuration files
    rm -f /etc/apache2/conf.d/info.conf /etc/apache2/conf.d/userdir.conf; \
    \
    # Create symlink for PHP
    ln -sf /usr/bin/php81 /usr/bin/php; \
    \
    # Enable the remoteip_module in Apache configuration
    sed -i -e 's|^#\(LoadModule remoteip_module.*\)|\1|' /etc/apache2/httpd.conf

# Copy PHP and Apache configuration files
COPY php.conf.d/ /etc/php81/conf.d/
COPY apache2.conf.d/ /etc/apache2/conf.d/

# Download, extract, and install phpLDAPadmin
RUN set -ex; \
    curl -fsSL -o "phpLDAPadmin-${APP_VERSION}.tar.gz" \
        "https://github.com/leenooks/phpLDAPadmin/archive/${APP_VERSION}.tar.gz"; \
    mkdir -p /var/www/phpldapadmin; \
    tar -xzf "phpLDAPadmin-${APP_VERSION}.tar.gz" --strip-components=1 -C /var/www/phpldapadmin; \
    rm "phpLDAPadmin-${APP_VERSION}.tar.gz"

# Copy the entrypoint script
COPY entrypoint.sh /

# Signal for proper container stop handling
STOPSIGNAL SIGWINCH

# Set the entrypoint script and Apache start command
ENTRYPOINT ["/entrypoint.sh"]
CMD ["httpd", "-DFOREGROUND"]
