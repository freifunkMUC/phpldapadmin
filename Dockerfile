FROM alpine:3.19.7 AS builder

ARG APP_VERSION=1.2.6.7

RUN apk add --no-cache curl tar && \
    curl -fsSL -o "/tmp/phpldapadmin.tar.gz" \
        "https://github.com/leenooks/phpLDAPadmin/archive/${APP_VERSION}.tar.gz" && \
    mkdir -p /phpldapadmin && \
    tar -xzf /tmp/phpldapadmin.tar.gz --strip-components=1 -C /phpldapadmin

FROM alpine:3.19.7

RUN apk add --no-cache \
        apache2 \
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
    rm -f /etc/apache2/conf.d/info.conf /etc/apache2/conf.d/userdir.conf && \
    ln -sf /usr/bin/php81 /usr/bin/php && \
    # Enable remoteip_module for proper client IP logging behind proxies
    sed -i 's|^#\(LoadModule remoteip_module.*\)|\1|' /etc/apache2/httpd.conf

# Copy configuration files
COPY php.conf.d/ /etc/php81/conf.d/
COPY apache2.conf.d/ /etc/apache2/conf.d/

# Copy phpLDAPadmin files from the builder stage
COPY --from=builder /phpldapadmin /var/www/phpldapadmin

# Use SIGTERM as the stop signal for Apache-based containers
STOPSIGNAL SIGTERM
# Use 'httpd -DFOREGROUND' to keep Apache running in the foreground as recommended for Alpine-based containers
CMD ["httpd", "-DFOREGROUND"]
