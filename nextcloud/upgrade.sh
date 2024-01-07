#!/bin/sh
set -eu

run_as() {
    if [ "$(id -u)" = 0 ]; then
        su -p www-data -s /bin/sh -c "$1"
    else
        sh -c "$1"
    fi
}

NEXTCLOUD_ROOT="/var/www/nextcloud"

config_version="0.0.0.0"
if [ -f "$NEXTCLOUD_ROOT/config/config.php" ]; then
    config_version=`php -r "require \"$NEXTCLOUD_ROOT/config/config.php\"; echo \$CONFIG[\"version\"];"`
fi
app_version=`php -r "require \"$NEXTCLOUD_ROOT/version.php\"; echo implode(\".\", \$OC_Version);"`

echo "Initializing nextcloud $app_version ..."

#install
if [ "$config_version" = "0.0.0.0" ]; then
    echo "New nextcloud instance, installing default config files."

    cp -n /usr/share/nextcloud/config/* "$NEXTCLOUD_ROOT/config/"

    echo "running web-based installer on first connect!"
#upgrade
elif [ "$app_version" != "$config_version" ]; then
    echo "Upgrading nextcloud from $config_version ..."
    run_as "php $NEXTCLOUD_ROOT/occ upgrade"
fi

exit 0
