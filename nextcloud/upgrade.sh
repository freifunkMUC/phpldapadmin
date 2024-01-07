#!/bin/sh
set -eu

run_as() {
    if [ "$(id -u)" = 0 ]; then
        su -p www-data -s /bin/sh -c "$1"
    else
        sh -c "$1"
    fi
}

config_version="0.0.0.0"
if [ -f "/var/www/nextcloud/config/config.php" ]; then
    config_version=`php -r 'require "/var/www/nextcloud/config/config.php"; echo $CONFIG["version"];'`
fi
app_version=`php -r 'require "/var/www/nextcloud/version.php"; echo implode(".", $OC_Version);'`

echo "Initializing nextcloud $app_version ..."

#install
if [ "$config_version" = "0.0.0.0" ]; then
    echo "New nextcloud instance, installing default config files."

    cp -n /usr/share/nextcloud/config/* "/var/www/nextcloud/config/"

    echo "running web-based installer on first connect!"
#upgrade
elif [ "$app_version" != "$config_version" ]; then
    echo "Upgrading nextcloud from $config_version ..."
    run_as "php /var/www/nextcloud/occ upgrade"
fi

exit 0
